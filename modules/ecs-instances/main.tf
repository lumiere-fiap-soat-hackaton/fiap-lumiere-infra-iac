# 1. --- NETWORKING (Security Groups) ---

# Security Group for the Application Load Balancer
resource "aws_security_group" "lb_sg" {
  name        = "${var.project_name}-lb-sg"
  description = "Allow HTTP traffic to the load balancer"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-lb-sg"
  }
}

# Security Group for the Fargate Tasks
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "${var.project_name}-tasks-sg"
  description = "Allow traffic from the ALB to the Fargate tasks"
  vpc_id      = var.vpc_id

  # Ingress rule: only allow traffic from the Load Balancer
  ingress {
    protocol        = "tcp"
    from_port       = 3000
    to_port         = 3000
    security_groups = [aws_security_group.lb_sg.id]
  }

  # Egress rule: allow all outbound traffic so containers can pull images
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-tasks-sg"
  }
}


# 2. --- SSL CERTIFICATE ---

# Self-signed SSL certificate using AWS Certificate Manager
resource "aws_acm_certificate" "self_signed" {
  count            =  var.domain_name != null ? 1 : 0
  private_key      = file("${path.module}/certs/private-key.pem")
  certificate_body = file("${path.module}/certs/certificate.pem")

  tags = {
    Name      = "${var.project_name}-self-signed-cert"
    ManagedBy = "Terraform"
  }
}

# 3. --- LOAD BALANCER ---

resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.public_subnets

  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_lb_target_group" "main" {
  name        = "${var.project_name}-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # Required for Fargate

  health_check {
    path                = "/docs"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name      = "${var.project_name}-tg"
    ManagedBy = "Terraform"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_listener" "https" {
  count             = var.domain_name != null ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   =  aws_acm_certificate.self_signed[0].arn 

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}


# 3. --- ECS CLUSTER ---

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  # Optional: Enable Container Insights for enhanced monitoring
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name      = "${var.project_name}-cluster"
    ManagedBy = "Terraform"
  }
}


# 4. --- ECS TASK & SERVICE DEFINITION ---

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.project_name}-api-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc" # Required for Fargate

  cpu    = "256" # 0.25 vCPU
  memory = "512" # 512 MiB

  execution_role_arn = var.ecs_task_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-api-container"
      image     = "nginx:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          name          = "api-port"
          containerPort = 3000
          hostPort      = 3000 # Must be same as containerPort for awsvpc mode
          protocol      = "tcp"
        }
      ]
    }
  ])

  tags = {
    Name      = "${var.project_name}-api-task"
    ManagedBy = "Terraform"
  }
}

resource "aws_ecs_service" "api" {
  name            = "${var.project_name}-api-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn

  desired_count = var.desired_count

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

  launch_type = "FARGATE"
  network_configuration {
    subnets         = var.public_subnets
    security_groups = [aws_security_group.ecs_tasks_sg.id]
    # Set to true if you're in public subnets and need a public IP for tasks
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "${var.project_name}-api-container"
    container_port   = 3000
  }

  # Ensure the ALB listener is created before the service tries to attach to it
  depends_on = [aws_lb_listener.http, aws_lb_listener.https]
}

# CloudWatch Log Group for ECS Tasks
resource "aws_cloudwatch_log_group" "ecs_tasks" {
  name              = "/ecs/${var.project_name}-api"
  retention_in_days = 7
  tags = {
    Name      = "${var.project_name}-ecs-tasks-logs"
    ManagedBy = "Terraform"
  }
}
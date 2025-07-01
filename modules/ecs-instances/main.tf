
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
    from_port       = 80
    to_port         = 80
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


# 2. --- LOAD BALANCER ---

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
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # Required for Fargate

  health_check {
    path                = "/"
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
          containerPort = 80
          hostPort      = 80 # Must be same as containerPort for awsvpc mode
          protocol      = "tcp"
        }
      ]
      tags = {
        Name        = "${var.project_name}-container"
        Environment = "Dev"
      }
    }
  ])
}

resource "aws_ecs_service" "api" {
  name            = "${var.project_name}-api-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn

  desired_count = var.desired_count

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
    container_port   = 80
  }

  # Ensure the ALB listener is created before the service tries to attach to it
  depends_on = [aws_lb_listener.http]
}
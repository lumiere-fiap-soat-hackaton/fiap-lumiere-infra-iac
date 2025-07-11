# 1. --- NETWORKING (Security Groups) ---

# Get current AWS region
data "aws_region" "current" {}

# Local values for security group IDs
locals {
  lb_sg_id         = var.existing_security_group_id != null ? var.existing_security_group_id : aws_security_group.lb_sg[0].id
  ecs_tasks_sg_id  = var.existing_security_group_id != null ? var.existing_security_group_id : aws_security_group.ecs_tasks_sg[0].id
  nlb_to_alb_sg_id = var.existing_security_group_id != null ? var.existing_security_group_id : aws_security_group.nlb_to_alb_sg[0].id
}

# Security Group for the Application Load Balancer
resource "aws_security_group" "lb_sg" {
  count       = var.existing_security_group_id == null ? 1 : 0
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

  # Allow traffic from NLB security group for API Gateway integration
  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [local.nlb_to_alb_sg_id]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [local.nlb_to_alb_sg_id]
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
  count       = var.existing_security_group_id == null ? 1 : 0
  name        = "${var.project_name}-tasks-sg"
  description = "Allow traffic from the ALB to the Fargate tasks"
  vpc_id      = var.vpc_id

  # Ingress rule: only allow traffic from the Load Balancer
  ingress {
    protocol        = "tcp"
    from_port       = 3000
    to_port         = 3000
    security_groups = [local.lb_sg_id]
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

# Security Group for the Network Load Balancer (though NLBs don't use security groups directly)
# This security group will be used to allow traffic from API Gateway VPC Link to ALB
resource "aws_security_group" "nlb_to_alb_sg" {
  count       = var.existing_security_group_id == null ? 1 : 0
  name        = "${var.project_name}-nlb-to-alb-sg"
  description = "Security group for NLB to ALB communication"
  vpc_id      = var.vpc_id

  # Allow HTTP traffic from NLB to ALB
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"] # Private IP ranges
  }

  # Allow HTTPS traffic from NLB to ALB
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"] # Private IP ranges
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-nlb-to-alb-sg"
  }
}


# 2. --- SSL CERTIFICATE ---

# Self-signed SSL certificate using AWS Certificate Manager
resource "aws_acm_certificate" "self_signed" {
  count            = var.domain_name != null ? 1 : 0
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
  security_groups    = [local.lb_sg_id]
  subnets            = var.public_subnets

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Network Load Balancer for API Gateway integration
resource "aws_lb" "nlb_for_api_gateway" {
  name               = "${var.project_name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = length(var.private_subnets) > 0 ? var.private_subnets : var.public_subnets

  enable_deletion_protection = false

  tags = {
    Name      = "${var.project_name}-nlb-for-api-gateway"
    ManagedBy = "Terraform"
  }
}

# Target Group for ALB to forward traffic to ECS tasks
resource "aws_lb_target_group" "main" {
  name        = "${var.project_name}-alb-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/docs/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name      = "${var.project_name}-alb-target-group"
    ManagedBy = "Terraform"
  }
}

# ALB HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# ALB HTTPS Listener (conditional based on SSL certificate)
resource "aws_lb_listener" "https" {
  count             = var.domain_name != null ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.self_signed[0].arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Target Group for NLB to forward traffic to ALB (HTTP)
resource "aws_lb_target_group" "nlb_to_alb" {
  name        = "${var.project_name}-nlb-tg"
  port        = 80
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "alb"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/docs/"
    port                = "traffic-port" # Use traffic-port for ALB targets
    protocol            = "HTTP"         # Use HTTP for ALB targets (required for ALB target type)
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name      = "${var.project_name}-nlb-to-alb-tg"
    ManagedBy = "Terraform"
  }
}

# Target Group for NLB to forward HTTPS traffic to ALB
resource "aws_lb_target_group" "nlb_to_alb_https" {
  count       = var.domain_name != null ? 1 : 0
  name        = "${var.project_name}-nlb-tg-https"
  port        = 443
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "alb"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/docs/"
    port                = "443"   # Use port 443 for HTTPS health checks
    protocol            = "HTTPS" # Use HTTPS for ALB HTTPS targets
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name      = "${var.project_name}-nlb-to-alb-tg-https"
    ManagedBy = "Terraform"
  }
}

# Attach ALB to NLB Target Group (HTTP)
resource "aws_lb_target_group_attachment" "nlb_to_alb" {
  target_group_arn = aws_lb_target_group.nlb_to_alb.arn
  target_id        = aws_lb.main.arn
  port             = 80

  # Ensure ALB listener exists before attaching to target group
  depends_on = [aws_lb_listener.http]
}

# Attach ALB to NLB Target Group (HTTPS)
resource "aws_lb_target_group_attachment" "nlb_to_alb_https" {
  count            = var.domain_name != null ? 1 : 0
  target_group_arn = aws_lb_target_group.nlb_to_alb_https[0].arn
  target_id        = aws_lb.main.arn
  port             = 443

  # Ensure ALB HTTPS listener exists before attaching to target group
  depends_on = [aws_lb_listener.https]
}

# NLB Listener (HTTP)
resource "aws_lb_listener" "nlb" {
  load_balancer_arn = aws_lb.nlb_for_api_gateway.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_to_alb.arn
  }
}

# NLB Listener (HTTPS)
resource "aws_lb_listener" "nlb_https" {
  count             = var.domain_name != null ? 1 : 0
  load_balancer_arn = aws_lb.nlb_for_api_gateway.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_to_alb_https[0].arn
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

# Service Discovery Namespace (Optional - only needed for inter-service communication)
# resource "aws_service_discovery_private_dns_namespace" "main" {
#   name        = "${var.project_name}.local"
#   description = "Private DNS namespace for service discovery"
#   vpc         = var.vpc_id
#
#   tags = {
#     Name      = "${var.project_name}-service-discovery-namespace"
#     ManagedBy = "Terraform"
#   }
# }

# Service Discovery Service (Optional - only needed for inter-service communication)
# resource "aws_service_discovery_service" "api" {
#   name = "api"
#
#   dns_config {
#     namespace_id = aws_service_discovery_private_dns_namespace.main.id
#
#     dns_records {
#       ttl  = 10
#       type = "A"
#     }
#
#     routing_policy = "MULTIVALUE"
#   }
#
#   tags = {
#     Name      = "${var.project_name}-api-service-discovery"
#     ManagedBy = "Terraform"
#   }
# }


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
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_tasks.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
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
    security_groups = [local.ecs_tasks_sg_id]
    # Set to true if you're in public subnets and need a public IP for tasks
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "${var.project_name}-api-container"
    container_port   = 3000
  }

  # Note: service_registries removed - not needed for API Gateway integration
  # service_registries {
  #   registry_arn = aws_service_discovery_service.api.arn
  # }

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

# Route53 record for service discovery (optional but recommended)
resource "aws_route53_record" "service_discovery" {
  count   = var.enable_custom_domain ? 1 : 0
  zone_id = var.route53_zone_id
  name    = "${var.project_name}-api.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.main.dns_name]
}

# VPC Endpoints for better networking performance (optional)
# ECR VPC Endpoint for container image pulls
resource "aws_vpc_endpoint" "ecr_dkr" {
  count               = var.enable_vpc_endpoints ? 1 : 0
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnets
  security_group_ids  = var.existing_security_group_id != null ? [var.existing_security_group_id] : [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = {
    Name      = "${var.project_name}-ecr-dkr-endpoint"
    ManagedBy = "Terraform"
  }
}

# ECR API VPC Endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  count               = var.enable_vpc_endpoints ? 1 : 0
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnets
  security_group_ids  = var.existing_security_group_id != null ? [var.existing_security_group_id] : [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = {
    Name      = "${var.project_name}-ecr-api-endpoint"
    ManagedBy = "Terraform"
  }
}

# S3 VPC Endpoint for accessing ECR layers
resource "aws_vpc_endpoint" "s3" {
  count             = var.enable_vpc_endpoints ? 1 : 0
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name      = "${var.project_name}-s3-endpoint"
    ManagedBy = "Terraform"
  }
}

# CloudWatch Logs VPC Endpoint
resource "aws_vpc_endpoint" "logs" {
  count               = var.enable_vpc_endpoints ? 1 : 0
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnets
  security_group_ids  = var.existing_security_group_id != null ? [var.existing_security_group_id] : [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = {
    Name      = "${var.project_name}-logs-endpoint"
    ManagedBy = "Terraform"
  }
}

# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints" {
  count       = var.enable_vpc_endpoints && var.existing_security_group_id == null ? 1 : 0
  name        = "${var.project_name}-vpc-endpoints-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [local.ecs_tasks_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project_name}-vpc-endpoints-sg"
    ManagedBy = "Terraform"
  }
}
output "load_balancer_dns_name" {
  description = "The public DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "network_load_balancer_arn" {
  description = "The ARN of the Network Load Balancer for API Gateway integration."
  value       = aws_lb.nlb_for_api_gateway.arn
}

output "network_load_balancer_dns_name" {
  description = "The DNS name of the Network Load Balancer for API Gateway integration."
  value       = aws_lb.nlb_for_api_gateway.dns_name
}

output "service_discovery_namespace_id" {
  description = "The ID of the service discovery namespace (commented out - not needed for API Gateway only)"
  value       = null # aws_service_discovery_private_dns_namespace.main.id
}

output "service_discovery_service_name" {
  description = "The name of the service discovery service (commented out - not needed for API Gateway only)"
  value       = null # aws_service_discovery_service.api.name
}

output "ecs_cluster_name" {
  description = "The name of the created ECS cluster."
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "The name of the created ECS service."
  value       = aws_ecs_service.api.name
}

output "ecs_frontend_service_name" {
  description = "The name of the created frontend ECS service."
  value       = aws_ecs_service.frontend.name
}

output "ecs_container_name" {
  description = "The name of the ECS container that runs the video processing tasks."
  value       = "${var.project_name}-api-container"
}

output "ecs_frontend_container_name" {
  description = "The name of the ECS container that runs the React frontend."
  value       = "${var.project_name}-frontend-container"
}

output "ssl_certificate_arn" {
  description = "The ARN of the SSL certificate"
  value       = var.domain_name != null ? aws_acm_certificate.self_signed[0].arn : null
}

output "ssl_certificate_domain" {
  description = "The domain name of the SSL certificate"
  value       = var.domain_name
}

# Service Discovery outputs (commented out - not needed for API Gateway only)
output "service_discovery_namespace_arn" {
  description = "The ARN of the service discovery namespace"
  value       = null # aws_service_discovery_private_dns_namespace.main.arn
}

output "service_discovery_service_arn" {
  description = "The ARN of the service discovery service"
  value       = null # aws_service_discovery_service.api.arn
}

# Security Group outputs for potential cross-module reference
output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = local.lb_sg_id
}

output "ecs_tasks_security_group_id" {
  description = "The ID of the ECS tasks security group"
  value       = local.ecs_tasks_sg_id
}

output "nlb_to_alb_security_group_id" {
  description = "The ID of the NLB to ALB security group"
  value       = local.nlb_to_alb_sg_id
}

# Load Balancer Target Group outputs
output "alb_target_group_arn" {
  description = "The ARN of the ALB target group"
  value       = aws_lb_target_group.main.arn
}

output "alb_frontend_target_group_arn" {
  description = "The ARN of the ALB frontend target group"
  value       = aws_lb_target_group.frontend.arn
}

output "nlb_target_group_arn" {
  description = "The ARN of the NLB target group"
  value       = aws_lb_target_group.nlb_to_alb.arn
}

output "nlb_target_group_https_arn" {
  description = "The ARN of the NLB HTTPS target group"
  value       = var.domain_name != null ? aws_lb_target_group.nlb_to_alb_https[0].arn : null
}

# VPC Endpoint outputs (optional)
output "vpc_endpoints_enabled" {
  description = "Whether VPC endpoints are enabled"
  value       = var.enable_vpc_endpoints
}

output "ecr_vpc_endpoint_id" {
  description = "The ID of the ECR VPC endpoint"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.ecr_dkr[0].id : null
}

output "route53_record_fqdn" {
  description = "The FQDN of the Route53 record for service discovery"
  value       = var.enable_custom_domain ? aws_route53_record.service_discovery[0].fqdn : null
}
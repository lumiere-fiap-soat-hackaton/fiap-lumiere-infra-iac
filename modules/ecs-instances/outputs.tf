output "load_balancer_dns_name" {
  description = "The public DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "ecs_cluster_name" {
  description = "The name of the created ECS cluster."
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "The name of the created ECS service."
  value       = aws_ecs_service.api.name
}

output "ecs_container_name" {
  description = "The name of the ECS container that runs the video processing tasks."
  value       = "${var.project_name}-api-container"
}

output "ssl_certificate_arn" {
  description = "The ARN of the SSL certificate"
  value       = var.domain_name != null ? aws_acm_certificate.self_signed[0].arn : null
}

output "ssl_certificate_domain" {
  description = "The domain name of the SSL certificate"
  value       = var.domain_name
}
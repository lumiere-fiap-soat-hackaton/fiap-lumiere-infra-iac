output "repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.this.name
}

output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.this.arn
}

output "repository_uri" {
  description = "Full URI of the ECR repository (for docker push/pull)"
  value       = aws_ecr_repository.this.repository_url
}

output "registry_id" {
  description = "AWS ECR registry ID"
  value       = aws_ecr_repository.this.registry_id
}
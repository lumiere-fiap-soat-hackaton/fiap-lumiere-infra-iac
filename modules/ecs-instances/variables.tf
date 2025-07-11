variable "project_name" {
  type        = string
  description = "The project's name to use as resources prefix"
}

variable "vpc_id" {
  description = "The ID of the existing VPC."
  type        = string
}

variable "public_subnets" {
  description = "A list of public subnet IDs for the Load Balancer and Fargate tasks."
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of private subnet IDs for the Network Load Balancer."
  type        = list(string)
  default     = []
}

variable "ecs_task_execution_role_arn" {
  type        = string
  description = "The ARN of the ECS task execution role"
}

variable "ecs_task_role_arn" {
  type        = string
  description = "The ARN of the ECS task role"
}

# --- OPTIMIZATION VARIABLE ---
variable "desired_count" {
  description = "Number of tasks to run. Set to 0 to turn off the environment and save costs."
  type        = number
  default     = 0 # Default to OFF to save money
}

variable "ssl_certificate_arn" {
  type        = string
  description = "The ARN of the SSL certificate for HTTPS listener"
  default     = null
}

variable "domain_name" {
  type        = string
  description = "The domain name for the SSL certificate (e.g., example.com or api.example.com)"
  default     = null
}

variable "enable_custom_domain" {
  type        = bool
  description = "Enable custom domain support with Route53"
  default     = false
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for custom domain (required if enable_custom_domain is true)"
  default     = null
}

variable "enable_vpc_endpoints" {
  type        = bool
  description = "Enable VPC endpoints for ECR, S3, and CloudWatch Logs for better networking performance"
  default     = false
}

variable "existing_security_group_id" {
  type        = string
  description = "The ID of an existing security group to use instead of creating new ones"
  default     = null
}
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
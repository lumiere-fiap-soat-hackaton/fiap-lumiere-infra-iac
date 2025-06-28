variable "project_name" {
  type        = string
  description = "The project's name to use as resources prefix"
}

variable "load_balancer_dns" {
  type        = string
  description = "Load balancer DNS name"
}

variable "cognito_user_pool_arn" {
  type        = string
  description = "ARN from Cognito's User Pool for API authorization"
}
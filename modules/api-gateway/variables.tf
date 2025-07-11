variable "project_name" {
  type        = string
  description = "The project's name to use as resources prefix"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "lambda_functions" {
  description = "Map of all Lambda functions with their ARNs and invoke ARNs"
  type = map(object({
    name       = string
    arn        = string
    invoke_arn = string
  }))
}

variable "application_load_balancer_url" {
  type        = string
  description = "Complete URL of the load balancer for the API Gateway"
}

variable "authorizer_role_arn" {
  description = "ARN of the role for the Authorizer Lambda function"
  type        = string
}

variable "authorizer_cache_ttl" {
  description = "Cache results TTL for the Authorizer in seconds"
  type        = number
}

variable "network_load_balancer_arn" {
  description = "ARN of the Network Load Balancer for VPC Link"
  type        = string
}
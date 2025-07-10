variable "project_name" {
  description = "Project name that will be used as a prefix for all resources"
  type        = string
}

variable "api_gateway_endpoint" {
  description = "API Gateway endpoint URL to be used during the build"
  type        = string
}

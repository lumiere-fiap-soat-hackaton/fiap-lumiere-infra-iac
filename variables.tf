variable "account_id" {
  description = "The AWS account ID where the resources will be deployed"
  type        = string
}

variable "account_region" {
  description = "The AWS region to deploy the resources in"
  type        = string
}

variable "project_name" {
  description = "The name of the project to use as resources prefix"
  type        = string
}

variable "load_balancer_dns" {
  type        = string
  description = "DNS of the load balancer to use for the API Gateway"
}
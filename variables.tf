variable "account_id" {
  description = "The AWS account ID where the resources will be deployed"
  type        = string
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID for the application"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key for the application"
  type        = string
  sensitive   = true
}

variable "account_region" {
  description = "The AWS region to deploy the resources in"
  type        = string
}

variable "project_name" {
  description = "The name of the project to use as resources prefix"
  type        = string
  default     = "fiap-lumiere"
}

variable "load_balancer_dns" {
  type        = string
  description = "DNS of the load balancer to use for the API Gateway"
}


# Network variables
variable "vpc_id" {
  description = "The ID of your existing VPC."
  type        = string
}

variable "subnet_ids" {
  description = "A list of public subnet IDs where the Load Balancer and EC2 instances will be placed."
  type        = list(string)
}

# --- Optional Customizations ---
variable "instance_type" {
  description = "The EC2 instance type for the ECS cluster nodes."
  type        = string
  default     = "t3.micro"
}

variable "ecs_service_desired_count" {
  description = "Number of tasks to run in the ECS service. Set to 0 to turn off the environment and save costs."
  type        = number
  default     = 0 # Default to OFF to save money
}
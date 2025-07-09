variable "aws_account_id" {
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

variable "aws_account_region" {
  description = "The AWS region to deploy the resources in"
  type        = string
}

variable "project_name" {
  description = "The name of the project to use as resources prefix"
  type        = string
  default     = "fiap-lumiere"
}

variable "environment" {
  description = "The environment for the deployment"
  type        = string
  default     = "development"
}

variable "log_level" {
  description = "Log level for the Lambda functions"
  type        = string
  default     = "debug"
}

variable "vpc_id" {
  description = "The ID of your existing VPC."
  type        = string
}

variable "subnet_ids" {
  description = "A list of public subnet IDs where the Load Balancer and EC2 instances will be placed."
  type = list(string)
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

variable "lambda_timeout" {
  description = "The timeout for Lambda functions in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "The memory size for Lambda functions in MB"
  type        = number
  default     = 128
}

variable "authorizer_cache_ttl" {
  description = "Cache TTL for the Authorizer in seconds"
  type        = number
  default     = 0 # Default to OFF to prevent wrong cache issues
}

variable "cloudwatch_logs_retention" {
  description = "The retention period for CloudWatch logs in days"
  type        = number
  default     = 14
}

variable "bucket_sources_expiration" {
  type        = number
  description = "Number of days to keep source files in the S3 bucket"
  default     = 3
}

variable "bucket_results_expiration" {
  type        = number
  description = "Number of days to keep result files in the S3 bucket"
  default     = 7
}

variable "buckets_suffix" {
  description = "A unique suffix to append to bucket names to avoid conflicts"
  type        = string

variable "domain_name" {
  description = "The domain name for SSL certificate (e.g., api.example.com). Leave null to skip HTTPS setup."
  type        = string
  default     = null
}
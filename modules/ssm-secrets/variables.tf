variable "project_name" {
  type        = string
  description = "Project name prefix"
}

variable "aws_access_key_id" {
  type        = string
  description = "AWS Access Key ID"
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS Secret Access Key"
  sensitive   = true
}

variable "aws_region" {
  type        = string
  description = "AWS region for the application"
  default     = "us-east-1"
}

variable "dynamodb_table_name" {
  type        = string
  description = "DynamoDB table name for storing media metadata"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name for media storage"
}
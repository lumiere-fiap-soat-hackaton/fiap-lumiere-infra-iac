variable "project_name" {
  type        = string
  description = "Project name prefix"
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

variable "media_events_queue_name" {
  type        = string
  description = "SQS queue name for media events"
}

variable "media_process_queue_name" {
  type        = string
  description = "SQS queue name for media processing"
}

variable "media_result_queue_name" {
  type        = string
  description = "SQS queue name for media results"
}
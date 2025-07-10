variable "project_name" {
  type        = string
  description = "The project's name to use as resources prefix"
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "log_level" {
  description = "Log level for the Lambda functions"
  type        = string
}

variable "auth_client_id" {
  description = "Authentication client ID from Cognito"
  type        = string
  sensitive   = true
}

variable "auth_client_secret" {
  description = "Authentication client secret from Cognito"
  type        = string
  sensitive   = true
}

variable "bucket_name" {
  description = "Name of the S3 bucket from media storage"
  type        = string
}

variable "lambda_exec_role_arn" {
  type        = string
  description = "ARN of the IAM role that the Lambda function will assume"
}

variable "api_gateway_exec_arn" {
  description = "Execution ARN of the API Gateway"
  type        = string
}

variable "artifacts_zip_path" {
  description = "Path to the Lambda function zip artifacts"
  type        = string
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
}

variable "cloudwatch_logs_retention" {
  description = "CloudWatch Logs retention period in days"
  type        = number
}

variable "source_files_events_queue_arn" {
  type        = string
  description = "ARN of the SQS queue that triggers the Lambda function"
}

variable "process_files_request_queue_arn" {
  type        = string
  description = "ARN of the SQS queue that triggers the Lambda function"
}

variable "media_storage_bucket_name" {
  type        = string
  description = "Name of the S3 bucket where media files are stored"
}

variable "media_result_queue_name" {
  type        = string
  description = "Name of the SQS queue where media processing results are sent"
}
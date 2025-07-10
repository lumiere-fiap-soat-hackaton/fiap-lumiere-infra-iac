variable "project_name" {
  type        = string
  description = "The project's name to use as resources prefix"
}

variable "lambda_execution_role_arn" {
  type        = string
  description = "ARN of the IAM role that the Lambda function will assume"
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
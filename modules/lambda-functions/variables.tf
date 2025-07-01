variable "project_name" {
  type        = string
  description = "The project's name to use as resources prefix"
}

variable "lambda_execution_role_arn" {
  type        = string
  description = "ARN of the IAM role that the Lambda function will assume"
}

variable "source_files_events_queue_arn" {
  type        = string
  description = "ARN of the SQS queue that triggers the Lambda function"
}
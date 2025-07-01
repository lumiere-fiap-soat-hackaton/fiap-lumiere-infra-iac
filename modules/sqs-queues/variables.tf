variable "project_name" {
  type        = string
  description = "Project name prefix"
}

variable "source_bucket_arn" {
  type        = string
  description = "ARN of s3 bucket to allow sending messages to the SQS queue"
}

variable "processor_lambda_arn" {
  type        = string
  description = "ARN of the Lambda function that processes the results and sends messages to the SQS queue"
}

variable "account_id" {
  type        = string
  description = "AWS Account ID"
}
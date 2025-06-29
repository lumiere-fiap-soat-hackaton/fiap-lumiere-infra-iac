variable "project_name" {
  type        = string
  description = "Project name prefix"
}

variable "source_bucket_arn" {
  type        = string
  description = "ARN of s3 bucket to allow sending messages to the SQS queue"
}

variable "result_bucket_arn" {
  type        = string
  description = "ARN of s3 bucket to allow sending messages to the SQS queue"
}
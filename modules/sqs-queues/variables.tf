variable "project_name" {
  type        = string
  description = "Project name prefix"
}

variable "media_storage_events_origin" {
  type = string
  description = "ARN of s3 bucket to allow sending messages to the SQS queue"
}
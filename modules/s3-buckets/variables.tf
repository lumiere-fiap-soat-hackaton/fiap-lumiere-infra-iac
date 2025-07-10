variable "project_name" {
  type        = string
  description = "The project's name to use as resources prefix"
}
variable "environment" {
  description = "Environment"
  type        = string
}

variable "sources_media_queue" {
  type        = string
  description = "The ARN of the SQS queue for media storage sources events"
}

variable "results_media_queue" {
  type        = string
  description = "The ARN of the SQS queue for media storage results events"
}

variable "sources_exp_days" {
  type        = number
  description = "Number of days to keep source files in the S3 bucket"
}

variable "results_exp_days" {
  type        = number
  description = "Number of days to keep results in the S3 bucket"
}

variable "buckets_suffix" {
  description = "A unique suffix to append to bucket names to avoid conflicts"
  type        = string
}
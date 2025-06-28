variable "project_name" {
  type        = string
  description = "The project's name to use as resources prefix"
}

variable "source_files_events_queue" {
  type        = string
  description = "The ARN of the SQS queue for media storage sources events"
}

variable "result_files_events_queue" {
  type        = string
  description = "The ARN of the SQS queue for media storage results events"
}
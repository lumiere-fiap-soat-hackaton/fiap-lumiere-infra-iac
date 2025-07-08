output "source_files_events_queue_arn" {
  value       = aws_sqs_queue.source_files_events_queue.arn
  description = "The queue to receive source video upload events"
}

output "result_files_events_queue_arn" {
  value       = aws_sqs_queue.result_files_events_queue.arn
  description = "The queue to receive video processing result events"
}

output "process_files_request_queue_arn" {
  value       = aws_sqs_queue.process_files_request_queue.arn
  description = "The queue to receive file processing requests"
}

output "source_files_events_queue_url" {
  value       = aws_sqs_queue.source_files_events_queue.id
  description = "URL of the source files events queue"
}

output "result_files_events_queue_url" {
  value       = aws_sqs_queue.result_files_events_queue.id
  description = "URL of the result files events queue"
}

output "process_files_request_queue_url" {
  value       = aws_sqs_queue.process_files_request_queue.id
  description = "URL of the process files request queue"
}
output "source_files_events_queue_arn" {
  value       = aws_sqs_queue.source_files_events_queue.arn
  description = "The queue to receive source video upload events"
}

output "result_files_events_queue_arn" {
  value       = aws_sqs_queue.result_files_events_queue.arn
  description = "The queue to receive video processing result events"
}
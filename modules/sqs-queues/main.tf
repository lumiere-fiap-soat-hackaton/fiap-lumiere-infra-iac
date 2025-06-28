resource "aws_sqs_queue" "source_files_events_queue" {
  name = "${var.project_name}-source-files-events-queue"
}

resource "aws_sqs_queue_policy" "source_files_events_policy" {
  queue_url = aws_sqs_queue.source_files_events_queue.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action   = "sqs:SendMessage",
        Resource = aws_sqs_queue.source_files_events_queue.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = var.media_storage_events_origin
          }
        }
      }
    ]
  })
}

resource "aws_sqs_queue" "result_files_events_queue" {
  name = "${var.project_name}-result-files-events-queue"
}

resource "aws_sqs_queue_policy" "result_files_events_policy" {
  queue_url = aws_sqs_queue.result_files_events_queue.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action   = "sqs:SendMessage",
        Resource = aws_sqs_queue.result_files_events_queue.arn,
        Condition = {
          ArnEquals = {
          ArnEquals = {
            "aws:SourceArn" = var.media_storage_events_origin
          }
        }
      }
    ]
  })
}
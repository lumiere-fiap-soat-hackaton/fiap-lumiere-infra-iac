# Queues
resource "aws_sqs_queue" "source_files_events_queue" {
  name = "${var.project_name}-source-files-events-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.source_files_events_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue" "result_files_events_queue" {
  name = "${var.project_name}-result-files-events-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.result_files_events_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue" "process_files_request_queue" {
  name                       = "${var.project_name}-process-files-request-queue"
  visibility_timeout_seconds = 300 # 5 minutes

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.process_files_request_dlq.arn
    maxReceiveCount     = 3
  })
}


# Dead Letter Queues
resource "aws_sqs_queue" "source_files_events_dlq" {
  name = "${var.project_name}-source-files-events-dlq"
}

resource "aws_sqs_queue" "result_files_events_dlq" {
  name = "${var.project_name}-result-files-events-dlq"
}

resource "aws_sqs_queue" "process_files_request_dlq" {
  name = "${var.project_name}-process-files-request-dlq"
}


# IAM Policy Documents
data "aws_iam_policy_document" "source_files_events_queue_policy_doc" {
  statement {
    effect  = "Allow"
    actions = ["sqs:*"]
    # The service principal for S3
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com", "ecs.amazonaws.com"]
    }
    # The ARN of the queue this policy will be attached to
    resources = [aws_sqs_queue.source_files_events_queue.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }
  }
}

resource "aws_sqs_queue_policy" "source_files_events_queue_policy" {
  queue_url = aws_sqs_queue.source_files_events_queue.id
  policy    = data.aws_iam_policy_document.source_files_events_queue_policy_doc.json
}

data "aws_iam_policy_document" "result_files_events_queue_policy_doc" {
  statement {
    effect  = "Allow"
    actions = ["sqs:*"]
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "lambda.amazonaws.com", "s3.amazonaws.com"]
    }
    resources = [aws_sqs_queue.result_files_events_queue.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }
  }
}

resource "aws_sqs_queue_policy" "result_files_events_queue_policy" {
  queue_url = aws_sqs_queue.result_files_events_queue.id
  policy    = data.aws_iam_policy_document.result_files_events_queue_policy_doc.json
}

data "aws_iam_policy_document" "process_files_request_queue_policy_doc" {
  statement {
    effect  = "Allow"
    actions = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "lambda.amazonaws.com"]
    }
    resources = [aws_sqs_queue.process_files_request_queue.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }
  }
}

resource "aws_sqs_queue_policy" "process_files_request_queue_policy" {
  queue_url = aws_sqs_queue.process_files_request_queue.id
  policy    = data.aws_iam_policy_document.process_files_request_queue_policy_doc.json
}
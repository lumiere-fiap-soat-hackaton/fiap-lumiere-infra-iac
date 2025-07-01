resource "aws_sqs_queue" "source_files_events_queue" {
  name = "${var.project_name}-source-files-events-queue"
}

resource "aws_sqs_queue" "result_files_events_queue" {
  name = "${var.project_name}-result-files-events-queue"
}


data "aws_iam_policy_document" "source_files_events_queue_policy_doc" {
  statement {
    effect  = "Allow"
    actions = ["sqs:SendMessage"]
    # The service principal for S3
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    # The ARN of the queue this policy will be attached to
    resources = [aws_sqs_queue.source_files_events_queue.arn]

    # Condition to ensure only your specific S3 bucket can send messages
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [var.source_bucket_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }
  }
}

resource "aws_sqs_queue_policy" "source_queue_policy" {
  queue_url = aws_sqs_queue.source_files_events_queue.id
  policy    = data.aws_iam_policy_document.source_files_events_queue_policy_doc.json
}


data "aws_iam_policy_document" "result_files_events_queue_policy_doc" {
  statement {
    effect  = "Allow"
    actions = ["sqs:SendMessage"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    resources = [aws_sqs_queue.result_files_events_queue.arn]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [var.processor_lambda_arn]
    }
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

resource "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda-code/lambda_function.py"
  output_path = "${path.module}/lambda_function_${local.environment}.zip"
}

resource "aws_lambda_function" "media_processor" {
  # Naming and runtime
  function_name = "${local.lambda_prefix}MediaProcessorLambda"
  runtime       = "python3.9"

  # The IAM role is now provided by a variable
  role = var.lambda_execution_role_arn

  # Code source
  filename         = archive_file.lambda_zip.output_path
  handler          = "lambda_function.lambda_handler"
  source_code_hash = archive_file.lambda_zip.output_base64sha256

  # Ephemeral storage configuration - set to maximum size
  ephemeral_storage {
    size = 10240 # Maximum size in MB (10 GB)
  }

  # Ignores to lambda code and layers changes
  lifecycle {
    ignore_changes = [
      layers,
      source_code_hash,
    ]
  }
  
  tags = {
    ManagedBy   = "Terraform"
    Environment = local.environment
  }
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = var.source_files_events_queue_arn
  function_name    = aws_lambda_function.media_processor.arn
  batch_size       = local.lambda_batch_size
}
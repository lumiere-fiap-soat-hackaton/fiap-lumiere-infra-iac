resource "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda-code/lambda_function.py"
  output_path = "${path.module}/lambda_function_${var.environment}.zip"
}

resource "aws_lambda_function" "media_processor" {
  # Naming and runtime
  function_name = "${local.lambda_prefix}MediaProcessorLambda"
  runtime = "python3.9"

  # The IAM role is now provided by a variable
  role = var.lambda_exec_role_arn

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
    Environment = var.environment
  }
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = var.source_files_events_queue_arn
  function_name    = aws_lambda_function.media_processor.arn
  batch_size       = local.lambda_batch_size
}

# //////// Auth lambda functions ////////

# Use for_each to dynamically create Lambda functions
resource "aws_lambda_function" "functions" {
  for_each = local.lambda_functions

  function_name = "${var.project_name}-${each.value.name}"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = var.lambda_exec_role_arn
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size
  filename      = local.artifacts_path[each.key]
  source_code_hash = filebase64sha256(local.artifacts_path[each.key])

  environment {
    variables = local.common_environment_variables
  }
}

# API Gateway permissions using for_each
resource "aws_lambda_permission" "api_gateway_permissions" {
  for_each = local.lambda_functions

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.functions[each.key].function_name
  source_arn    = "${var.api_gateway_exec_arn}/*/*"
}

# CloudWatch Log Groups using for_each
resource "aws_cloudwatch_log_group" "log_groups" {
  for_each = local.lambda_functions

  name              = "/aws/lambda/${aws_lambda_function.functions[each.key].function_name}"
  retention_in_days = var.cloudwatch_logs_retention
}
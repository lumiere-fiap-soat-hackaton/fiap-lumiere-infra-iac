output "lambda_name" {
  description = "Name of the Lambda function that processes media files"
  value       = aws_lambda_function.media_processor.function_name
}

output "lambda_arn" {
  description = "ARN of the Lambda function that processes media files"
  value       = aws_lambda_function.media_processor.arn
}
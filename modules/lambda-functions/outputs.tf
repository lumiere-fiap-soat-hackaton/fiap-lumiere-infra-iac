output "lambda_name" {
  description = "Name of the Lambda function that processes media files"
  value       = aws_lambda_function.media_processor.function_name
}

output "lambda_arn" {
  description = "ARN of the Lambda function that processes media files"
  value       = aws_lambda_function.media_processor.arn
}

output "lambda_functions" {
  description = "Map of all Lambda functions with their ARNs and invoke ARNs"
  value       = {
    for key, function in aws_lambda_function.functions : key => {
      name       = function.function_name
      arn        = function.arn
      invoke_arn = function.invoke_arn
    }
  }
}
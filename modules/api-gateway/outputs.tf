output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.api_gateway.execution_arn
}

output "api_gateway_invoke_url" {
  description = "Invocation URL of the API Gateway"
  value       = aws_api_gateway_stage.api_gateway_stage.invoke_url
}

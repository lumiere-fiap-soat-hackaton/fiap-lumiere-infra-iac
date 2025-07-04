output "table_name" {
  description = "The name of the DynamoDB table."
  value       = aws_dynamodb_table.main.name
}

output "dev_table_arn" {
  description = "The ARN of the dev DynamoDB table."
  value       = aws_dynamodb_table.main.arn
}
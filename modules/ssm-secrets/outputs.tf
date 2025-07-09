# AWS Credentials Outputs
output "aws_access_key_id_parameter_name" {
  description = "SSM parameter name for AWS Access Key ID"
  value       = aws_ssm_parameter.parameters["aws_access_key_id"].name
}

output "aws_secret_access_key_parameter_name" {
  description = "SSM parameter name for AWS Secret Access Key"
  value       = aws_ssm_parameter.parameters["aws_secret_access_key"].name
}

# DynamoDB Configuration Outputs
output "dynamodb_endpoint_parameter_name" {
  description = "SSM parameter name for DynamoDB endpoint"
  value       = aws_ssm_parameter.parameters["dynamodb_endpoint"].name
}

output "dynamodb_region_parameter_name" {
  description = "SSM parameter name for DynamoDB region"
  value       = aws_ssm_parameter.parameters["dynamodb_region"].name
}

output "dynamodb_table_name_parameter_name" {
  description = "SSM parameter name for DynamoDB table name"
  value       = aws_ssm_parameter.parameters["dynamodb_table_name"].name
}

# S3 Configuration Outputs
output "s3_bucket_name_parameter_name" {
  description = "SSM parameter name for S3 bucket name"
  value       = aws_ssm_parameter.parameters["s3_bucket_name"].name
}

# SQS Configuration Outputs
output "media_events_queue_name_parameter_name" {
  description = "SSM parameter name for media events queue name"
  value       = aws_ssm_parameter.parameters["media_events_queue_name"].name
}

output "media_process_queue_name_parameter_name" {
  description = "SSM parameter name for media process queue name"
  value       = aws_ssm_parameter.parameters["media_process_queue_name"].name
}

output "media_result_queue_name_parameter_name" {
  description = "SSM parameter name for media result queue name"
  value       = aws_ssm_parameter.parameters["media_result_queue_name"].name
}

output "sqs_endpoint_parameter_name" {
  description = "SSM parameter name for SQS endpoint"
  value       = aws_ssm_parameter.parameters["sqs_endpoint"].name
}

# Convenience output for all parameter names
output "all_parameter_names" {
  description = "Map of all SSM parameter names"
  value = {
    for key, param in aws_ssm_parameter.parameters : key => param.name
  }
}
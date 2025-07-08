# AWS Credentials Outputs
output "aws_access_key_id_parameter_name" {
  description = "SSM parameter name for AWS Access Key ID"
  value       = aws_ssm_parameter.aws_access_key_id.name
}

output "aws_secret_access_key_parameter_name" {
  description = "SSM parameter name for AWS Secret Access Key"
  value       = aws_ssm_parameter.aws_secret_access_key.name
}

# DynamoDB Configuration Outputs
output "dynamodb_endpoint_parameter_name" {
  description = "SSM parameter name for DynamoDB endpoint"
  value       = aws_ssm_parameter.dynamodb_endpoint.name
}

output "dynamodb_region_parameter_name" {
  description = "SSM parameter name for DynamoDB region"
  value       = aws_ssm_parameter.dynamodb_region.name
}

output "dynamodb_table_name" {
  description = "SSM parameter name for DynamoDB table name"
  value       = aws_ssm_parameter.dynamodb_table_name.name
}

# S3 Configuration Outputs
output "s3_bucket_name_parameter_name" {
  description = "SSM parameter name for S3 bucket name"
  value       = aws_ssm_parameter.s3_bucket_name.name
}

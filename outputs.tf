# S3 Bucket outputs
output "media_storage_bucket_name" {
  description = "Name of the S3 bucket where media files are stored"
  value       = module.s3_buckets.media_storage_bucket_name
}

output "media_storage_bucket_arn" {
  description = "ARN of the S3 bucket where media files are stored"
  value       = module.s3_buckets.media_storage_bucket_arn
}

output "lambda_code_bucket_name" {
  description = "Name of the S3 bucket where Lambda code is stored"
  value       = module.s3_buckets.lambda_code_bucket_name
}

output "lambda_code_bucket_arn" {
  description = "ARN of the S3 bucket where Lambda code is stored"
  value       = module.s3_buckets.lambda_code_bucket_arn
}

# Lambda function outputs
output "lambda_processor_name" {
  description = "Name of the Lambda function that processes media files"
  value       = module.lambda_functions.lambda_name
}

output "lambda_processor_arn" {
  description = "ARN of the Lambda function that processes media files"
  value       = module.lambda_functions.lambda_arn
}

# ECR outputs
output "ecr_repository_name" {
  description = "Name of the ECR repository for the video processor"
  value       = module.ecr_repositories.repository_name
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository for the video processor"
  value       = module.ecr_repositories.repository_arn
}

output "ecr_repository_uri" {
  description = "Full URI of the ECR repository (for docker push/pull)"
  value       = module.ecr_repositories.repository_uri
}

# ECS outputs
output "ecs_service_name" {
  description = "Name of the ECS service that runs the video processing tasks"
  value       = module.ecs_instances.ecs_service_name
}

output "ecs_container_name" {
  description = "Name of the ECS container that runs the video processing tasks"
  value       = module.ecs_instances.ecs_container_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster where the video processing tasks are deployed"
  value       = module.ecs_instances.ecs_cluster_name
}

output "load_balancer_dns_name" {
  description = "The public DNS name of the Application Load Balancer"
  value       = module.ecs_instances.load_balancer_dns_name
}

output "ssl_certificate_arn" {
  description = "The ARN of the SSL certificate"
  value       = module.ecs_instances.ssl_certificate_arn
}

output "ssl_certificate_domain" {
  description = "The domain name of the SSL certificate"
  value       = module.ecs_instances.ssl_certificate_domain
}

# DynamoDB outputs
output "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  value       = module.dynamo_db.table_name
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table"
  value       = module.dynamo_db.dev_table_arn
}

# SQS outputs
output "source_files_events_queue_arn" {
  description = "The queue to receive source video upload events"
  value       = module.sqs_queues.source_files_events_queue_arn
}

output "result_files_events_queue_arn" {
  description = "The queue to receive video processing result events"
  value       = module.sqs_queues.result_files_events_queue_arn
}

output "process_files_request_queue_arn" {
  description = "The queue to receive file processing requests"
  value       = module.sqs_queues.process_files_request_queue_arn

}

output "source_files_events_queue_url" {
  description = "URL of the source files events queue"
  value       = module.sqs_queues.source_files_events_queue_url
}

output "result_files_events_queue_url" {
  description = "URL of the result files events queue"
  value       = module.sqs_queues.result_files_events_queue_url
}

output "process_files_request_queue_url" {
  description = "URL of the process files request queue"
  value       = module.sqs_queues.process_files_request_queue_url

}

# Cognito outputs
output "cognito_user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = module.cognito_pools.user_pool_arn
}

# Project info
output "project_name" {
  description = "Project name used as prefix for resources"
  value       = var.project_name
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.account_region
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = local.account_id
}
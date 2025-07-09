locals {
  # Common tag sets to avoid repetition
  base_tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }

  secret_tags = merge(local.base_tags, {
    Type = "Secret"
  })

  config_tags = merge(local.base_tags, {
    Type = "Configuration"
  })

  # Parameter definitions to reduce repetition
  parameters = {
    # AWS Credentials - SecureString type for sensitive data
    aws_access_key_id = {
      name        = "/${var.project_name}/aws/AWS_ACCESS_KEY_ID"
      type        = "SecureString"
      value       = var.aws_access_key_id
      description = "AWS Access Key ID for the application"
      tags        = merge(local.secret_tags, { Name = "${var.project_name}-aws-access-key-id" })
    }

    aws_secret_access_key = {
      name        = "/${var.project_name}/aws/AWS_SECRET_ACCESS_KEY"
      type        = "SecureString"
      value       = var.aws_secret_access_key
      description = "AWS Secret Access Key for the application"
      tags        = merge(local.secret_tags, { Name = "${var.project_name}-aws-secret-access-key" })
    }

    # DynamoDB Configuration
    dynamodb_table_name = {
      name        = "/${var.project_name}/dynamodb/DYNAMODB_TABLE_NAME"
      type        = "String"
      value       = var.dynamodb_table_name
      description = "DynamoDB table name for storing media metadata"
      tags        = merge(local.config_tags, { Name = "${var.project_name}-dynamodb-table-name" })
    }

    dynamodb_endpoint = {
      name        = "/${var.project_name}/dynamodb/DYNAMODB_ENDPOINT"
      type        = "String"
      value       = local.dynamodb_endpoint
      description = "DynamoDB endpoint URL"
      tags        = merge(local.config_tags, { Name = "${var.project_name}-dynamodb-endpoint" })
    }

    dynamodb_region = {
      name        = "/${var.project_name}/dynamodb/DYNAMODB_REGION"
      type        = "String"
      value       = local.dynamodb_region
      description = "DynamoDB region"
      tags        = merge(local.config_tags, { Name = "${var.project_name}-dynamodb-region" })
    }

    # S3 Configuration
    s3_bucket_name = {
      name        = "/${var.project_name}/s3/AWS_S3_BUCKET_NAME"
      type        = "String"
      value       = var.s3_bucket_name
      description = "S3 bucket name for media storage"
      tags        = merge(local.config_tags, { Name = "${var.project_name}-s3-bucket-name" })
    }

    # SQS Configuration
    media_events_queue_name = {
      name        = "/${var.project_name}/sqs/MEDIA_EVENTS_QUEUE_NAME"
      type        = "String"
      value       = var.media_events_queue_name
      description = "SQS queue name for media events"
      tags        = merge(local.config_tags, { Name = "${var.project_name}-media-events-queue-name" })
    }

    media_process_queue_name = {
      name        = "/${var.project_name}/sqs/MEDIA_PROCESS_QUEUE_NAME"
      type        = "String"
      value       = var.media_process_queue_name
      description = "SQS queue name for media processing"
      tags        = merge(local.config_tags, { Name = "${var.project_name}-media-process-queue-name" })
    }

    media_result_queue_name = {
      name        = "/${var.project_name}/sqs/MEDIA_RESULT_QUEUE_NAME"
      type        = "String"
      value       = var.media_result_queue_name
      description = "SQS queue name for media results"
      tags        = merge(local.config_tags, { Name = "${var.project_name}-media-result-queue-name" })
    }

    sqs_endpoint = {
      name        = "/${var.project_name}/sqs/SQS_ENDPOINT"
      type        = "String"
      value       = local.sqs_endpoint
      description = "SQS endpoint URL"
      tags        = merge(local.config_tags, { Name = "${var.project_name}-sqs-endpoint" })
    }
  }
}

# Create SSM parameters using for_each to eliminate repetition
resource "aws_ssm_parameter" "parameters" {
  for_each = local.parameters

  overwrite = true

  name        = each.value.name
  type        = each.value.type
  value       = each.value.value
  description = each.value.description
  tags        = each.value.tags
}
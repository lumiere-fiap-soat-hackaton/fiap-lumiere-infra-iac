# AWS Credentials - SecureString type for sensitive data
resource "aws_ssm_parameter" "aws_access_key_id" {
  name  = "/${var.project_name}/aws/AWS_ACCESS_KEY_ID"
  type  = "SecureString"
  value = var.aws_access_key_id

  description = "AWS Access Key ID for the application"

  tags = {
    Name        = "${var.project_name}-aws-access-key-id"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Type        = "Secret"
  }
}

resource "aws_ssm_parameter" "aws_secret_access_key" {
  name  = "/${var.project_name}/aws/AWS_SECRET_ACCESS_KEY"
  type  = "SecureString"
  value = var.aws_secret_access_key

  description = "AWS Secret Access Key for the application"

  tags = {
    Name        = "${var.project_name}-aws-secret-access-key"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Type        = "Secret"
  }
}

# DynamoDB Configuration
resource "aws_ssm_parameter" "dynamodb_table_name" {
  name  = "/${var.project_name}/dynamodb/DYNAMODB_TABLE_NAME"
  type  = "String"
  value = var.dynamodb_table_name

  description = "DynamoDB table name for storing media metadata"

  tags = {
    Name        = "${var.project_name}-dynamodb-table-name"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Type        = "Configuration"
  }

}

resource "aws_ssm_parameter" "dynamodb_endpoint" {
  name  = "/${var.project_name}/dynamodb/DYNAMODB_ENDPOINT"
  type  = "String"
  value = local.dynamodb_endpoint

  description = "DynamoDB endpoint URL"

  tags = {
    Name        = "${var.project_name}-dynamodb-endpoint"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Type        = "Configuration"
  }
}

resource "aws_ssm_parameter" "dynamodb_region" {
  name  = "/${var.project_name}/dynamodb/DYNAMODB_REGION"
  type  = "String"
  value = local.dynamodb_region

  description = "DynamoDB region"

  tags = {
    Name        = "${var.project_name}-dynamodb-region"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Type        = "Configuration"
  }
}

# S3 Configuration
resource "aws_ssm_parameter" "s3_bucket_name" {
  name  = "/${var.project_name}/s3/AWS_S3_BUCKET_NAME"
  type  = "String"
  value = var.s3_bucket_name

  description = "S3 bucket name for media storage"

  tags = {
    Name        = "${var.project_name}-s3-bucket-name"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Type        = "Configuration"
  }
}
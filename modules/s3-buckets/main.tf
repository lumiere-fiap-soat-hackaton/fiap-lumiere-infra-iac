resource "aws_s3_bucket" "media_storage" {
  bucket = "${var.project_name}-bucket"

  tags = {
    Name        = "Media storage Bucket"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}

resource "aws_s3_bucket" "lambda_code_storage" {
  bucket = "${var.project_name}-lambda-code-bucket"

  tags = {
    Name        = "Lambda Code Storage Bucket"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "media_storage_lifecycle" {
  bucket = aws_s3_bucket.media_storage.id

  rule {
    id     = "expire-old-uploads"
    status = "Enabled"

    expiration {
      days = 7
    }

    filter {
      prefix = "sources/"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "media_storage_restrictions" {
  bucket                  = aws_s3_bucket.media_storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "media_storage_cors_config" {
  bucket = aws_s3_bucket.media_storage.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_origins = ["*"]
    allowed_methods = ["GET", "PUT"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_notification" "media_storage_sources_event" {
  bucket = aws_s3_bucket.media_storage.id

  queue {
    queue_arn     = var.source_files_events_queue
    events        = ["s3:ObjectCreated:Put"]
    filter_prefix = "sources/*"
  }
}

resource "aws_s3_bucket_versioning" "lambda_code_versioning" {
  bucket = aws_s3_bucket.lambda_code_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lambda_code_lifecycle" {
  bucket = aws_s3_bucket.lambda_code_storage.id

  rule {
    id     = "expire-old-lambda-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    filter {
      prefix = "lambda-code/"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "lambda_code_restrictions" {
  bucket                  = aws_s3_bucket.lambda_code_storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



# resource "aws_s3_bucket_notification" "media_storage_results_event" {
#   bucket = aws_s3_bucket.media_storage.id

#   queue {
#     queue_arn     = var.result_files_events_queue
#     events = ["s3:ObjectCreated:Put"]
#     filter_prefix = "results/"
#   }
# }

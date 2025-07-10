resource "aws_s3_bucket" "media_storage" {
  bucket = "${var.project_name}-bucket-${var.buckets_suffix}"

  tags = {
    Name        = "Media storage Bucket"
    ManagedBy   = "Terraform"
    Environment = var.environment
  }
}

resource "aws_s3_object" "sources" {
  bucket = aws_s3_bucket.media_storage.bucket
  key    = "sources/"
  source = "/dev/null"
  tags = {
    Name        = "Sources Directory"
    Environment = var.environment
  }
}

resource "aws_s3_object" "results" {
  bucket = aws_s3_bucket.media_storage.bucket
  key    = "results/"
  source = "/dev/null"
  tags = {
    Name        = "Results Directory"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "media_storage_lifecycle" {
  bucket = aws_s3_bucket.media_storage.id

  rule {
    id     = "expire-old-source-files"
    status = "Enabled"

    expiration {
      days = var.sources_exp_days
    }

    filter {
      prefix = "${var.videos_folder}/"
    }
  }

  rule {
    id     = "expire-old-result-files"
    status = "Enabled"

    expiration {
      days = var.results_exp_days
    }

    filter {
      prefix = "results/"
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

resource "aws_s3_bucket_notification" "object_created_event" {
  bucket = aws_s3_bucket.media_storage.id

  queue {
    queue_arn     = var.sources_media_queue
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "${var.videos_folder}/"
  }
  queue {
    queue_arn     = var.results_media_queue
    events        = ["s3:ObjectCreated:Put"]
    filter_prefix = "results/*"
  }
}

# lambda processor code storage bucket
resource "aws_s3_bucket" "lambda_code_storage" {
  bucket = "${var.project_name}-lambda-code-bucket-${var.buckets_suffix}"

  tags = {
    Name        = "Lambda Code Storage Bucket"
    ManagedBy   = "Terraform"
    Environment = "dev"
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

# web front bucket for static files
/*resource "aws_s3_bucket" "web_front_bucket" {
  bucket = "${var.project_name}-web-front-bucket-${var.buckets_suffix}"

  tags = {
    Name        = "Application storage Bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_website_configuration" "web_front_bucket_configs" {
  bucket = aws_s3_bucket.web_front_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "web_front_bucket_policy" {
  bucket = aws_s3_bucket.web_front_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.web_front_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "web_front_bucket_public_access" {
  bucket = aws_s3_bucket.web_front_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_cors_configuration" "web_front_bucket_cors_configs" {
  bucket = aws_s3_bucket.web_front_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}*/
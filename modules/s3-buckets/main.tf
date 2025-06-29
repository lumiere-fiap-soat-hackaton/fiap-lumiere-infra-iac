resource "aws_s3_bucket" "buckets" {
  for_each = local.buckets

  bucket = "${var.project_name}-${each.value.name_suffix}"

  tags = {
    Name        = each.value.name_tag
    Environment = "dev"
  }
}

# Apply public access restrictions to all buckets
resource "aws_s3_bucket_public_access_block" "restrictions" {
  for_each = aws_s3_bucket.buckets

  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create event notifications for all buckets
resource "aws_s3_bucket_notification" "events" {
  for_each = local.buckets

  bucket = aws_s3_bucket.buckets[each.key].id

  queue {
    queue_arn = each.value.queue_arn
    events    = ["s3:ObjectCreated:Put"]
  }
}

# Conditionally create lifecycle configuration using the filtered map
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  for_each = local.buckets_with_lifecycle

  bucket = aws_s3_bucket.buckets[each.key].id

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

# Conditionally create CORS configuration using the filtered map
resource "aws_s3_bucket_cors_configuration" "cors_config" {
  for_each = local.buckets_with_cors

  bucket = aws_s3_bucket.buckets[each.key].id

  cors_rule {
    allowed_headers = ["*"]
    allowed_origins = ["*"]
    allowed_methods = ["GET", "PUT"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
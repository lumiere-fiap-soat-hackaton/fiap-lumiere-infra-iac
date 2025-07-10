output "media_storage_bucket_name" {
  description = "Name of the S3 bucket where media files are stored"
  value       = aws_s3_bucket.media_storage.bucket
}

output "media_storage_bucket_arn" {
  description = "ARN of the S3 bucket where media files are stored"
  value       = aws_s3_bucket.media_storage.arn
}

output "lambda_code_bucket_name" {
  description = "Name of the S3 bucket where Lambda code is stored"
  value       = aws_s3_bucket.lambda_code_storage.bucket
}

output "lambda_code_bucket_arn" {
  description = "ARN of the S3 bucket where Lambda code is stored"
  value       = aws_s3_bucket.lambda_code_storage.arn
}

/*output "web_front_bucket_name" {
  value       = aws_s3_bucket.web_front_bucket.bucket
  description = "Application storage Bucket name"
}

output "web_front_bucket_arn" {
  value       = aws_s3_bucket.web_front_bucket.arn
  description = "Application storage Bucket ARN"
}

output "s3_website_endpoint" {
  value       = aws_s3_bucket_website_configuration.web_front_bucket_configs.website_endpoint
  description = "S3 website endpoint URL (HTTP only)"
}*/

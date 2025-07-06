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
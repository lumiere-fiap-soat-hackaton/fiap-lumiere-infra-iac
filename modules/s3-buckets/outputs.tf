output "s3_buckets" {
  description = "A map of the created S3 buckets, with each bucket's name (ID) and ARN."
  value = {
    for key, bucket in aws_s3_bucket.buckets : key => {
      name = bucket.id # For S3 buckets, the 'id' attribute is the bucket name.
      arn  = bucket.arn
    }
  }
}

output "source_bucket_name" {
  description = "The name of the source files S3 bucket."
  value       = aws_s3_bucket.buckets["source_files"].id
}

output "result_bucket_name" {
  description = "The name of the result files S3 bucket."
  value       = aws_s3_bucket.buckets["result_files"].id
}

output "source_bucket_arn" {
  description = "The ARN of the source files S3 bucket."
  value       = aws_s3_bucket.buckets["source_files"].arn
  
}

output "result_bucket_arn" {
  description = "The ARN of the result files S3 bucket."
  value       = aws_s3_bucket.buckets["result_files"].arn
}
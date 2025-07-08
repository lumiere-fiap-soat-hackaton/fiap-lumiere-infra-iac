locals {
  dynamodb_endpoint = "https://dynamodb.${var.aws_region}.amazonaws.com"
  dynamodb_region = var.aws_region
}
locals {
  account_role_arn = "arn:aws:iam::${var.account_id}:role/LabRole"
}

provider "aws" {
  region = var.account_region
}

module "api_gateway" {
  source       = "./modules/api-gateway"
  project_name = var.project_name
}

module "cognito_pools" {
  source       = "./modules/cognito-pools"
  project_name = var.project_name
}

module "dynamo_db" {
  source       = "./modules/dynamo-db"
  project_name = var.project_name
}

module "ecs_instances" {
  source       = "./modules/ecs-instances"
  project_name = var.project_name
}

module "lambda_functions" {
  source       = "./modules/lambda-functions"
  project_name = var.project_name
}

module "s3_buckets" {
  source       = "./modules/s3-buckets"
  project_name = var.project_name
}

module "sqs_queues" {
  source       = "./modules/sqs-queues"
  project_name = var.project_name
}

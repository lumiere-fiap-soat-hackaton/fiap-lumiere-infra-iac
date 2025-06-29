locals {
  account_role_arn = "arn:aws:iam::${var.account_id}:role/LabRole"
}

provider "aws" {
  region = var.account_region
}

module "api_gateway" {
  source                = "./modules/api-gateway"
  project_name          = var.project_name
  load_balancer_dns     = var.load_balancer_dns
  cognito_user_pool_arn = module.cognito_pools.user_pool_arn
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
  source                    = "./modules/s3-buckets"
  project_name              = var.project_name
  source_files_events_queue = module.sqs_queues.source_files_events_queue_arn
  result_files_events_queue = module.sqs_queues.result_files_events_queue_arn
}

module "sqs_queues" {
  source            = "./modules/sqs-queues"
  project_name      = var.project_name
  source_bucket_arn = module.s3_buckets.source_bucket_arn
  result_bucket_arn = module.s3_buckets.result_bucket_arn
}
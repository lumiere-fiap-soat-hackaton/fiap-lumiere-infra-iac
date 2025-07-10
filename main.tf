# This data source gets the current AWS Account ID automatically
data "aws_caller_identity" "current" {}

locals {
  account_id       = data.aws_caller_identity.current.account_id
  account_role_arn = "arn:aws:iam::${local.account_id}:role/LabRole"
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

module "ecr_repositories" {
  source       = "./modules/ecr-repositories"
  project_name = var.project_name
}

module "ecs_instances" {
  source                      = "./modules/ecs-instances"
  project_name                = var.project_name
  vpc_id                      = var.vpc_id
  public_subnets              = var.subnet_ids
  ecs_task_execution_role_arn = local.account_role_arn
  ecs_task_role_arn           = local.account_role_arn
  desired_count               = var.ecs_service_desired_count
  domain_name                 = var.domain_name
}

module "lambda_functions" {
  source                          = "./modules/lambda-functions"
  project_name                    = var.project_name
  lambda_execution_role_arn       = local.account_role_arn
  process_files_request_queue_arn = module.sqs_queues.process_files_request_queue_arn
}

module "s3_buckets" {
  source                    = "./modules/s3-buckets"
  project_name              = var.project_name
  source_files_events_queue = module.sqs_queues.source_files_events_queue_arn
  result_files_events_queue = module.sqs_queues.result_files_events_queue_arn
}

module "sqs_queues" {
  source               = "./modules/sqs-queues"
  project_name         = var.project_name
  account_id           = local.account_id
  source_bucket_arn    = module.s3_buckets.media_storage_bucket_arn
  processor_lambda_arn = module.lambda_functions.lambda_arn
}

module "ssm_secrets" {
  source                   = "./modules/ssm-secrets"
  project_name             = var.project_name
  aws_region               = var.account_region
  s3_bucket_name           = module.s3_buckets.media_storage_bucket_name
  dynamodb_table_name      = module.dynamo_db.table_name
  media_events_queue_name  = module.sqs_queues.source_files_events_queue_name
  media_process_queue_name = module.sqs_queues.process_files_request_queue_name
  media_result_queue_name  = module.sqs_queues.result_files_events_queue_name
}

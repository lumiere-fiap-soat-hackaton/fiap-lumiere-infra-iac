# This data source gets the current AWS Account ID automatically
data "aws_caller_identity" "current" {}

locals {
  account_id        = data.aws_caller_identity.current.account_id
  account_role_arn  = "arn:aws:iam::${local.account_id}:role/LabRole"
  load_balancer_url = "https://${module.ecs_instances.load_balancer_dns_name}"
  artifacts_path    = "${path.module}/artifacts/"
}

provider "aws" {
  region = var.aws_account_region
}

module "cognito_pools" {
  source       = "./modules/cognito-pools"
  project_name = var.project_name
}

module "api_gateway" {
  source       = "./modules/api-gateway"
  project_name = var.project_name

  environment          = var.environment
  authorizer_cache_ttl = var.authorizer_cache_ttl
  subnet_id            = var.subnet_ids[0]
  authorizer_role_arn  = local.account_role_arn
  load_balancer_url    = local.load_balancer_url
  lambda_functions     = module.lambda_functions.lambda_functions

  depends_on = [module.ecs_instances]
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
  source       = "./modules/ecs-instances"
  project_name = var.project_name

  vpc_id                      = var.vpc_id
  public_subnets              = var.subnet_ids
  ecs_task_execution_role_arn = local.account_role_arn
  ecs_task_role_arn           = local.account_role_arn
  desired_count               = var.ecs_service_desired_count
  domain_name                 = var.domain_name
}

module "lambda_functions" {
  source       = "./modules/lambda-functions"
  project_name = var.project_name

  log_level            = var.log_level
  environment          = var.environment
  artifacts_zip_path   = local.artifacts_path
  lambda_exec_role_arn = local.account_role_arn
  bucket_name          = module.s3_buckets.media_storage_bucket_name
  auth_client_id       = module.cognito_pools.user_pool_client_id
  auth_client_secret   = module.cognito_pools.user_pool_client_secret
  api_gateway_exec_arn = module.api_gateway.api_gateway_execution_arn
  source_files_events_queue_arn = module.sqs_queues.source_files_events_queue_arn

  # Lambda settings
  lambda_timeout            = var.lambda_timeout
  lambda_memory_size        = var.lambda_memory_size
  cloudwatch_logs_retention = var.cloudwatch_logs_retention
}

module "s3_buckets" {
  source       = "./modules/s3-buckets"
  project_name = var.project_name

  environment         = var.environment
  buckets_suffix      = var.buckets_suffix
  sources_exp_days    = var.bucket_sources_expiration
  results_exp_days    = var.bucket_results_expiration
  sources_media_queue = module.sqs_queues.source_files_events_queue_arn
  results_media_queue = module.sqs_queues.result_files_events_queue_arn
}

module "sqs_queues" {
  source       = "./modules/sqs-queues"
  project_name = var.project_name

  account_id = local.account_id
}

module "ssm_secrets" {
  source                   = "./modules/ssm-secrets"
  project_name             = var.project_name
  aws_region               = var.aws_account_region
  aws_access_key_id        = var.aws_access_key_id
  aws_secret_access_key    = var.aws_secret_access_key
  s3_bucket_name           = module.s3_buckets.media_storage_bucket_name
  dynamodb_table_name      = module.dynamo_db.table_name
  media_events_queue_name  = module.sqs_queues.source_files_events_queue_name
  media_process_queue_name = module.sqs_queues.process_files_request_queue_name
  media_result_queue_name  = module.sqs_queues.result_files_events_queue_name
}

module "amplify" {
  source       = "./modules/amplify"
  project_name = var.project_name

  api_gateway_endpoint = module.api_gateway.api_gateway_invoke_url
}

module "amplify" {
  source       = "./modules/amplify"
  project_name = var.project_name

  api_gateway_endpoint = module.api_gateway.api_gateway_invoke_url
}

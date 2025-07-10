# API Gateway
resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "${var.project_name}-api-gateway"
  description = "API Gateway for Lumiere Project"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "api_gateway_deploy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.auth.id,
      aws_api_gateway_resource.sign_up_resource.id,
      aws_api_gateway_resource.sign_up_action_resource.id,
      aws_api_gateway_resource.sign_in_resource.id,
      aws_api_gateway_resource.sign_out_resource.id,
      aws_api_gateway_resource.user_data_resource.id,

      aws_api_gateway_resource.api.id,
      aws_api_gateway_resource.storage.id,
      aws_api_gateway_resource.user_records.id,
      aws_api_gateway_resource.storage_action.id,

      aws_api_gateway_resource.v1.id,
      aws_api_gateway_resource.storage_v1_resource.id,
      aws_api_gateway_resource.user_records_v1_resource.id,
      aws_api_gateway_resource.storage_upload_url_v1_resource.id,
      aws_api_gateway_resource.storage_download_url_v1_resource.id,
    ]))
  }

  depends_on = [
    aws_api_gateway_integration.sign_up_action_integration,
    aws_api_gateway_integration.sign_in_integration,
    aws_api_gateway_integration.sign_out_integration,
    aws_api_gateway_integration.user_data_integration,

    aws_api_gateway_integration.user_records_integration,
    aws_api_gateway_integration.storage_action_integration,

    aws_api_gateway_integration.user_records_v1_integration,
    aws_api_gateway_integration.storage_upload_url_v1_integration,
    aws_api_gateway_integration.storage_download_url_v1_integration,
  ]

  lifecycle {
    create_before_destroy = false
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "api_gateway_stage" {
  deployment_id = aws_api_gateway_deployment.api_gateway_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = var.environment
}

# API Gateway Access Authorizer
resource "aws_api_gateway_authorizer" "access_authorizer" {
  name                             = "AccessAuthorizer"
  rest_api_id                      = aws_api_gateway_rest_api.api_gateway.id
  authorizer_uri                   = var.lambda_functions["authorizer"].invoke_arn
  authorizer_credentials           = var.authorizer_role_arn
  authorizer_result_ttl_in_seconds = var.authorizer_cache_ttl
  identity_source                  = "method.request.header.Cookie"
  type                             = "REQUEST"
}

# API Gateway Network load balancer
resource "aws_lb" "api_gateway_lb" {
  name               = "${var.project_name}-api-gateway-lb"
  internal           = true
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id = var.subnet_id
  }
}

resource "aws_api_gateway_vpc_link" "vpc_link" {
  name        = "${var.project_name}-vpc-link"
  target_arns = [aws_lb.api_gateway_lb.arn]

  tags = {
    Name = "${var.project_name}-api-gateway-vpc-link"
  }
}

# //////// ROOT RESOURCES ////////
# /auth
resource "aws_api_gateway_resource" "auth" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "auth"
}

# /api
resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "api"
}
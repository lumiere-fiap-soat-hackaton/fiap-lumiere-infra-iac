locals {
  load_balancer_dns = "https://${var.load_balancer_dns}"
}

resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "${var.project_name}-api-gateway"
  description = "API for project records"
}

# Cognito Authorizer for API Gateway
resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name            = "${var.project_name}-cognito-authorizer"
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  rest_api_id     = aws_api_gateway_rest_api.api_gateway.id
  provider_arns   = [var.cognito_user_pool_arn]
}

# /storage/{operation}
resource "aws_api_gateway_resource" "storage" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "storage"
}

resource "aws_api_gateway_resource" "file_operation" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.storage.id
  path_part   = "{operation}"
}

resource "aws_api_gateway_method" "file_operation" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.file_operation.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  request_parameters = {
    "method.request.path.operation" = true
  }
}

resource "aws_api_gateway_integration" "file_operation" {
  type                    = "HTTP"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.file_operation.id
  http_method             = aws_api_gateway_method.file_operation.http_method
  uri                     = "${local.load_balancer_dns}/storage/{operation}"
  integration_http_method = "POST"
}


# /records/user-records
resource "aws_api_gateway_resource" "records" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "records"
}

resource "aws_api_gateway_resource" "user_records" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.records.id
  path_part   = "user-records"
}

resource "aws_api_gateway_method" "user_records" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.user_records.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  request_parameters = {
    "method.request.querystring.statuses" = false
  }
}

resource "aws_api_gateway_integration" "user_records" {
  type                    = "HTTP"
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.user_records.id
  http_method             = aws_api_gateway_method.user_records.http_method
  uri                     = "${local.load_balancer_dns}/records/user-records"
  integration_http_method = "GET"
}

# ////////////////  API Gateway Deploy //////////////////////////
resource "aws_api_gateway_deployment" "api_gateway_deploy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.file_operation,
    aws_api_gateway_integration.user_records,
  ]
}

resource "aws_api_gateway_stage" "api_gateway_stage_dev" {
  deployment_id = aws_api_gateway_deployment.api_gateway_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = "dev"
}

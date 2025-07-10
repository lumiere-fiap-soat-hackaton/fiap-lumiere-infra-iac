# //////// API V1 RESOURCES ////////

# /api/v1/storage/
resource "aws_api_gateway_resource" "storage_v1_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "storage"
}

# /api/v1/storage/{upload-url|download-url}
resource "aws_api_gateway_resource" "storage_action_v1_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.storage_v1_resource.id
  path_part   = "{action}"
}

# /api/v1/storage/user-records
resource "aws_api_gateway_resource" "user_records_v1_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.storage_v1_resource.id
  path_part   = "user-records"
}

# //////// API V1 METHODS ////////

# POST method for /api/v1/storage/{upload-url|download-url}
resource "aws_api_gateway_method" "storage_v1_action_post" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.storage_action_v1_resource.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.access_authorizer.id
  request_parameters = {
    "method.request.path.action" = true
  }
}

# GET method for /api/v1/storage/user-records
resource "aws_api_gateway_method" "user_v1_records_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.user_records_v1_resource.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.access_authorizer.id
  request_parameters = {
    "method.request.querystring.statuses" = false
  }
}

# //////// API V1 INTEGRATIONS ////////
resource "aws_api_gateway_integration" "storage_action_v1_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.storage_action_v1_resource.id
  http_method             = aws_api_gateway_method.storage_v1_action_post.http_method
  uri                     = var.load_balancer_url
  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  connection_type         = "VPC_LINK"
  connection_id           = ""
}

resource "aws_api_gateway_integration" "user_records_v1_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.user_records_v1_resource.id
  http_method             = aws_api_gateway_method.user_v1_records_get.http_method
  uri                     = var.load_balancer_url
  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  connection_type         = "VPC_LINK"
  connection_id           = ""
}
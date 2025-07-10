# //////// API RESOURCES ////////

# /api/storage/
resource "aws_api_gateway_resource" "storage" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "storage"
}

# /api/storage/{upload-url|download-url}
resource "aws_api_gateway_resource" "storage_action" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.storage.id
  path_part   = "{action}"
}

# /api/storage/user-records
resource "aws_api_gateway_resource" "user_records" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.storage.id
  path_part   = "user-records"
}

# //////// API METHODS ////////

# POST method for /api/storage/{upload-url|download-url}
resource "aws_api_gateway_method" "storage_action_post" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.storage_action.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.access_authorizer.id
  request_parameters = {
    "method.request.path.action" = true
  }
}

# GET method for /api/storage_user-records
resource "aws_api_gateway_method" "user_records_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.user_records.id
  authorizer_id = aws_api_gateway_authorizer.access_authorizer.id
  http_method   = "GET"
  authorization = "CUSTOM"
  request_parameters = {
    "method.request.querystring.statuses" = false
  }
}

# //////// API INTEGRATIONS ////////

resource "aws_api_gateway_integration" "storage_action_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.storage_action.id
  http_method             = aws_api_gateway_method.storage_action_post.http_method
  uri                     = var.lambda_functions["storageUrl"].invoke_arn
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
}

resource "aws_api_gateway_integration" "user_records_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.user_records.id
  http_method             = aws_api_gateway_method.user_records_get.http_method
  uri                     = var.lambda_functions["userRecords"].invoke_arn
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
}
# //////// API V1 RESOURCES ////////
# /api/v1
resource "aws_api_gateway_resource" "v1" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "v1"
}
# /api/v1/storage/
resource "aws_api_gateway_resource" "storage_v1_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "storage"
}

# /api/v1/storage/upload-url
resource "aws_api_gateway_resource" "storage_upload_url_v1_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.storage_v1_resource.id
  path_part   = "upload-url"
}

# /api/v1/storage/download-url
resource "aws_api_gateway_resource" "storage_download_url_v1_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.storage_v1_resource.id
  path_part   = "download-url"
}

# /api/v1/storage/user-records
resource "aws_api_gateway_resource" "user_records_v1_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.storage_v1_resource.id
  path_part   = "user-records"
}

# //////// API V1 METHODS ////////

# POST method for /api/v1/storage/upload-url
resource "aws_api_gateway_method" "storage_upload_url_v1_post" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.storage_upload_url_v1_resource.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.access_authorizer.id
}

# POST method for /api/v1/storage/download-url
resource "aws_api_gateway_method" "storage_download_url_v1_post" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.storage_download_url_v1_resource.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.access_authorizer.id
}

# GET method for /api/v1/storage/user-records
resource "aws_api_gateway_method" "user_records_v1_get" {
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
resource "aws_api_gateway_integration" "storage_upload_url_v1_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.storage_upload_url_v1_resource.id
  http_method             = aws_api_gateway_method.storage_upload_url_v1_post.http_method
  uri                     = "${var.application_load_balancer_url}/api/v1/videos/upload-url"
  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpc_link.id
}

resource "aws_api_gateway_integration" "storage_download_url_v1_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.storage_download_url_v1_resource.id
  http_method             = aws_api_gateway_method.storage_download_url_v1_post.http_method
  uri                     = "${var.application_load_balancer_url}/api/v1/videos/download-url"
  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpc_link.id
}

resource "aws_api_gateway_integration" "user_records_v1_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.user_records_v1_resource.id
  http_method             = aws_api_gateway_method.user_records_v1_get.http_method
  uri                     = "${var.application_load_balancer_url}/api/v1/user-records"
  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpc_link.id
}
# //////// AUTH RESOURCES ////////

# /auth/sign-up resource
resource "aws_api_gateway_resource" "sign_up_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "sign-up"
}

# /auth/sign-up/{create|confirm} resource
resource "aws_api_gateway_resource" "sign_up_action_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.sign_up_resource.id
  path_part   = "{action}"
}

# /auth/sign-in resource
resource "aws_api_gateway_resource" "sign_in_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "sign-in"
}

# /auth/sign-out resource
resource "aws_api_gateway_resource" "sign_out_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "sign-out"
}

# /auth/user-data resource
resource "aws_api_gateway_resource" "user_data_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "user-data"
}

# //////// AUTH METHODS ////////

# POST method for /auth/sign-up/{create|confirm}
resource "aws_api_gateway_method" "sign_up_action_post" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.sign_up_action_resource.id
  http_method   = "POST"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.action" = true
  }
}

# POST method for /auth/sign-in
resource "aws_api_gateway_method" "sign_in_post" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.sign_in_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# POST method for /auth/sign-out
resource "aws_api_gateway_method" "sign_out_post" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.sign_out_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# GET method for /auth/user-data
resource "aws_api_gateway_method" "user_data_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.user_data_resource.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.access_authorizer.id
}

# //////// INTEGRATIONS //////// #
# Integration of SignUp Lambda with API Gateway for /auth/sign-up/{create|confirm }
resource "aws_api_gateway_integration" "sign_up_action_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.sign_up_action_resource.id
  http_method             = aws_api_gateway_method.sign_up_action_post.http_method
  uri                     = var.lambda_functions["signUp"].invoke_arn
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
}

# Integration of SignIn Lambda with API Gateway for /auth/sign-in
resource "aws_api_gateway_integration" "sign_in_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.sign_in_resource.id
  http_method             = aws_api_gateway_method.sign_in_post.http_method
  uri                     = var.lambda_functions["signIn"].invoke_arn
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
}

# Integration of SignOut Lambda with API Gateway for /auth/sign-out
resource "aws_api_gateway_integration" "sign_out_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.sign_out_resource.id
  http_method             = aws_api_gateway_method.sign_out_post.http_method
  uri                     = var.lambda_functions["signOut"].invoke_arn
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
}

# Integration of UserData Lambda with API Gateway for /auth/user-data
resource "aws_api_gateway_integration" "user_data_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.user_data_resource.id
  http_method             = aws_api_gateway_method.user_data_get.http_method
  uri                     = var.lambda_functions["userData"].invoke_arn
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
}
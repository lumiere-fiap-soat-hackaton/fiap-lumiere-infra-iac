resource "aws_amplify_app" "static_website" {
  name = "${var.project_name}-website"

  environment_variables = {
    VITE_API_BASE_URL = var.api_gateway_endpoint
  }

  enable_auto_branch_creation = true
  auto_branch_creation_patterns = [
    "*",
    "*/**",
  ]

  enable_branch_auto_build = false

  # Reverse Proxy Rewrite for API requests
  # https://docs.aws.amazon.com/amplify/latest/userguide/redirects.html#reverse-proxy-rewrite
  custom_rule {
    source = "/server/<*>"
    status = "200"
    target = var.api_gateway_endpoint
  }
}

resource "aws_amplify_branch" "branch" {
  app_id      = aws_amplify_app.static_website.id
  branch_name = "main"

  enable_auto_build = false
}

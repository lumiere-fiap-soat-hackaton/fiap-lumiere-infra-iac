locals {
  lambda_prefix     = join("", [for s in split("-", var.project_name) : title(s)])
  lambda_batch_size = 5
  environment       = "Dev"
}
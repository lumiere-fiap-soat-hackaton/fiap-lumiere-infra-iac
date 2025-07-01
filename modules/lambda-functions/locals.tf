locals {
  lambda_prefix     = join("", [for s in split("-", var.project_name) : title(s)])
  environment       = "Dev"
  
  # Number of messages to pull in one batch (1-10)
  lambda_batch_size = 5
}
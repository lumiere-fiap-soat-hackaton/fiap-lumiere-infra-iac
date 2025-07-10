resource "aws_dynamodb_table" "main" {
  name = "${var.project_name}-table"

  # This is the most critical setting for dev. You only pay for what you use.
  billing_mode = "PAY_PER_REQUEST"

  # A simple primary key (partition key)
  hash_key  = "id"
  range_key = "userId"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  point_in_time_recovery {
    enabled = false
  }
  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "${var.project_name}-table"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

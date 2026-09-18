resource "aws_dynamodb_table" "analytics" {
  name         = "${var.project_name}-${var.environment}-analytics"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"

  attribute {
    name = "userId"
    type = "S"
  }
}


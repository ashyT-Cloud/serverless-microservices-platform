resource "aws_sqs_queue" "analytics_dlq" {
  name = "${var.project_name}-${var.environment}-analytics-dlq"
}

resource "aws_dynamodb_table" "analytics_processed_events" {
  name         = "${var.project_name}-${var.environment}-analytics-prcessed-events"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "eventId"

  attribute {
    name = "eventId"
    type = "S"
  }

  ttl {
    attribute_name = "expiresAt"
    enabled        = true
  }
}

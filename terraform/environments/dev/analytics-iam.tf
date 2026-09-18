resource "aws_iam_role_policy" "analytics_idempotency" {
  name = "${var.project_name}-${var.environment}-analytics-idempotency"
  role = "${var.project_name}-${var.environment}-analytics-service-role"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem"
        ]

        Resource = aws_dynamodb_table.analytics_processed_events.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "analytics_dlq" {
  name = "${var.project_name}-${var.environment}-analytics-dlq"
  role = "${var.project_name}-${var.environment}-analytics-service-role"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "sqs:SendMessage"
        ]

        Resource = aws_sqs_queue.analytics_dlq.arn
      }
    ]
  })
}

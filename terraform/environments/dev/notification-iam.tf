resource "aws_iam_role_policy" "notification_worker" {
  name = "${var.project_name}-${var.environment}-notification-worker"
  role = "${var.project_name}-${var.environment}-notification-service-role"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]

        Resource = aws_sqs_queue.notification.arn
      }
    ]
  })
}

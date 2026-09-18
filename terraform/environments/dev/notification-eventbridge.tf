resource "aws_cloudwatch_event_target" "notification" {
  rule           = aws_cloudwatch_event_rule.workout_created_analytics.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "NotificationQueue"
  arn            = aws_sqs_queue.notification.arn

  retry_policy {
    maximum_event_age_in_seconds = 3600
    maximum_retry_attempts       = 3
  }

  dead_letter_config {
    arn = aws_sqs_queue.notification_dlq.arn
  }
}

resource "aws_sqs_queue_policy" "notification_eventbridge" {
  queue_url = aws_sqs_queue.notification.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowEventBridgeToSendMessages"
        Effect = "Allow"

        Principal = {
          Service = "events.amazonaws.com"
        }

        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.notification.arn

        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.workout_created_analytics.arn
          }
        }
      }
    ]
  })
}


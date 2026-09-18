resource "aws_cloudwatch_event_rule" "workout_created_analytics" {
  name           = "${var.project_name}-${var.environment}-workout-created-analytics"
  description    = "Send WorkoutCreated events to Analytics Service"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source = [
      "fittrack.workout-service"
    ]

    detail-type = [
      "WorkoutCreated"
    ]
  })
}

resource "aws_cloudwatch_event_target" "analytics" {
  rule           = aws_cloudwatch_event_rule.workout_created_analytics.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "AnalyticsService"
  arn            = module.analytics_service.function_arn

  retry_policy {
    maximum_event_age_in_seconds = 3600
    maximum_retry_attempts       = 3
  }

  dead_letter_config {
    arn = aws_sqs_queue.analytics_dlq.arn
  }
}

resource "aws_lambda_permission" "eventbridge_analytics" {
  statement_id  = "AllowEventBridgeInvokeAnalytics"
  action        = "lambda:InvokeFunction"
  function_name = module.analytics_service.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.workout_created_analytics.arn
}

resource "aws_sqs_queue_policy" "analytics_dlq" {
  queue_url = aws_sqs_queue.analytics_dlq.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "events.amazonaws.com"
        }

        Action = "sqs:SendMessage"

        Resource = aws_sqs_queue.analytics_dlq.arn

        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.workout_created_analytics.arn
          }
        }
      }
    ]
  })
}

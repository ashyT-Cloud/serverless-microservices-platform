resource "aws_cloudwatch_log_group" "eventbridge" {
  name              = "/aws/events/${var.project_name}-${var.environment}"
  retention_in_days = 7
}

resource "aws_cloudwatch_event_rule" "workout_created" {
  name           = "${var.project_name}-${var.environment}-workout-created"
  description    = "Capture WorkoutCreated events"
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

resource "aws_cloudwatch_event_target" "workout_created_logs" {
  rule           = aws_cloudwatch_event_rule.workout_created.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "WorkoutCreatedLogs"
  arn            = aws_cloudwatch_log_group.eventbridge.arn
}

resource "aws_cloudwatch_log_resource_policy" "eventbridge" {
  policy_name = "${var.project_name}-${var.environment}-eventbridge-logs"

  policy_document = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowEventBridgeToWriteLogs"
        Effect = "Allow"

        Principal = {
          Service = "events.amazonaws.com"
        }

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "${aws_cloudwatch_log_group.eventbridge.arn}:*"
      }
    ]
  })
}

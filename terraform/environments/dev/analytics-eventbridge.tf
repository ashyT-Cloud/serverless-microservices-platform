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
}

resource "aws_lambda_permission" "eventbridge_analytics" {
  statement_id  = "AllowEventBridgeInvokeAnalytics"
  action        = "lambda:InvokeFunction"
  function_name = module.analytics_service.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.workout_created_analytics.arn
}

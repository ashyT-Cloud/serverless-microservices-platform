# ==========================================
# Lambda Error Alarms
# ==========================================

resource "aws_cloudwatch_metric_alarm" "analytics_errors" {
  alarm_name        = "${var.project_name}-${var.environment}-analytics-errors"
  alarm_description = "Analytics Lambda has execution errors"
  namespace         = "AWS/Lambda"
  metric_name       = "Errors"
  dimensions = {
    FunctionName = module.analytics_service.function_name
  }

  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "notification_errors" {
  alarm_name        = "${var.project_name}-${var.environment}-notification-errors"
  alarm_description = "Notification Worker Lambda has execution errors"
  namespace         = "AWS/Lambda"
  metric_name       = "Errors"
  dimensions = {
    FunctionName = module.notification_service.function_name
  }

  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"
}

# ==========================================
# DLQ Alarms
# ==========================================

resource "aws_cloudwatch_metric_alarm" "analytics_dlq" {
  alarm_name        = "${var.project_name}-${var.environment}-analytics-dlq"
  alarm_description = "Messages are present in Analytics DLQ"
  namespace         = "AWS/SQS"
  metric_name       = "ApproximateNumberOfMessagesVisible"

  dimensions = {
    QueueName = aws_sqs_queue.analytics_dlq.name
  }

  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "notification_dlq" {
  alarm_name        = "${var.project_name}-${var.environment}-notification-dlq"
  alarm_description = "Messages are present in Notification DLQ"
  namespace         = "AWS/SQS"
  metric_name       = "ApproximateNumberOfMessagesVisible"

  dimensions = {
    QueueName = aws_sqs_queue.notification_dlq.name
  }

  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"
}


resource "aws_sqs_queue" "notification_dlq" {
  name = "${var.project_name}-${var.environment}-notification-dlq"
}

resource "aws_sqs_queue" "notification" {
  name                       = "${var.project_name}-${var.environment}-notification"
  visibility_timeout_seconds = 60

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.notification_dlq.arn
    maxReceiveCount     = 3
  })
}

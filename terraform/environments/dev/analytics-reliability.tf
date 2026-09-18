resource "aws_lambda_function_event_invoke_config" "analytics" {
  function_name = module.analytics_service.function_name

  maximum_event_age_in_seconds = 3600
  maximum_retry_attempts       = 2

  destination_config {
    on_failure {
      destination = aws_sqs_queue.analytics_dlq.arn
    }
  }
}


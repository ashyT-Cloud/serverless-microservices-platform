resource "aws_lambda_event_source_mapping" "notification" {
  event_source_arn = aws_sqs_queue.notification.arn
  function_name    = module.notification_service.function_name

  batch_size                         = 5
  maximum_batching_window_in_seconds = 5
}

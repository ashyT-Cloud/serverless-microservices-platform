module "user_service" {
  source = "../../modules/lambda"

  function_name          = "${var.project_name}-${var.environment}-user-service"
  handler                = "handler.lambda_handler"
  runtime                = "python3.12"
  source_dir             = "../../../services/user-service/src"
  dynamodb_table_name    = aws_dynamodb_table.users.name
  dynamodb_table_arn     = aws_dynamodb_table.users.arn
  enable_dynamodb_policy = true
}

module "user_api" {
  source = "../../modules/api-gateway"

  api_name             = "${var.project_name}-${var.environment}-api"
  lambda_arn           = module.user_service.function_arn
  lambda_function_name = module.user_service.function_name

  routes = [
    "GET /users",
    "POST /users",
    "GET /users/{userId}"
  ]
}

module "workout_service" {
  source = "../../modules/lambda"

  function_name                 = "${var.project_name}-${var.environment}-workout-service"
  handler                       = "handler.lambda_handler"
  runtime                       = "python3.12"
  source_dir                    = "../../../services/workout-service/src"
  dynamodb_table_name           = aws_dynamodb_table.workouts.name
  dynamodb_table_arn            = aws_dynamodb_table.workouts.arn
  dynamodb_environment_variable = "WORKOUTS_TABLE"
  event_bus_arn                 = aws_cloudwatch_event_bus.main.arn
  event_bus_name                = aws_cloudwatch_event_bus.main.name
  enable_dynamodb_policy        = true
  enable_eventbridge_policy     = true
}

module "workout_api" {
  source = "../../modules/api-gateway"

  api_name             = "${var.project_name}-${var.environment}-workout-api"
  lambda_arn           = module.workout_service.function_arn
  lambda_function_name = module.workout_service.function_name

  routes = [
    "GET /workouts",
    "POST /workouts",
    "GET /workouts/{workoutId}"
  ]
}

module "analytics_service" {
  source = "../../modules/lambda"

  function_name                 = "${var.project_name}-${var.environment}-analytics-service"
  handler                       = "handler.lambda_handler"
  runtime                       = "python3.12"
  source_dir                    = "../../../services/analytics-service/src"
  dynamodb_table_name           = aws_dynamodb_table.analytics.name
  dynamodb_table_arn            = aws_dynamodb_table.analytics.arn
  dynamodb_environment_variable = "ANALYTICS_TABLE"
  enable_dynamodb_policy        = true

  environment_variables = {
    IDEMPOTENCY_TABLE = aws_dynamodb_table.analytics_processed_events.name
  }
}

module "notification_service" {
  source = "../../modules/lambda"

  function_name = "${var.project_name}-${var.environment}-notification-service"
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"
  source_dir    = "../../../services/notification-service/src"

  environment_variables = {
    NOTIFICATION_QUEUE_URL = aws_sqs_queue.notification.url
  }
}

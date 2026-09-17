module "user_service" {
  source = "../../modules/lambda"

  function_name       = "${var.project_name}-${var.environment}-user-service"
  handler             = "handler.lambda_handler"
  runtime             = "python3.12"
  source_dir          = "../../../services/user-service/src"
  dynamodb_table_name = aws_dynamodb_table.users.name
  dynamodb_table_arn  = aws_dynamodb_table.users.arn
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

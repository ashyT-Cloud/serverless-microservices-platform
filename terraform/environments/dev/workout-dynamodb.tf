resource "aws_dynamodb_table" "workouts" {
  name         = "${var.project_name}-${var.environment}-workouts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "workoutId"

  attribute {
    name = "workoutId"
    type = "S"
  }
}

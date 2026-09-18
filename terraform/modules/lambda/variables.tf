variable "function_name" {
  type = string
}

variable "handler" {
  type = string
}

variable "runtime" {
  type = string
}

variable "source_dir" {
  type = string
}

variable "dynamodb_table_name" {
  type    = string
  default = ""
}

variable "dynamodb_table_arn" {
  type    = string
  default = ""
}

variable "dynamodb_environment_variable" {
  type    = string
  default = "USERS_TABLE"
}

variable "event_bus_arn" {
  type    = string
  default = ""
}

variable "event_bus_name" {
  type    = string
  default = ""
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "enable_dynamodb_policy" {
  description = "Whether to attach DynamoDB permissions to the Lambda role"
  type        = bool
  default     = false
}

variable "enable_eventbridge_policy" {
  description = "Whether to attach EventBridge permissions to the Lambda role"
  type        = bool
  default     = false
}

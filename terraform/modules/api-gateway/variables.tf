variable "api_name" {
  type = string
}

variable "lambda_arn" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "routes" {
  type = list(string)
}

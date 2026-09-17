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

## lambda.tf variables
##
variable "lambda_file" {
  description = "lambda function file name"
  type        = string
  default     = "http-crud-function.mjs"
}

variable "lambda_max_concurrent_executions" {
  description = "Maximum concurrent function invocations"
  default     = "50"
}

## gateway.tf variables
##
variable "gw_burst_limit" {
  description = "burst limit of the API gateway; max concurrent requests"
  default     = "10"
}

variable "gw_rate_limit" {
  description = "rate limit of the API gateway; requests per second"
  default     = "100"
}

## dynamodb.tf variables
##
variable "dynamo_read_limits" {
  description = "maximum provisioned read units"
  default     = "8"
}

variable "dynamo_write_limits" {
  description = "maximum provisioned write units"
  default     = "4"
}

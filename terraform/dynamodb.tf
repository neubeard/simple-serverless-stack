resource "aws_dynamodb_table" "http-crud-dynamodb-table" {
  name           = "http-crud-items"
  billing_mode   = "PROVISIONED"
  read_capacity  = var.dynamo_read_limits
  write_capacity = var.dynamo_write_limits
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

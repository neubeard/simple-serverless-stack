data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "http-crud-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  path               = "/service-role/"
}

resource "aws_iam_role_policy_attachment" "lambda_policy_basic" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.policy.arn
}

data "aws_iam_policy_document" "lambda_basic" {
  statement {
    actions   = ["logs:CreateLogGroup"]
    resources = ["arn:aws:logs:us-east-2:810918113647:*"]
  }
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:us-east-2:810918113647:log-group:/aws/lambda/http-crud-function:*",
    ]
  }
}

resource "aws_iam_policy" "policy" {
  name   = "AWSLambdaBasicExecutionRoleCustom"
  policy = data.aws_iam_policy_document.lambda_basic.json
  path   = "/service-role/"
}

data "aws_iam_policy_document" "lambda_microservice" {
  statement {
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Scan",
      "dynamodb:UpdateItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:BatchGetItem"
    ]
    resources = ["arn:aws:dynamodb:us-east-2:810918113647:table/*"]
  }
}

resource "aws_iam_policy" "policy_microservice" {
  name   = "AWSLambdaMicroserviceExecutionRoleCustom"
  policy = data.aws_iam_policy_document.lambda_microservice.json
  path   = "/service-role/"
}

resource "aws_iam_role_policy_attachment" "lambda_policy_microservice" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.policy_microservice.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/files/${var.lambda_file}"
  output_path = "${path.module}/files/lambda_function_payload.zip"
}

resource "aws_lambda_function" "http-crud-function" {
  filename                       = "${path.module}/files/lambda_function_payload.zip"
  function_name                  = "http-crud-function"
  role                           = aws_iam_role.iam_for_lambda.arn
  handler                        = "${trimsuffix(var.lambda_file, ".mjs")}.handler"
  source_code_hash               = data.archive_file.lambda.output_base64sha256
  runtime                        = "nodejs20.x"
  timeout                        = "3"
  depends_on                     = [aws_cloudwatch_log_group.lambda_log]
#  reserved_concurrent_executions = var.lambda_max_concurrent_executions
}

resource "aws_cloudwatch_log_group" "lambda_log" {
  name              = "/aws/lambda/http-crud-function"
  log_group_class   = "STANDARD"
  retention_in_days = "0"
}

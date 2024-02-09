resource "aws_apigatewayv2_api" "http-crud-api" {
  name          = "http-crud-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http-crud-api.id
  name        = "$default"
  auto_deploy = false
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      ip                      = "$context.identity.sourceIp"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
  default_route_settings {
    detailed_metrics_enabled = true
    throttling_burst_limit   = var.gw_burst_limit
    throttling_rate_limit    = var.gw_rate_limit
  }

  depends_on = [aws_cloudwatch_log_group.api_gw]
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "blackbeard"
  log_group_class   = "STANDARD"
  retention_in_days = "0"
}

resource "aws_apigatewayv2_integration" "http-crud-function" {
  api_id                 = aws_apigatewayv2_api.http-crud-api.id
  integration_uri        = aws_lambda_function.http-crud-function.invoke_arn
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.http-crud-function.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http-crud-api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_route" "bulkitems-post" {
  api_id    = aws_apigatewayv2_api.http-crud-api.id
  route_key = "POST /bulkitems"
  target    = "integrations/${aws_apigatewayv2_integration.http-crud-function.id}"
}

resource "aws_apigatewayv2_route" "bulkitems-get" {
  api_id    = aws_apigatewayv2_api.http-crud-api.id
  route_key = "GET /bulkitems"
  target    = "integrations/${aws_apigatewayv2_integration.http-crud-function.id}"
}

resource "aws_apigatewayv2_route" "items-put" {
  api_id    = aws_apigatewayv2_api.http-crud-api.id
  route_key = "PUT /items"
  target    = "integrations/${aws_apigatewayv2_integration.http-crud-function.id}"
}

resource "aws_apigatewayv2_route" "items-get" {
  api_id    = aws_apigatewayv2_api.http-crud-api.id
  route_key = "GET /items"
  target    = "integrations/${aws_apigatewayv2_integration.http-crud-function.id}"
}

resource "aws_apigatewayv2_route" "item-id-get" {
  api_id    = aws_apigatewayv2_api.http-crud-api.id
  route_key = "GET /items/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.http-crud-function.id}"
}

resource "aws_apigatewayv2_route" "item-id-delete" {
  api_id    = aws_apigatewayv2_api.http-crud-api.id
  route_key = "DELETE /items/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.http-crud-function.id}"
}

resource "aws_apigatewayv2_api" "main" {
  name          = "cloudresume-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "visitor_counter" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.visitor_counter.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "visitors" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /visitors"
  target    = "integrations/${aws_apigatewayv2_integration.visitor_counter.id}"
}

resource "aws_apigatewayv2_route" "api_visitors" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /api/visitors"
  target    = "integrations/${aws_apigatewayv2_integration.visitor_counter.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigateway" {
  statement_id  = "apigateway-invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*/visitors"
}

resource "aws_lambda_permission" "apigateway_api_path" {
  statement_id  = "apigateway-invoke-api-path"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*/api/visitors"
}

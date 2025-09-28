resource "aws_lambda_function" "get_school_data" {
  function_name = "getSchoolData"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "get_school_data.lambda_handler"
  runtime       = "python3.12"
  filename      = "deployment_package.zip"
  source_code_hash = filebase64sha256("deployment_package.zip")
  timeout     = 90
  memory_size = 512

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.private_data_bucket.id
      S3_KEY    = var.geojson_file
    }
  }
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "MapDataAPI"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.get_school_data.invoke_arn
}

resource "aws_apigatewayv2_route" "get_schools" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /schools"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_school_data.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
data "archive_file" "visitor_counter" {
  type        = "zip"
  source_file = "${path.module}/../lambda/visitor-counter/lambda_function.py"
  output_path = "${path.module}/build/visitor-counter.zip"
}

resource "aws_lambda_function" "visitor_counter" {
  function_name = "cloudresume-visitor-counter"
  role          = aws_iam_role.visitor_counter.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.13"
  timeout       = 10
  memory_size   = 128

  filename         = data.archive_file.visitor_counter.output_path
  source_code_hash = data.archive_file.visitor_counter.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.visitors.name
    }
  }
}

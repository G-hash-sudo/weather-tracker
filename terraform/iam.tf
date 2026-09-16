data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "visitor_counter" {
  name               = "cloudresume-visitor-counter-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "visitor_counter_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:us-west-2:852155010068:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
    ]
    resources = [aws_dynamodb_table.visitors.arn]
  }
}

resource "aws_iam_role_policy" "visitor_counter" {
  name   = "visitor-counter-permissions"
  role   = aws_iam_role.visitor_counter.id
  policy = data.aws_iam_policy_document.visitor_counter_permissions.json
}

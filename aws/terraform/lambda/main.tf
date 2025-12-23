locals {
  prefix = "${var.project_name}-${var.environment}"
}

resource "aws_iam_role" "lambda_role" {
  name = "${local.prefix}-ingestion-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "s3_write_policy" {
  name = "${local.prefix}-s3-write"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject"]
      Resource = "arn:aws:s3:::${var.data_lake_bucket}/raw/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "ingestion" {
  function_name = "${local.prefix}-ingestion"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.11"

  filename         = "${path.module}/ingestion.zip"
  source_code_hash = filebase64sha256("${path.module}/ingestion.zip")

  environment {
    variables = {
      DATA_LAKE_BUCKET = var.data_lake_bucket
    }
  }
}
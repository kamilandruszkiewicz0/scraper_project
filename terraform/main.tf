provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "scraper_data" {
  bucket = var.s3_bucket_name
}

resource "aws_dynamodb_table" "scraper_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "scraper_lambda_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_policy"
  description = "IAM policy for Lambda execution"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:PutObject", "s3:GetObject"],
        Resource = ["${aws_s3_bucket.scraper_data.arn}/*"]
      },
      {
        Effect = "Allow",
        Action = ["dynamodb:PutItem", "dynamodb:GetItem"],
        Resource = ["${aws_dynamodb_table.scraper_table.arn}"]
      },
      {
        Effect = "Allow",
        Action = ["logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = ["arn:aws:logs:us-east-1:*:log-group:/aws/lambda/scraper_lambda:*"]
      },
      {
        Effect = "Allow",
        Action = ["lambda:InvokeFunction"],
        Resource = ["${aws_lambda_function.scraper_lambda.arn}"]
      }
    ]
  })
}

resource "aws_lambda_function" "scraper_lambda" {
  function_name = "scraper_lambda"
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_exec.arn

  filename = "lambda_function.zip"
  timeout  = 900  # Maksymalny czas działania Lambdy (15 minut)

  environment {
    variables = {
      S3_BUCKET      = aws_s3_bucket.scraper_data.id
      DYNAMODB_TABLE = aws_dynamodb_table.scraper_table.name
      LOG_LEVEL      = "INFO"
    }
  }
}

resource "aws_sqs_queue" "scraper_queue" {
  name                      = var.sqs_queue_name
  visibility_timeout_seconds = 300
}

resource "aws_iam_role" "step_function" {
  name = "step_function_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012.10.17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })
}

resource "aws_sfn_state_machine" "scraper_workflow" {
  name     = "ScraperWorkflow"
  role_arn = aws_iam_role.step_function.arn
  definition = file("step_functions/step_function.json")
}

resource "aws_api_gateway_rest_api" "scraper_api" {
  name        = "scraper-api"
  description = "API Gateway for triggering the scraper"
}

resource "aws_api_gateway_resource" "scraper_resource" {
  rest_api_id = aws_api_gateway_rest_api.scraper_api.id
  parent_id   = aws_api_gateway_rest_api.scraper_api.root_resource_id
  path_part   = "scrape"
}

resource "aws_api_gateway_method" "scraper_method" {
  rest_api_id   = aws_api_gateway_rest_api.scraper_api.id
  resource_id   = aws_api_gateway_resource.scraper_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "scraper_integration" {
  rest_api_id             = aws_api_gateway_rest_api.scraper_api.id
  resource_id             = aws_api_gateway_resource.scraper_resource.id
  http_method             = aws_api_gateway_method.scraper_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.scraper_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "scraper_deployment" {
  depends_on = [aws_api_gateway_integration.scraper_integration]
  rest_api_id = aws_api_gateway_rest_api.scraper_api.id
}

resource "aws_api_gateway_account" "api_logging" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_logging.arn
}

resource "aws_api_gateway_stage" "scraper_stage" {
  stage_name = "prod"
  rest_api_id = aws_api_gateway_rest_api.scraper_api.id
  deployment_id = aws_api_gateway_deployment.scraper_deployment.id
}

resource "aws_iam_role" "api_gateway_logging" {
  name = "api_gateway_logging_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "apigateway.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "api_gateway_execution_policy" {
  name = "api_gateway_execution_policy"
  description = "Restrict API Gateway to invoke only this Lambda function"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow", 
        Action = "lambda:InvokeFunction",
        Resource = ["${aws_lambda_function.scraper_lambda.arn}"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_execution_attachment" {
  role       = aws_iam_role.api_gateway_logging.name
  policy_arn = aws_iam_policy.api_gateway_execution_policy.arn
}

resource "aws_iam_policy" "restricted_api_gateway_logging" {
  name        = "restricted_api_gateway_logging"
  description = "Restrict API Gateway logging to only the API Gateway for this project"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = ["arn:aws:logs:us-east-1:*:log-group:/aws/api-gateway/scraper-api:*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "restricted_api_gateway_logging_attachment" {
  role       = aws_iam_role.api_gateway_logging.name
  policy_arn = aws_iam_policy.restricted_api_gateway_logging.arn
}

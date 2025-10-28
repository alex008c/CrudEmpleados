data "archive_file" "publisher_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../infra/lambdas/publisher_lambda"
  output_path = "${path.module}/../infra/lambdas/publisher_lambda.zip"
}

resource "aws_iam_role" "publisher_lambda_role" {
  name = "${var.project_name}-publisher-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-publisher-lambda-role"
  }
}

resource "aws_iam_policy" "publisher_lambda_policy" {
  name = "${var.project_name}-publisher-lambda-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.project_name}-publisher-lambda:*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.email_topic.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "publisher_lambda_policy_attach" {
  role       = aws_iam_role.publisher_lambda_role.name
  policy_arn = aws_iam_policy.publisher_lambda_policy.arn
}

resource "aws_lambda_function" "publisher_lambda" {
  filename         = data.archive_file.publisher_lambda_zip.output_path
  function_name    = "${var.project_name}-publisher-lambda"
  role             = aws_iam_role.publisher_lambda_role.arn
  handler          = "handler.lambda_handler"
  source_code_hash = data.archive_file.publisher_lambda_zip.output_base64sha256
  runtime          = "python3.11"
  timeout          = 30

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.email_topic.arn
      ENVIRONMENT   = var.environment
    }
  }

  tags = {
    Name = "${var.project_name}-publisher-lambda"
  }
}

resource "aws_cloudwatch_log_group" "publisher_lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-publisher-lambda"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-publisher-lambda-logs"
  }
}

resource "aws_api_gateway_rest_api" "email_api" {
  name        = "${var.project_name}-email-api"
  description = "API Gateway para envío de correos mediante SNS/SQS"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name = "${var.project_name}-email-api"
  }
}

resource "aws_api_gateway_resource" "publish" {
  rest_api_id = aws_api_gateway_rest_api.email_api.id
  parent_id   = aws_api_gateway_rest_api.email_api.root_resource_id
  path_part   = "publish"
}

resource "aws_api_gateway_method" "publish_post" {
  rest_api_id      = aws_api_gateway_rest_api.email_api.id
  resource_id      = aws_api_gateway_resource.publish.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "publish_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.email_api.id
  resource_id             = aws_api_gateway_resource.publish.id
  http_method             = aws_api_gateway_method.publish_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.publisher_lambda.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.publisher_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.email_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "email_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.email_api.id

  depends_on = [
    aws_api_gateway_integration.publish_lambda
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "email_api_stage" {
  deployment_id = aws_api_gateway_deployment.email_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.email_api.id
  stage_name    = var.environment
}

resource "aws_api_gateway_usage_plan" "email_api_usage_plan" {
  name = "${var.project_name}-email-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.email_api.id
    stage  = aws_api_gateway_stage.email_api_stage.stage_name
  }

  quota_settings {
    limit  = 10000
    period = "MONTH"
  }

  throttle_settings {
    burst_limit = 100
    rate_limit  = 50
  }
}

resource "aws_api_gateway_api_key" "email_api_key" {
  name    = "${var.project_name}-email-api-key"
  enabled = true
}

resource "aws_api_gateway_usage_plan_key" "email_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.email_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.email_api_usage_plan.id
}

output "email_api_url" {
  value       = "${aws_api_gateway_stage.email_api_stage.invoke_url}/publish"
  description = "URL del API Gateway para envío de correos"
}

output "email_api_key" {
  value       = aws_api_gateway_api_key.email_api_key.value
  description = "API Key para autenticación"
  sensitive   = true
}

output "sns_topic_arn" {
  value       = aws_sns_topic.email_topic.arn
  description = "ARN del SNS Topic"
}

output "sqs_queue_url" {
  value       = aws_sqs_queue.email_queue.url
  description = "URL de la cola SQS"
}

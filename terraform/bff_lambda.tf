# ========================================
# BFF LAMBDA FUNCTION
# ========================================
# Lambda del BFF que será invocada por el ALB
# Usa Mangum para adaptar FastAPI a Lambda

# 1. IAM Role para BFF Lambda
resource "aws_iam_role" "bff_lambda_role" {
  name = "${var.project_name}-bff-lambda-role"

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
    Name = "${var.project_name}-bff-lambda-role"
  }
}

# 2. IAM Policy para BFF Lambda
resource "aws_iam_policy" "bff_lambda_policy" {
  name = "${var.project_name}-bff-lambda-policy"

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
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.project_name}-bff-lambda:*"
      },
      {
        Effect = "Allow"
        Action = [
          "apigateway:POST"
        ]
        Resource = "*"
      }
    ]
  })
}

# 3. Attach Policy to Role
resource "aws_iam_role_policy_attachment" "bff_lambda_policy_attach" {
  role       = aws_iam_role.bff_lambda_role.name
  policy_arn = aws_iam_policy.bff_lambda_policy.arn
}

# 4. Empaquetar código del BFF
data "archive_file" "bff_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../bff"
  output_path = "${path.module}/../infra/lambdas/bff_lambda.zip"
  
  excludes = [
    "__pycache__",
    "*.pyc",
    ".pytest_cache",
    "start_bff.ps1"
  ]
}

# 5. Lambda Function del BFF (Versión proxy para ALB → API Gateway)
resource "aws_lambda_function" "bff_lambda" {
  filename         = "${path.module}/../bff/bff_proxy.zip"  # Handler proxy que conecta con API Gateway
  function_name    = "${var.project_name}-bff-lambda"
  role             = aws_iam_role.bff_lambda_role.arn
  handler          = "handler_proxy.handler"  # archivo.funcion
  source_code_hash = filebase64sha256("${path.module}/../bff/bff_proxy.zip")
  runtime          = "python3.11"
  timeout          = 30
  memory_size      = 512  # MB
  publish          = true  # Publicar versión para alias

  environment {
    variables = {
      ENVIRONMENT      = var.environment
      PUBLISH_API_URL  = aws_api_gateway_stage.email_api_stage.invoke_url
      PUBLISH_API_KEY  = aws_api_gateway_api_key.email_api_key.value
    }
  }

  tags = {
    Name = "${var.project_name}-bff-lambda"
  }
}

# 6. CloudWatch Log Group
resource "aws_cloudwatch_log_group" "bff_lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-bff-lambda"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-bff-lambda-logs"
  }
}

# 7. Lambda Alias para Provisioned Concurrency
resource "aws_lambda_alias" "bff_live" {
  name             = "live"
  description      = "Alias para versión en producción con provisioned concurrency"
  function_name    = aws_lambda_function.bff_lambda.function_name
  function_version = aws_lambda_function.bff_lambda.version
}

# 8. Outputs
output "bff_lambda_arn" {
  value       = aws_lambda_function.bff_lambda.arn
  description = "ARN de la Lambda del BFF"
}

output "bff_lambda_name" {
  value       = aws_lambda_function.bff_lambda.function_name
  description = "Nombre de la Lambda del BFF"
}

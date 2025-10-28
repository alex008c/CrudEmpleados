# Backend CRUD en AWS Lambda (sin Docker)
# Versión simplificada usando ZIP

# Empaquetar el código del backend
data "archive_file" "crud_backend_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../backend"
  output_path = "${path.module}/../infra/lambdas/crud_backend.zip"
  excludes    = ["__pycache__", "*.pyc", ".pytest_cache", "venv", "uploads"]
}

# IAM Role para el backend CRUD Lambda
resource "aws_iam_role" "crud_lambda_role" {
  name = "${var.project_name}-crud-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
      },
    ],
  })

  tags = {
    Name = "${var.project_name}-crud-lambda-role"
  }
}

# Policy para el backend CRUD Lambda
resource "aws_iam_policy" "crud_lambda_policy" {
  name = "${var.project_name}-crud-lambda-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "logs:CreateLogGroup",
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*",
      },
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.project_name}-crud-lambda:*",
      }
    ],
  })
}

resource "aws_iam_role_policy_attachment" "crud_lambda_policy_attach" {
  role       = aws_iam_role.crud_lambda_role.name
  policy_arn = aws_iam_policy.crud_lambda_policy.arn
}

# Lambda Function para backend CRUD
resource "aws_lambda_function" "crud_lambda" {
  function_name = "${var.project_name}-crud-lambda"
  filename      = data.archive_file.crud_backend_zip.output_path
  source_code_hash = data.archive_file.crud_backend_zip.output_base64sha256
  
  role    = aws_iam_role.crud_lambda_role.arn
  handler = "main.handler"
  runtime = "python3.11"
  
  timeout     = 30
  memory_size = 512

  environment {
    variables = {
      DATABASE_URL = var.external_db_url
    }
  }

  tags = {
    Name = "${var.project_name}-crud-lambda"
  }
}

# API Gateway HTTP API para el backend CRUD
resource "aws_apigatewayv2_api" "crud_api_gw" {
  name          = "${var.project_name}-crud-api-gw"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["*"]
    max_age       = 300
  }

  tags = {
    Name = "${var.project_name}-crud-api-gw"
  }
}

# Integración Lambda
resource "aws_apigatewayv2_integration" "crud_lambda_integration" {
  api_id           = aws_apigatewayv2_api.crud_api_gw.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.crud_lambda.invoke_arn
  timeout_milliseconds = 29000
}

# Ruta comodín
resource "aws_apigatewayv2_route" "crud_proxy_route" {
  api_id    = aws_apigatewayv2_api.crud_api_gw.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.crud_lambda_integration.id}"
}

# Stage
resource "aws_apigatewayv2_stage" "crud_default_stage" {
  api_id      = aws_apigatewayv2_api.crud_api_gw.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Name = "${var.project_name}-crud-api-stage"
  }
}

# Permiso para API Gateway invocar Lambda
resource "aws_lambda_permission" "crud_api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvokeCRUD"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crud_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.crud_api_gw.execution_arn}/*"
}

# Output de la URL del API Gateway CRUD
output "crud_api_gateway_url" {
  description = "La URL del API Gateway para el servicio CRUD"
  value       = aws_apigatewayv2_stage.crud_default_stage.invoke_url
}

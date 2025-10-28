resource "docker_image" "crud_backend_image"{
  name = "${aws_ecr_repository.crud_backend_repo.aws_ecr_repository_url}:lastest"

  build {
    context = "../backend"
    dockerile = "dockerfile"
    platorm = "linux/amd64"
  }
  keep_locally = false
}

resource "docker_registry_image" "crud_backend_registry_image" {
  name = docker_image.crud_backend_image.name

  depends_on = [docker_image.crud_backend_image]
}


resource "aws_ecr_repository" "crud_backend_repo" {
  name                 = "${var.project_name}-backend-repo"
  image_tag_mutability = "MUTABLE" 

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true

  tags = {
    Name = "${var.project_name}-backend-repo"
  }
}


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

resource "aws_iam_policy" "crud_lambda_policy" {
  name = "${var.project_name}-crud-lambda-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Permisos básicos para escribir logs en CloudWatch
      {
        Effect   = "Allow",
        Action   = "logs:CreateLogGroup",
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*",
      },
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.project_name}-crud-lambda:*",
      },
      # Permisos necesarios para que la Lambda opere dentro de la VPC
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ],
        Resource = "*"
      }
    ],
  })
}

resource "aws_iam_role_policy_attachment" "crud_lambda_policy_attach" {
  role       = aws_iam_role.crud_lambda_role.name
  policy_arn = aws_iam_policy.crud_lambda_policy.arn
}

# Obtiene el ID de la cuenta AWS actual
data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "crud_lambda" {
  function_name = "${var.project_name}-crud-lambda"

  package_type = "Image"
  image_uri    = docker_registry_image.crud_backend_registry_image.name

  role = aws_iam_role.crud_lambda_role.arn

  timeout     = 30
  memory_size = 512

  environment {
    variables = {
      DATABASE_URL = var.external_db_url
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_group_ids = [aws_security_group.main_sg.id]
  }

  depends_on = [
    docker_registry_image.crud_backend_registry_image,
    aws_iam_role_policy_attachment.crud_lambda_policy_attach,
    aws_internet_gateway.main_igw,
    aws_route_table_association.public_a_assoc,
    aws_route_table_association.public_b_assoc
  ]

  tags = {
    Name = "${var.project_name}-crud-lambda"
  }
}

resource "aws_apigatewayv2_api" "crud_api_gw" {
  name          = "${var.project_name}-crud-api-gw"
  protocol_type = "HTTP"

  # Configuración CORS (Cross-Origin Resource Sharing)
  # Permite que tu frontend (Flutter Web/App) alojado en otro dominio llame a esta API
  cors_configuration {
    allow_origins = ["*"] # Permite cualquier origen (¡restringir en producción!)
    allow_methods = ["*"] # Permite GET, POST, PUT, DELETE, OPTIONS, etc.
    allow_headers = ["*"] # Permite encabezados como Content-Type, Authorization, x-api-key
    max_age       = 300   # Tiempo que el navegador cachea la respuesta OPTIONS
  }

  tags = {
    Name = "${var.project_name}-crud-api-gw"
  }
}

resource "aws_apigatewayv2_integration" "crud_lambda_integration" {
  api_id           = aws_apigatewayv2_api.crud_api_gw.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.crud_lambda.invoke_arn
  timeout_milliseconds = 29000

resource "aws_apigatewayv2_route" "crud_proxy_route" {
  api_id    = aws_apigatewayv2_api.crud_api_gw.id
  route_key = "$default" # Ruta especial que actúa como comodín
  target    = "integrations/${aws_apigatewayv2_integration.crud_lambda_integration.id}"

  api_key_required = true
}

resource "aws_api_key" "main_api_key" {
  name  = "${var.project_name}-bff-key"
  value = var.api_key_value # Usa el valor secreto pasado como variable

  tags = {
    Name = "${var.project_name}-bff-key"
  }
}

resource "aws_apigateway_usage_plan" "main_usage_plan" {
  name = "${var.project_name}-bff-usage-plan"

  api_stages {
    api_id = aws_apigatewayv2_api.crud_api_gw.id
    stage  = aws_apigatewayv2_stage.crud_default_stage.name
  }

  tags = {
    Name = "${var.project_name}-bff-usage-plan"
  }
}

resource "aws_api_gateway_usage_plan_key" "main_usage_plan_key" {
  key_id        = aws_api_key.main_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_apigateway_usage_plan.main_usage_plan.id
}


resource "aws_apigatewayv2_stage" "crud_default_stage" {
  api_id      = aws_apigatewayv2_api.crud_api_gw.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Name = "${var.project_name}-crud-api-stage"
  }
}


output "crud_api_gateway_url" {
  description = "La URL del API Gateway para el servicio CRUD (protegido por API Key)"
  value       = replace(aws_apigatewayv2_stage.crud_default_stage.invoke_url, "/\\$default$/", "")
}

output "api_key_id_output" {
  description = "El ID de la API Key creada (NO el valor secreto)"
  value       = aws_api_key.main_api_key.id
}
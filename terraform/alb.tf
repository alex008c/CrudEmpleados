# ========================================
# APPLICATION LOAD BALANCER (ALB)
# ========================================
# El ALB distribuye el tráfico entre múltiples destinos (Lambdas)
# Conceptos clave:
# - Listener: Escucha en un puerto (80) y reenvía tráfico
# - Target Group: Grupo de destinos (nuestras Lambdas)
# - Health Check: Verifica que los destinos estén saludables

# 1. S3 Bucket para Access Logs del ALB
resource "aws_s3_bucket" "alb_logs" {
  bucket = "${var.project_name}-alb-logs-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "${var.project_name}-alb-logs"
    Environment = var.environment
  }
}

# 2. Política del bucket - Permite al ALB escribir logs
resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      },
      {
        Sid    = "AWSLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.alb_logs.arn
      },
      {
        Sid    = "AWSLogDeliveryWrite2"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::127311923021:root"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      }
    ]
  })
}

# 3. Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false  # false = accesible desde Internet
  load_balancer_type = "application"  # ALB (vs NLB o CLB)
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  # Habilitar logs de acceso - Deshabilitado temporalmente por permisos
  # access_logs {
  #   bucket  = aws_s3_bucket.alb_logs.id
  #   enabled = true
  # }

  # Protección contra eliminación accidental
  enable_deletion_protection = false  # true en producción

  tags = {
    Name        = "${var.project_name}-alb"
    Environment = var.environment
  }
}

# 4. Target Group - Apunta a Lambda (BFF)
resource "aws_lb_target_group" "lambda_bff" {
  name        = "${var.project_name}-lambda-bff-tg"
  target_type = "lambda"  # Importante: Lambda como destino

  # Health Check - Para Lambda no se usa protocol
  health_check {
    enabled             = true
    interval            = 35  # Cada 35 segundos (debe ser mayor a timeout de Lambda)
    timeout             = 30  # Timeout de 30 segundos (debe coincidir con timeout de Lambda)
    healthy_threshold   = 2  # 2 checks exitosos = saludable
    unhealthy_threshold = 2  # 2 checks fallidos = no saludable
    matcher             = "200"  # Código HTTP esperado
  }

  tags = {
    Name = "${var.project_name}-lambda-bff-tg"
  }
}

# 5. Permiso para que ALB invoque la Lambda
resource "aws_lambda_permission" "alb_invoke" {
  statement_id  = "AllowALBInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bff_lambda.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.lambda_bff.arn
}

# 6. Registrar Lambda en el Target Group
resource "aws_lb_target_group_attachment" "lambda_bff" {
  target_group_arn = aws_lb_target_group.lambda_bff.arn
  target_id        = aws_lambda_function.bff_lambda.arn
  depends_on       = [aws_lambda_permission.alb_invoke]
}

# 7. Listener HTTP - Escucha en puerto 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  # Acción: Reenviar al Target Group
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lambda_bff.arn
  }

  tags = {
    Name = "${var.project_name}-http-listener"
  }
}

# 8. Outputs
output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "DNS del ALB para acceder desde Internet"
}

output "alb_arn" {
  value       = aws_lb.main.arn
  description = "ARN del ALB"
}

output "target_group_arn" {
  value       = aws_lb_target_group.lambda_bff.arn
  description = "ARN del Target Group"
}

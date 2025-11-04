# ========================================
# AUTO SCALING PARA LAMBDA (SIMPLIFICADO)
# ========================================
# Lambda escala automáticamente sin necesidad de configuración explícita
# debido a limitaciones de concurrencia provisionada en la cuenta AWS
#
# Comportamiento por defecto de Lambda:
# - Escala automáticamente desde 0 hasta 1000 instancias concurrentes
# - Crea nuevas instancias cuando hay peticiones concurrentes
# - Reutiliza instancias disponibles (warm starts)
# - Elimina instancias inactivas después de ~15 minutos
#
# El ALB distribuye el tráfico entre las instancias que Lambda crea automáticamente

# CloudWatch Alarm - Errores Lambda
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Alerta cuando hay más de 10 errores en Lambda"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.bff_lambda.function_name
  }

  tags = {
    Name = "${var.project_name}-lambda-errors-alarm"
  }
}

# CloudWatch Alarm - Alta Concurrencia
resource "aws_cloudwatch_metric_alarm" "lambda_high_concurrency" {
  alarm_name          = "${var.project_name}-lambda-high-concurrency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ConcurrentExecutions"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Maximum"
  threshold           = 50
  alarm_description   = "Alerta cuando hay más de 50 ejecuciones concurrentes"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.bff_lambda.function_name
  }

  tags = {
    Name = "${var.project_name}-lambda-concurrency-alarm"
  }
}

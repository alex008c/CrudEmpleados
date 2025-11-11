# ==============================================================================
# EventBridge Scheduler para Lambda de Email
# Ejecuta automáticamente la Lambda cada cierto intervalo de tiempo
# ==============================================================================

# Regla de EventBridge que se dispara automáticamente
# Se ejecuta cada 5 minutos (puedes cambiar el schedule_expression)
resource "aws_cloudwatch_event_rule" "email_scheduler" {
  name                = "${var.project_name}-email-scheduler"
  description         = "Ejecuta la Lambda de email automáticamente cada cierto tiempo"
  schedule_expression = "rate(5 minutes)" # Opciones: rate(5 minutes), rate(1 hour), cron(0 12 * * ? *)

  tags = {
    Name        = "${var.project_name}-email-scheduler"
    Environment = var.environment
    Purpose     = "Automated Email Sending"
  }
}

# Target: Especifica que la Lambda de email debe ejecutarse cuando la regla se dispare
resource "aws_cloudwatch_event_target" "email_lambda_target" {
  rule      = aws_cloudwatch_event_rule.email_scheduler.name
  target_id = "EmailLambdaTarget"
  arn       = aws_lambda_function.email_lambda.arn

  # Payload que se enviará a la Lambda
  # La Lambda de email espera un evento con estructura de SQS Records
  input = jsonencode({
    Records = [
      {
        body = jsonencode({
          Message = jsonencode({
            to      = "alexfrank.af04@gmail.com"
            subject = "Correo Automatizado - EventBridge"
            body    = "Este correo fue enviado automáticamente por EventBridge cada 5 minutos. Timestamp: $${timestamp()}"
          })
        })
      }
    ]
  })
}

# Permiso para que EventBridge pueda invocar la Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.email_scheduler.arn
}

# ==============================================================================
# Outputs para verificación
# ==============================================================================

output "eventbridge_rule_name" {
  description = "Nombre de la regla de EventBridge"
  value       = aws_cloudwatch_event_rule.email_scheduler.name
}

output "eventbridge_rule_arn" {
  description = "ARN de la regla de EventBridge"
  value       = aws_cloudwatch_event_rule.email_scheduler.arn
}

output "eventbridge_schedule" {
  description = "Expresión de schedule configurada"
  value       = aws_cloudwatch_event_rule.email_scheduler.schedule_expression
}

# ==============================================================================
# Documentación del Schedule Expression
# ==============================================================================

# OPCIONES DE SCHEDULE:
#
# Rate expressions (intervalo fijo):
#   - rate(5 minutes)   → Cada 5 minutos
#   - rate(1 hour)      → Cada hora
#   - rate(1 day)       → Cada día
#
# Cron expressions (horarios específicos):
#   - cron(0 12 * * ? *)        → Todos los días a las 12:00 PM UTC
#   - cron(0 9 ? * MON-FRI *)   → Lunes a viernes a las 9:00 AM UTC
#   - cron(0/15 * * * ? *)      → Cada 15 minutos
#
# Formato cron: cron(minutos horas día mes día-semana año)
# * = cualquier valor
# ? = sin valor específico (usado en día o día-semana)
#
# ==============================================================================
# Flujo completo:
# ==============================================================================
#
# EventBridge (cada 5 min) → Lambda Email → SES → Correo enviado
#
# Este flujo es PARALELO y ASÍNCRONO:
# - EventBridge dispara múltiples ejecuciones en paralelo si es necesario
# - Lambda escala automáticamente según la demanda
# - No requiere intervención manual
# - Logs en CloudWatch: /aws/lambda/crud-app-email-lambda
#
# ==============================================================================

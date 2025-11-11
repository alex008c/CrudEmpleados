# 💰 ANÁLISIS DE COSTOS AWS - CrudEmpleados

## 📊 RECURSOS IDENTIFICADOS EN TU CUENTA

### ✅ RECURSOS CON COSTO SIGNIFICATIVO (DESACTIVAR)

#### 1. **Application Load Balancer (ALB)** 💸💸💸
- **Archivo**: `alb.tf`
- **Costo**: ~$16-20/mes (24/7 aunque no reciba tráfico)
- **¿Se puede eliminar?**: ✅ **SÍ**
- **¿Afecta EventBridge?**: ❌ **NO**
- **Razón**: ALB solo se usa para el BFF Lambda (flujo manual), EventBridge invoca Lambda directamente

**Componentes del ALB**:
- `aws_lb.main` - Load Balancer principal ($16/mes)
- `aws_lb_target_group.lambda_bff` - Target group (gratis pero requiere ALB)
- `aws_lb_listener.http` - Listener puerto 80 (gratis pero requiere ALB)
- `aws_s3_bucket.alb_logs` - Bucket para logs ($0.023/GB - mínimo)

---

#### 2. **SNS Topic** 💸
- **Archivo**: `messaging.tf`
- **Recurso**: `aws_sns_topic.email_topic`
- **Costo**: $0.50 por millón de publicaciones
- **¿Se puede eliminar?**: ✅ **SÍ**
- **¿Afecta EventBridge?**: ❌ **NO**
- **Razón**: EventBridge → Lambda (directo), no necesita SNS

---

#### 3. **SQS Queues** 💸
- **Archivo**: `messaging.tf`
- **Recursos**: 
  - `aws_sqs_queue.email_queue` (cola principal)
  - `aws_sqs_queue.email_dlq` (dead letter queue)
- **Costo**: $0.40-0.76 por millón de peticiones + $0.0004 por 10k mensajes retenidos
- **¿Se puede eliminar?**: ✅ **SÍ**
- **¿Afecta EventBridge?**: ❌ **NO**
- **Razón**: EventBridge no usa colas, invoca Lambda directamente

---

### ✅ RECURSOS GRATUITOS O MÍNIMOS (MANTENER)

#### 4. **Lambda Functions** (FREE TIER) 🆓
- **Recursos**:
  - `aws_lambda_function.email_lambda` (envía correos)
  - `aws_lambda_function.bff_lambda` (BFF para frontend)
- **Costo**: 
  - **1 millón de peticiones GRATIS/mes**
  - **400,000 GB-segundos GRATIS/mes**
  - Después: $0.20 por millón + $0.0000166667 por GB-segundo
- **¿Se puede eliminar?**: ❌ **NO** (necesaria para EventBridge)
- **Costo real con tu uso**: $0.00 (dentro del free tier)

---

#### 5. **EventBridge Rule** 🆓
- **Archivo**: `eventbridge_scheduler.tf`
- **Recurso**: `aws_cloudwatch_event_rule.email_scheduler`
- **Costo**: **14 millones de eventos GRATIS/mes**
- **¿Se puede eliminar?**: ❌ **NO** (es lo que queremos demostrar)
- **Costo real**: $0.00 (dentro del free tier)
- **Ejecuciones**: 8,640 por mes (cada 5 min × 24h × 30 días)

---

#### 6. **CloudWatch Logs** 🆓
- **Recursos**:
  - `/aws/lambda/crud-app-email-lambda`
  - `/aws/lambda/crud-app-bff-lambda`
- **Costo**: 
  - **5 GB ingesta GRATIS/mes**
  - Retención: 7 días (configurado en `messaging.tf`)
- **Costo real**: $0.00 (logs mínimos)

---

#### 7. **IAM Roles y Policies** 🆓
- **Recursos**: 
  - `aws_iam_role.email_lambda_role`
  - `aws_iam_policy.email_lambda_policy`
- **Costo**: **$0.00** (IAM es gratis)

---

#### 8. **API Gateway** 💸
- **Archivo**: `api_gateway_email.tf`
- **Costo**: $3.50 por millón de peticiones (después de 1 millón gratis el primer año)
- **¿Se puede eliminar?**: ⚠️ **DEPENDE**
- **¿Afecta EventBridge?**: ❌ **NO**
- **Razón**: Solo se usa para enviar emails desde el frontend manualmente

---

#### 9. **CloudWatch Alarms** 💸
- **Archivo**: `autoscaling.tf`, `monitoring.tf`
- **Costo**: $0.10 por alarma/mes (primeras 10 GRATIS)
- **¿Se puede eliminar?**: ✅ **SÍ** (opcional, solo para monitoreo)

---

## 🔥 RESUMEN DE COSTOS MENSUALES

### ANTES (Todo activo):
```
ALB                      : $16-20/mes  💸💸💸
SNS Topic                : $0.50/mes   💸
SQS Queues               : $0.40-1.00  💸
API Gateway              : $0-3.50     💸 (después de free tier)
CloudWatch Alarms        : $0.00       🆓 (primeras 10)
Lambda (email + BFF)     : $0.00       🆓 (dentro free tier)
EventBridge              : $0.00       🆓 (dentro free tier)
CloudWatch Logs          : $0.00       🆓 (dentro free tier)
IAM                      : $0.00       🆓
S3 (logs)                : ~$0.05      💸

TOTAL: ~$17-25/mes
```

### DESPUÉS (Solo EventBridge + Lambda):
```
Lambda (email)           : $0.00       🆓
EventBridge              : $0.00       🆓
CloudWatch Logs          : $0.00       🆓
IAM                      : $0.00       🆓

TOTAL: $0.00/mes 🎉
```

**AHORRO: ~$17-25/mes** ($204-300/año)

---

## 🎯 QUÉ HICIMOS CON EVENTBRIDGE

### ANTES (Tarea 1 - Flujo Manual):
```
Frontend Flutter
    ↓ (click botón)
BFF Lambda (puerto 8001)
    ↓ POST
API Gateway
    ↓ invoca
Publisher Lambda
    ↓ publica
SNS Topic
    ↓ notifica
SQS Queue
    ↓ trigger
Email Lambda
    ↓ envía
Amazon SES → ✉️ Correo enviado
```
**Problema**: Requiere intervención manual (click), usa muchos servicios (costoso)

---

### AHORA (Tarea 2 - Automatización con EventBridge):
```
EventBridge Rule
    schedule_expression = "rate(5 minutes)"
    ↓ (automático cada 5 min)
Email Lambda
    ↓ envía
Amazon SES → ✉️ Correo enviado
```

**Ventajas**:
1. ✅ **Automático**: No requiere intervención manual
2. ✅ **Paralelo**: Lambda escala automáticamente (hasta 1000 instancias concurrentes)
3. ✅ **Asíncrono**: EventBridge dispara y no espera respuesta ("fire and forget")
4. ✅ **Económico**: Solo usa 2 servicios (EventBridge + Lambda), ambos con free tier generoso
5. ✅ **Infraestructura como Código**: Todo en `eventbridge_scheduler.tf`

---

## 📝 LO QUE CONFIGURAMOS EN EVENTBRIDGE

### Archivo: `eventbridge_scheduler.tf`

```hcl
# REGLA: Ejecutar cada 5 minutos
resource "aws_cloudwatch_event_rule" "email_scheduler" {
  name                = "crud-app-email-scheduler"
  description         = "Ejecuta Lambda de email cada 5 minutos"
  schedule_expression = "rate(5 minutes)"  # ← AUTOMÁTICO
  state               = "ENABLED"
}

# TARGET: Qué Lambda ejecutar
resource "aws_cloudwatch_event_target" "email_lambda_target" {
  rule      = aws_cloudwatch_event_rule.email_scheduler.name
  target_id = "EmailLambdaTarget"
  arn       = aws_lambda_function.email_lambda.arn
  
  # Payload: Simula SQS Records para compatibilidad
  input = jsonencode({
    Records = [{
      body = jsonencode({
        to      = "alexfrank.af04@gmail.com"
        subject = "Correo Automatizado - EventBridge"
        body    = "Este correo fue enviado automáticamente cada 5 minutos por EventBridge."
      })
    }]
  })
}

# PERMISO: EventBridge puede invocar Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.email_scheduler.arn
}
```

---

## 🗑️ RECURSOS A ELIMINAR (NO AFECTAN EVENTBRIDGE)

### Prioridad 1: ALB (Mayor ahorro - $16-20/mes)
```bash
aws_lb.main
aws_lb_target_group.lambda_bff
aws_lb_listener.http
aws_s3_bucket.alb_logs
aws_lb_target_group_attachment.lambda_bff
aws_lambda_permission.alb_invoke
```

### Prioridad 2: SNS/SQS (Ahorro $0.90-1.50/mes)
```bash
aws_sns_topic.email_topic
aws_sns_topic_subscription.email_sqs_subscription
aws_sqs_queue.email_queue
aws_sqs_queue.email_dlq
aws_sqs_queue_policy.email_queue_policy
aws_lambda_event_source_mapping.email_sqs_trigger
```

### Prioridad 3: API Gateway (Ahorro $3.50/mes después de free tier)
```bash
aws_api_gateway_rest_api.email_api
aws_api_gateway_deployment.email_api_deployment
...
```

### Opcional: CloudWatch Alarms (Sin costo si tienes <10)
```bash
aws_cloudwatch_metric_alarm.lambda_errors
aws_cloudwatch_metric_alarm.lambda_high_concurrency
```

---

## ⚠️ RECURSOS QUE **NO** DEBES ELIMINAR

❌ **NO ELIMINAR**:
- `aws_lambda_function.email_lambda` (EventBridge la necesita)
- `aws_cloudwatch_event_rule.email_scheduler` (es la automatización)
- `aws_cloudwatch_event_target.email_lambda_target` (conecta EventBridge con Lambda)
- `aws_lambda_permission.allow_eventbridge` (permiso necesario)
- `aws_iam_role.email_lambda_role` (Lambda necesita rol)
- `aws_cloudwatch_log_group.email_lambda_logs` (para debugging)

---

## 🎓 CONCEPTOS CLAVE (Para tu presentación)

### 1. **Paralelismo**
> "Lambda escala automáticamente. Si EventBridge dispara 100 eventos simultáneos, AWS crea 100 instancias de Lambda en paralelo sin configuración adicional."

### 2. **Asincronía**
> "EventBridge dispara la Lambda y NO espera respuesta. Es 'fire and forget'. Esto permite procesamiento en background eficiente."

### 3. **Automatización**
> "Una vez desplegado con Terraform (`eventbridge_scheduler.tf`), el sistema funciona solo. Cero intervención manual. La infraestructura está versionada como código."

### 4. **Serverless**
> "No gestionamos servidores. AWS se encarga de escalado, disponibilidad, parches. Solo pagamos por ejecuciones (y con free tier: $0)."

---

## 🚀 FLUJO COMPLETO DE EVENTBRIDGE

```
1. EventBridge Rule (cada 5 minutos)
   - Configurado en: eventbridge_scheduler.tf línea 12
   - schedule_expression = "rate(5 minutes)"
   ↓

2. Target: Email Lambda
   - Configurado en: eventbridge_scheduler.tf línea 24
   - arn = aws_lambda_function.email_lambda.arn
   ↓

3. Lambda Execution (paralelo, asíncrono)
   - Código en: infra/lambdas/email_lambda/handler.py
   - Lee payload de EventBridge
   ↓

4. Amazon SES
   - Lambda invoca SES API
   - SES envía correo real
   ↓

5. Correo recibido ✉️
   - Destino: alexfrank.af04@gmail.com
   - Asunto: "Correo Automatizado - EventBridge"
```

---

## 📊 EVIDENCIA DE AUTOMATIZACIÓN

### CloudWatch Logs
```
/aws/lambda/crud-app-email-lambda

Timestamps (cada 5 minutos):
2025-11-07 10:00:00 - ENVIANDO CORREO REAL CON AMAZON SES
2025-11-07 10:05:00 - ENVIANDO CORREO REAL CON AMAZON SES
2025-11-07 10:10:00 - ENVIANDO CORREO REAL CON AMAZON SES
```

### EventBridge Console
```
Rule: crud-app-email-scheduler
State: ENABLED
Schedule: rate(5 minutes)
Targets: 1 (crud-app-email-lambda)
Invocations: ~8,640/mes
```

---

## 💡 RESUMEN EJECUTIVO

### ¿Qué automatizamos?
**Envío de correos electrónicos cada 5 minutos sin intervención manual.**

### ¿Cómo?
**EventBridge Rule con `schedule_expression = "rate(5 minutes)"` dispara Lambda automáticamente.**

### ¿Por qué es mejor que un servidor tradicional?
1. **Sin gestión de servidores**: AWS se encarga de todo
2. **Escala automático**: De 0 a 1000 instancias según demanda
3. **Pago por uso**: $0.00 con free tier (vs $5-10/mes servidor mínimo)
4. **Alta disponibilidad**: Multi-AZ automático
5. **Infraestructura como código**: Replicable en segundos

### ¿Cuánto ahorramos eliminando lo innecesario?
**$17-25/mes → $0/mes** (100% ahorro manteniendo funcionalidad EventBridge)

---

**Siguiente paso**: Ejecutar `COMANDOS_ELIMINACION_AWS.ps1` para limpiar recursos con costo.

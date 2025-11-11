# 🚀 GUÍA: EventBridge + Lambda Automatizada

## 📋 Resumen de la Implementación

Se ha creado una configuración de Terraform (`terraform/eventbridge_scheduler.tf`) que automatiza el envío de correos usando EventBridge.

## 🏗️ Arquitectura

```
EventBridge Rule (cada 5 min)
    ↓
Lambda Email
    ↓
Amazon SES
    ↓
Correo enviado a alexfrank.af04@gmail.com
```

### Componentes creados:

1. **aws_cloudwatch_event_rule** - Regla que se dispara cada 5 minutos
2. **aws_cloudwatch_event_target** - Conecta la regla con la Lambda
3. **aws_lambda_permission** - Permite que EventBridge invoque la Lambda

## ⚙️ Configuración Actual

- **Schedule**: `rate(5 minutes)` → Cada 5 minutos
- **Destinatario**: alexfrank.af04@gmail.com
- **Asunto**: "Correo Automatizado - EventBridge"
- **Cuerpo**: Incluye timestamp de envío

## 🛠️ Cómo Desplegar

### Paso 1: Navegar a la carpeta de Terraform

```powershell
cd terraform
```

### Paso 2: Inicializar Terraform (si no lo has hecho)

```powershell
terraform init
```

### Paso 3: Validar la configuración

```powershell
terraform validate
```

### Paso 4: Ver qué recursos se crearán

```powershell
terraform plan
```

Deberías ver:
- `aws_cloudwatch_event_rule.email_scheduler` (will be created)
- `aws_cloudwatch_event_target.email_lambda_target` (will be created)
- `aws_lambda_permission.allow_eventbridge` (will be created)

### Paso 5: Aplicar los cambios

```powershell
terraform apply
```

Escribe `yes` cuando te lo pida.

### Paso 6: Verificar outputs

Terraform mostrará:
```
eventbridge_rule_name = "crud-app-email-scheduler"
eventbridge_rule_arn = "arn:aws:events:us-east-1:..."
eventbridge_schedule = "rate(5 minutes)"
```

## ✅ Verificación

### Opción 1: AWS Console

1. **EventBridge**:
   - Ve a: https://console.aws.amazon.com/events/
   - Busca la regla: `crud-app-email-scheduler`
   - Verifica que esté "Enabled"

2. **CloudWatch Logs**:
   - Ve a: https://console.aws.amazon.com/cloudwatch/
   - Log Group: `/aws/lambda/crud-app-email-lambda`
   - Deberías ver ejecuciones cada 5 minutos

3. **Email**:
   - Revisa la bandeja de entrada de: alexfrank.af04@gmail.com
   - Deberías recibir correos cada 5 minutos

### Opción 2: AWS CLI

```powershell
# Ver la regla creada
aws events list-rules --region us-east-1 --name-prefix crud-app

# Ver targets de la regla
aws events list-targets-by-rule --rule crud-app-email-scheduler --region us-east-1

# Ver logs recientes
aws logs tail /aws/lambda/crud-app-email-lambda --region us-east-1 --follow
```

## 🎨 Personalización

### Cambiar el intervalo de tiempo

Edita `terraform/eventbridge_scheduler.tf` línea 12:

```hcl
schedule_expression = "rate(5 minutes)"
```

**Opciones disponibles:**

```hcl
# Cada X minutos/horas/días
rate(5 minutes)    # Cada 5 minutos
rate(1 hour)       # Cada hora
rate(2 hours)      # Cada 2 horas
rate(1 day)        # Cada día

# Horarios específicos (cron)
cron(0 12 * * ? *)        # Todos los días a las 12:00 PM UTC
cron(0 9 ? * MON-FRI *)   # Lunes a viernes a las 9:00 AM UTC
cron(0/15 * * * ? *)      # Cada 15 minutos
cron(0 0 * * ? *)         # Medianoche todos los días
```

Después de cambiar, ejecuta:
```powershell
terraform apply
```

### Cambiar el destinatario o contenido

Edita `terraform/eventbridge_scheduler.tf` líneas 25-34 (sección `input`):

```hcl
input = jsonencode({
  Records = [
    {
      body = jsonencode({
        Message = jsonencode({
          to      = "nuevo-email@example.com"  # ← Cambiar aquí
          subject = "Nuevo Asunto"              # ← Cambiar aquí
          body    = "Nuevo contenido"           # ← Cambiar aquí
        })
      })
    }
  ]
})
```

Después ejecuta: `terraform apply`

## 🛑 Cómo Detener el Envío Automático

### Opción 1: Deshabilitar la regla (temporal)

```powershell
aws events disable-rule --name crud-app-email-scheduler --region us-east-1
```

Para volver a habilitar:
```powershell
aws events enable-rule --name crud-app-email-scheduler --region us-east-1
```

### Opción 2: Destruir los recursos (permanente)

```powershell
cd terraform
terraform destroy -target=aws_cloudwatch_event_rule.email_scheduler
terraform destroy -target=aws_cloudwatch_event_target.email_lambda_target
terraform destroy -target=aws_lambda_permission.allow_eventbridge
```

O destruir todo:
```powershell
terraform destroy
```

## 📊 Conceptos Demostrados

### 1. **Paralelismo**
- EventBridge puede disparar múltiples Lambdas simultáneamente
- Lambda escala automáticamente (hasta 1000 ejecuciones concurrentes)

### 2. **Asincronía**
- EventBridge dispara la Lambda sin esperar respuesta
- Lambda procesa en background
- No hay bloqueo de recursos

### 3. **Automatización**
- Sin intervención manual después del despliegue
- Infraestructura como código (Terraform)
- Ejecución basada en schedule

## 🎓 Para la Presentación

**Flujo a mostrar:**

1. Mostrar `terraform/eventbridge_scheduler.tf`
2. Ejecutar `terraform plan` y `terraform apply`
3. Ir a AWS Console → EventBridge → Ver regla activa
4. Esperar 5 minutos y mostrar CloudWatch Logs
5. Mostrar email recibido
6. Explicar conceptos de paralelismo y automatización

**Puntos clave:**

- "EventBridge actúa como scheduler serverless"
- "Lambda se ejecuta automáticamente sin intervención manual"
- "Arquitectura event-driven completamente escalable"
- "Infraestructura definida como código con Terraform"

## 🐛 Troubleshooting

### La Lambda no se ejecuta

1. Verificar que la regla esté habilitada:
   ```powershell
   aws events describe-rule --name crud-app-email-scheduler --region us-east-1
   ```

2. Verificar permisos:
   ```powershell
   aws lambda get-policy --function-name crud-app-email-lambda --region us-east-1
   ```

3. Ver errores en CloudWatch Logs

### No llegan correos

1. Verificar que el email esté verificado en SES:
   ```powershell
   aws ses list-verified-email-addresses --region us-east-1
   ```

2. Verificar logs de la Lambda para ver errores

3. Revisar si SES está en sandbox (solo puede enviar a emails verificados)

## 📚 Recursos Adicionales

- [EventBridge Schedule Expressions](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-create-rule-schedule.html)
- [Lambda Permissions](https://docs.aws.amazon.com/lambda/latest/dg/lambda-permissions.html)
- [Terraform AWS EventBridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)

---

**Última actualización**: 7 de noviembre de 2025
**Autor**: Sistema de CRUD Empleados

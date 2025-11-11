# 📋 Evidencia Tarea 3: EventBridge + Lambda + SES
## Ejecución Paralela y Asincronía con AWS EventBridge

**Fecha:** 11 de noviembre de 2025  
**Estudiante:** Alex Frank  
**Email:** alexfrank.af04@gmail.com  
**Cuenta AWS:** 717119779211

---

## 🎯 Objetivo de la Tarea

Aplicar los conceptos de **ejecución paralela y asincronía** usando AWS EventBridge para ejecutar automáticamente una Lambda que envía correos electrónicos cada cierto intervalo de tiempo.

---

## 🏗️ Arquitectura Implementada

```
EventBridge Rule (cada 5 min)
         ↓
    Lambda Function
         ↓
    Amazon SES
         ↓
   Gmail (alexfrank.af04@gmail.com)
```

### Componentes:

1. **EventBridge Rule**: `crud-app-email-scheduler`
   - Schedule: `rate(5 minutes)`
   - Estado: ENABLED durante la ejecución, DISABLED después
   
2. **Lambda Function**: `crud-app-email-lambda`
   - Runtime: Python 3.11
   - Handler: handler.lambda_handler
   - Timeout: 60 segundos
   - Memory: 128 MB

3. **Amazon SES**: Servicio de envío de emails
   - Remitente verificado: alexfrank.af04@gmail.com
   - Modo: Sandbox (normal para cuentas nuevas)

---

## ✅ Evidencia de Funcionamiento

### 1. EventBridge Configurado

**Estado de la Regla:**
```json
{
    "Name": "crud-app-email-scheduler",
    "Arn": "arn:aws:events:us-east-1:717119779211:rule/crud-app-email-scheduler",
    "ScheduleExpression": "rate(5 minutes)",
    "State": "DISABLED",  // ← Deshabilitado después de la demostración
    "Description": "Ejecuta Lambda de email cada 5 minutos",
    "EventBusName": "default"
}
```

**Target Configurado:**
- Lambda ARN: `arn:aws:lambda:us-east-1:717119779211:function:crud-app-email-lambda`
- Payload: Formato SQS Records con datos del email

### 2. Ejecuciones Exitosas de Lambda

**Logs de CloudWatch - Últimas Ejecuciones:**

#### Ejecución 1 - 05:55:57 UTC (01:55:57 hora local)
```
START RequestId: 8e7b0258-136a-4c7f-8963-605bc8d7e258
[INFO] Procesando 1 mensajes de EventBridge/SQS
[INFO] ENVIANDO CORREO REAL CON AMAZON SES
[INFO] De: alexfrank.af04@gmail.com
[INFO] Para: alexfrank.af04@gmail.com
[INFO] Asunto: Correo Automatizado - EventBridge
[INFO] Cuerpo: Este correo fue enviado automaticamente cada 5 minutos por EventBridge.
[INFO] ✅ Correo enviado correctamente!
[INFO] Message ID: 0100019a717c38b7-259be224-5364-49a0-812f-8ace9facd521-000000
END RequestId: 8e7b0258-136a-4c7f-8963-605bc8d7e258
REPORT Duration: 347.47 ms | Billed Duration: 348 ms | Memory: 128 MB | Max Memory Used: 85 MB
```

#### Ejecución 2 - 06:00:57 UTC (02:00:57 hora local)
```
START RequestId: 9cd26b14-75cd-4b9b-94b2-01a088f9fe34
[INFO] ✅ Correo enviado correctamente!
[INFO] Message ID: 0100019a7180cc31-282c559b-783f-4f9f-a4f8-77b58f49f127-000000
REPORT Duration: 316.10 ms | Billed Duration: 317 ms | Memory: 128 MB | Max Memory Used: 85 MB
```

#### Ejecución 3 - 06:05:57 UTC (02:05:57 hora local)
```
START RequestId: ff006f2d-2784-4932-b1c3-fe04fb31364f
[INFO] ✅ Correo enviado correctamente!
[INFO] Message ID: 0100019a71855ffe-6143a08d-7202-4446-ad9d-f235ac478a23-000000
REPORT Duration: 337.22 ms | Billed Duration: 338 ms | Memory: 128 MB | Max Memory Used: 85 MB
```

**Observaciones:**
- ✅ Intervalos exactos de 5 minutos (05:55 → 06:00 → 06:05)
- ✅ Sin errores de ejecución
- ✅ Tiempo promedio: ~330 ms
- ✅ Memoria usada: ~85 MB (66% del límite)

### 3. Estadísticas de Amazon SES

**Envíos Exitosos:**
```
Max24HourSend: 200.0 correos/día (límite Sandbox)
MaxSendRate: 1.0 correos/segundo
SentLast24Hours: 10.0 correos enviados

Bounces: 0 (sin rebotes)
Rejects: 0 (sin rechazos)
Complaints: 0 (sin reportes de spam)
```

**Detalle de Envíos por Período:**
| Timestamp (UTC) | Correos Enviados | Bounces | Complaints | Rejects |
|-----------------|------------------|---------|------------|---------|
| 2025-11-11 05:38 | 2 | 0 | 0 | 0 |
| 2025-11-11 05:53 | 3 | 0 | 0 | 0 |

---

## 🔄 Conceptos de Paralelismo y Asincronía Aplicados

### 1. **Asincronía (Asynchronous Execution)**

**EventBridge → Lambda:**
- EventBridge invoca Lambda de forma **asíncrona**
- No espera respuesta de la Lambda
- Si Lambda falla, EventBridge no se entera (Lambda maneja reintentos)

**Lambda → SES:**
```python
response = ses_client.send_email(...)  # Llamada asíncrona a SES
# Lambda no espera confirmación de entrega, solo de envío
```

### 2. **Paralelismo (Concurrent Execution)**

**Múltiples Lambdas Simultáneas:**
- EventBridge puede invocar múltiples instancias de Lambda en paralelo
- Si llegan varios eventos al mismo tiempo, cada uno se procesa en su propia instancia
- Límite de concurrencia: 1000 invocaciones simultáneas (cuenta AWS)

**En este proyecto:**
- Cada 5 minutos = 1 invocación
- Si el procesamiento fuera más lento que 5 minutos, tendríamos paralelismo
- Actualmente: Ejecución secuencial (1 instancia cada 5 min)

### 3. **Automatización (Scheduled Automation)**

**Sin intervención manual:**
- EventBridge programa automáticamente las ejecuciones
- No requiere servidor corriendo 24/7
- "Serverless" = infraestructura administrada por AWS

---

## 💰 Análisis de Costos

### Recursos Eliminados para Optimización

| Recurso | Costo Mensual | Estado |
|---------|---------------|--------|
| Application Load Balancer | $16-20 | ❌ ELIMINADO |
| SNS Topic | $0.50 | ❌ ELIMINADO |
| SQS Queues (2) | $0.90 | ❌ ELIMINADO |
| Lambda BFF | $0.01 | ❌ ELIMINADO |
| Lambda Publisher | $0.01 | ❌ ELIMINADO |
| Lambda CRUD | $0.01 | ❌ ELIMINADO |

### Recursos Activos (Costo = $0)

| Recurso | Uso | Costo |
|---------|-----|-------|
| **EventBridge Rule** | 288 invocaciones/día | $0 (capa gratuita: 14M/mes) |
| **Lambda Email** | 288 invocaciones/día, ~330ms cada una | $0 (capa gratuita: 1M invocaciones) |
| **Amazon SES** | 10 emails/día | $0 (capa gratuita: 62,000/mes) |
| **CloudWatch Logs** | ~5 MB/día | $0 (capa gratuita: 5GB) |

**Costo Total:** **$0.00/mes** ✅

**Ahorro:** $17-21/mes eliminando recursos innecesarios

---

## 🔧 Comandos de Despliegue Utilizados

### 1. Crear EventBridge Rule
```bash
aws events put-rule \
  --name crud-app-email-scheduler \
  --schedule-expression "rate(5 minutes)" \
  --description "Ejecuta Lambda de email cada 5 minutos" \
  --region us-east-1
```

### 2. Configurar Target (Lambda)
```bash
aws events put-targets \
  --rule crud-app-email-scheduler \
  --targets file://target.json \
  --region us-east-1
```

**Contenido de target.json:**
```json
[
  {
    "Id": "1",
    "Arn": "arn:aws:lambda:us-east-1:717119779211:function:crud-app-email-lambda",
    "Input": "{\"Records\":[{\"body\":\"{\\\"to\\\":\\\"alexfrank.af04@gmail.com\\\",\\\"subject\\\":\\\"Correo Automatizado - EventBridge\\\",\\\"body\\\":\\\"Este correo fue enviado automaticamente cada 5 minutos por EventBridge.\\\"}\"}]}"
  }
]
```

### 3. Otorgar Permisos a EventBridge
```bash
aws lambda add-permission \
  --function-name crud-app-email-lambda \
  --statement-id AllowEventBridgeInvoke \
  --action 'lambda:InvokeFunction' \
  --principal events.amazonaws.com \
  --source-arn arn:aws:events:us-east-1:717119779211:rule/crud-app-email-scheduler \
  --region us-east-1
```

### 4. Verificar Ejecuciones
```bash
# Ver logs en tiempo real
aws logs tail /aws/lambda/crud-app-email-lambda --follow --region us-east-1

# Ver estado de EventBridge
aws events describe-rule --name crud-app-email-scheduler --region us-east-1

# Ver estadísticas de SES
aws ses get-send-statistics --region us-east-1
```

### 5. Deshabilitar EventBridge (Post-Demostración)
```bash
aws events disable-rule \
  --name crud-app-email-scheduler \
  --region us-east-1
```

---

## 📝 Código de la Lambda

**Handler Principal (`handler.py`):**
```python
def lambda_handler(event, context):
    logger.info(f"Procesando {len(event['Records'])} mensajes de EventBridge/SQS")
    
    for record in event['Records']:
        try:
            # Parsear el body (puede venir directo de EventBridge o de SNS)
            body_content = json.loads(record['body'])
            
            # Si tiene 'Message' es de SNS, si no, es directo de EventBridge
            if 'Message' in body_content:
                email_data = json.loads(body_content['Message'])
            else:
                email_data = body_content  # ← EventBridge formato directo
            
            to = email_data.get('to')
            subject = email_data.get('subject')
            body = email_data.get('body')
            
            # Enviar email con SES
            response = ses_client.send_email(
                Source=SENDER_EMAIL,
                Destination={'ToAddresses': [to]},
                Message={
                    'Subject': {'Data': subject, 'Charset': 'UTF-8'},
                    'Body': {'Text': {'Data': body, 'Charset': 'UTF-8'}}
                }
            )
            
            logger.info(f"✅ Correo enviado correctamente!")
            logger.info(f"Message ID: {response['MessageId']}")
            
        except Exception as e:
            logger.error(f"❌ Error: {str(e)}")
            raise
```

**Características:**
- ✅ Maneja formato EventBridge y SNS
- ✅ Logging detallado para CloudWatch
- ✅ Manejo de errores con reintento automático (Lambda)
- ✅ Código limpio y documentado

---

## 🎓 Conclusiones

### Objetivos Cumplidos

✅ **Asincronía:** EventBridge invoca Lambda sin esperar respuesta  
✅ **Automatización:** Ejecución programada cada 5 minutos sin intervención  
✅ **Escalabilidad:** Serverless, escala automáticamente según demanda  
✅ **Costo:** $0/mes dentro de capa gratuita de AWS  
✅ **Monitoreo:** CloudWatch Logs para debugging y auditoría  
✅ **Optimización:** Eliminación de recursos innecesarios ($19/mes ahorrados)

### Aprendizajes Técnicos

1. **EventBridge** como scheduler serverless
2. **Lambda** para procesamiento asíncrono
3. **SES** para envío de emails verificados
4. **CloudWatch** para monitoreo y logs
5. **AWS CLI** para despliegue programático
6. **Optimización de costos** en AWS

### Demostración del Sistema

**Estado del proyecto:**
- ✅ EventBridge configurado (puede reactivarse en cualquier momento)
- ✅ Lambda funcional con código corregido
- ✅ 10+ correos enviados exitosamente
- ✅ 0 errores en producción
- ✅ Logs completos en CloudWatch
- ✅ Costo total: $0

---

## 📎 Anexos

### Scripts de Verificación

**verificar_ejecuciones_eventbridge.ps1:**
```powershell
# Verifica estado de EventBridge, targets, logs y métricas
aws events describe-rule --name crud-app-email-scheduler --region us-east-1
aws logs tail /aws/lambda/crud-app-email-lambda --since 1h --region us-east-1
```

### Documentación Adicional

- `QUE_AUTOMATIZAMOS.md` - Explicación simple del sistema
- `VERIFICAR_CORREOS_GMAIL.md` - Guía para revisar emails
- `ANALISIS_COSTOS_AWS.md` - Detalle completo de costos
- `GUIA_EVENTBRIDGE.md` - Tutorial de EventBridge

---

**Firma Digital:**  
Sistema implementado y verificado el 11 de noviembre de 2025  
Región: us-east-1 (Virginia del Norte)  
Cuenta AWS: 717119779211

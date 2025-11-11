# 📧 ¿QUÉ AUTOMATIZAMOS CON EVENTBRIDGE?

## 🎯 RESPUESTA SIMPLE

**Automatizamos el envío de 1 correo electrónico cada 5 minutos SIN tocar NADA.**

---

## 🔄 CÓMO FUNCIONA

### ANTES (Manual - Tarea 1):
```
1. Abres la app Flutter
2. Click en botón "Enviar Email"
3. Se envía 1 correo
4. Fin
```
**Problema**: Requiere que TÚ hagas click cada vez.

---

### AHORA (Automático - Tarea 2 con EventBridge):
```
1. EventBridge despierta cada 5 minutos ⏰
2. Invoca Lambda automáticamente
3. Lambda envía correo vía SES
4. Correo llega a alexfrank.af04@gmail.com
5. Se repite cada 5 minutos... para siempre

(Todo esto sin que TÚ hagas NADA)
```

**Ventaja**: Sistema autónomo 24/7.

---

## 📊 VISUALIZACIÓN

```
  ⏰ Cada 5 minutos
  ─────────────────────────────
  10:00 → ✉️ Correo enviado
  10:05 → ✉️ Correo enviado
  10:10 → ✉️ Correo enviado
  10:15 → ✉️ Correo enviado
  10:20 → ✉️ Correo enviado
  ...   → ✉️ (continúa infinitamente)
```

**SIN intervención manual. SIN servidores que mantener.**

---

## 🧩 LOS 3 COMPONENTES

### 1. EventBridge Rule (El Despertador)
- **Qué hace**: Ejecuta algo cada X tiempo
- **En nuestro caso**: `rate(5 minutes)` = cada 5 minutos
- **Archivo**: `terraform/eventbridge_scheduler.tf` línea 12

### 2. Lambda Function (El Trabajador)
- **Qué hace**: Envía el correo con Amazon SES
- **Código**: `infra/lambdas/email_lambda/handler.py`
- **Costo**: $0.00 (free tier cubre 1 millón de ejecuciones/mes)

### 3. Permission (El Permiso)
- **Qué hace**: Permite a EventBridge invocar Lambda
- **Archivo**: `terraform/eventbridge_scheduler.tf` línea 44

---

## 📈 CANTIDAD DE CORREOS

```
Por hora:    12 correos (60 min ÷ 5 min)
Por día:     288 correos (24 horas × 12)
Por mes:     8,640 correos (30 días × 288)
```

**Costo**: $0.00 (dentro del free tier de Lambda y EventBridge)

---

## 🎓 LOS 3 CONCEPTOS CLAVE (Para tu tarea)

### 1. ⚡ PARALELISMO
> "Si EventBridge dispara 100 eventos simultáneos, Lambda crea 100 instancias automáticamente. Escala de 0 a 1000 instancias según demanda sin configuración."

**Ejemplo**: Si en vez de 1 correo cada 5 min fueran 1000, Lambda los procesaría TODOS al mismo tiempo.

---

### 2. 🔄 ASINCRONÍA
> "EventBridge dispara Lambda y NO espera respuesta. Es 'fire and forget'. Esto permite procesamiento en background sin bloquear."

**Ejemplo**: EventBridge no se queda esperando a ver si el correo se envió. Dispara y sigue con su vida.

---

### 3. 🤖 AUTOMATIZACIÓN
> "Una vez desplegado, funciona solo. Cero intervención manual. La infraestructura está como código en `eventbridge_scheduler.tf`."

**Ejemplo**: Puedes apagar tu PC, irte a dormir, y EventBridge seguirá enviando correos cada 5 minutos.

---

## 🛠️ DÓNDE ESTÁ EL CÓDIGO

### Terraform (Infraestructura)
```bash
terraform/eventbridge_scheduler.tf
  ├── aws_cloudwatch_event_rule (línea 12)
  ├── aws_cloudwatch_event_target (línea 24)
  └── aws_lambda_permission (línea 44)
```

### Lambda (Código Python)
```bash
infra/lambdas/email_lambda/handler.py
  └── lambda_handler() - Función que envía correos
```

---

## 🔍 CÓMO VERIFICAR QUE FUNCIONA

### 1. AWS Console - EventBridge
```
URL: https://console.aws.amazon.com/events/
Buscar: "crud-app-email-scheduler"
Estado: Enabled ✅
Schedule: rate(5 minutes)
```

### 2. CloudWatch Logs
```
URL: https://console.aws.amazon.com/cloudwatch/
Log Group: /aws/lambda/crud-app-email-lambda
Buscar: "ENVIANDO CORREO REAL CON AMAZON SES"

Deberías ver timestamps cada 5 minutos:
10:00:00 - Correo enviado
10:05:00 - Correo enviado
10:10:00 - Correo enviado
```

### 3. Tu Gmail
```
Email: alexfrank.af04@gmail.com
Asunto: "Correo Automatizado - EventBridge"
Frecuencia: Cada 5 minutos
```

---

## 💰 ¿Y EL COSTO?

### Recursos con EventBridge:
```
EventBridge Rule    : $0.00 (primeros 14 millones gratis/mes)
Lambda Executions   : $0.00 (primeras 1 millón gratis/mes)
CloudWatch Logs     : $0.00 (primeros 5 GB gratis/mes)
IAM                 : $0.00 (siempre gratis)

TOTAL: $0.00/mes 🎉
```

### Recursos que SÍ cuestan (y NO necesitas para EventBridge):
```
ALB                 : ~$16-20/mes ❌ ELIMINAR
SNS Topic           : ~$0.50/mes ❌ ELIMINAR
SQS Queues          : ~$0.90/mes ❌ ELIMINAR
API Gateway         : ~$3.50/mes ❌ ELIMINAR (opcional)

Estos los usabas en Tarea 1 (flujo manual).
EventBridge NO los necesita.
```

**Ahorro al eliminar**: $17-25/mes

---

## 🚀 RESUMEN PARA TU PRESENTACIÓN

### ¿Qué hiciste?
> "Implementé un sistema de envío automático de correos usando AWS EventBridge que dispara una Lambda cada 5 minutos."

### ¿Por qué es mejor que un servidor tradicional?
> "No gestiono servidores, escala automáticamente, pago solo por uso ($0 con free tier), y está en código versionado."

### ¿Qué conceptos aplica?
> "Paralelismo (Lambda escala automático), asincronía (fire and forget), y automatización (cero intervención manual)."

### ¿Cuánto cuesta?
> "$0/mes. EventBridge tiene 14 millones de eventos gratis, Lambda 1 millón de ejecuciones. Ejecuto 8,640/mes: 100% dentro del free tier."

---

## ⚙️ CÓMO PAUSAR/REACTIVAR

### Pausar (sin eliminar):
```powershell
aws events disable-rule --name crud-app-email-scheduler --region us-east-1
```
**Resultado**: Deja de enviar correos pero la regla sigue existiendo.

### Reactivar:
```powershell
aws events enable-rule --name crud-app-email-scheduler --region us-east-1
```
**Resultado**: Vuelve a enviar correos cada 5 minutos.

### Eliminar completamente:
```powershell
cd terraform
.\terraform.exe destroy -target=aws_cloudwatch_event_rule.email_scheduler -auto-approve
```
**Resultado**: Elimina todo EventBridge (tendrías que reconfigurarlo).

---

## 🎬 FLUJO TÉCNICO COMPLETO

```
┌─────────────────────────────────────────────┐
│  EventBridge Rule                           │
│  - Name: crud-app-email-scheduler           │
│  - Schedule: rate(5 minutes)                │
│  - State: ENABLED                           │
└──────────────────┬──────────────────────────┘
                   │
                   │ (cada 5 min)
                   │ trigger asíncrono
                   ↓
┌─────────────────────────────────────────────┐
│  Lambda Email Function                      │
│  - Name: crud-app-email-lambda              │
│  - Runtime: Python 3.11                     │
│  - Timeout: 60 seg                          │
│  - Concurrency: Auto-scaling (0-1000)       │
└──────────────────┬──────────────────────────┘
                   │
                   │ invoke SES API
                   │ (asíncrono)
                   ↓
┌─────────────────────────────────────────────┐
│  Amazon SES (Simple Email Service)          │
│  - Sender: alexfrank.af04@gmail.com         │
│  - Verified Identity: ✅                    │
└──────────────────┬──────────────────────────┘
                   │
                   │ deliver email
                   ↓
┌─────────────────────────────────────────────┐
│  📧 Correo Recibido                         │
│  To: alexfrank.af04@gmail.com               │
│  Subject: Correo Automatizado - EventBridge │
│  Body: "Este correo fue enviado..."         │
└─────────────────────────────────────────────┘
```

---

## ✅ CHECKLIST DE VERIFICACIÓN

Antes de presentar, verifica:

- [ ] EventBridge Rule existe y está **Enabled**
- [ ] CloudWatch Logs muestra ejecuciones cada 5 minutos
- [ ] Gmail tiene múltiples correos con timestamps espaciados 5 min
- [ ] Puedes explicar los 3 conceptos: paralelismo, asincronía, automatización
- [ ] Sabes cuánto cuesta: **$0.00** (free tier)
- [ ] Entiendes la diferencia vs servidor tradicional (sin gestión, auto-escala, pago por uso)

---

**¡ÉXITO EN TU PRESENTACIÓN!** 🎓🚀

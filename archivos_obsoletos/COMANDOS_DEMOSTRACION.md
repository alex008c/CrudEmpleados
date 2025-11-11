# 🎯 GUÍA DE DEMOSTRACIÓN - EVENTBRIDGE + LAMBDA

## 📋 RESUMEN RÁPIDO

**Script único**: `EJECUTAR_TODO_COMPLETO.ps1`
- ✅ Inicia backend + BFF + frontend
- ✅ Despliega EventBridge en AWS
- ✅ Muestra instrucciones de demostración

## 🚀 PASO A PASO PARA LA DEMOSTRACIÓN

### 🎬 ANTES DE PRESENTAR (5 min antes)

1. **Ejecutar el script**:
```powershell
.\EJECUTAR_TODO_COMPLETO.ps1
```

2. **Verificar que todo esté corriendo**:
   - ✅ 3 ventanas PowerShell abiertas (backend, BFF, frontend)
   - ✅ App Flutter funcionando
   - ✅ EventBridge desplegado en AWS

---

### 📺 DURANTE LA PRESENTACIÓN (5 minutos)

#### **MINUTO 1: Mostrar el Código**

1. Abrir archivo: `terraform/eventbridge_scheduler.tf`

2. **Explicar** mostrando estas líneas:

```hcl
# Línea 12 - LA REGLA
resource "aws_cloudwatch_event_rule" "email_scheduler" {
  schedule_expression = "rate(5 minutes)"  # ← AUTOMÁTICO CADA 5 MIN
}

# Línea 24 - EL TARGET (qué ejecutar)
resource "aws_cloudwatch_event_target" "email_lambda_target" {
  arn = aws_lambda_function.email_lambda.arn  # ← LAMBDA DE EMAIL
}

# Línea 44 - LOS PERMISOS
resource "aws_lambda_permission" "allow_eventbridge" {
  principal = "events.amazonaws.com"  # ← EVENTBRIDGE PUEDE INVOCAR
}
```

**Decir**: 
> "Con solo 3 recursos de Terraform configuré una ejecución automática cada 5 minutos, sin servidores que administrar."

---

#### **MINUTO 2-3: Mostrar AWS Console - EventBridge**

1. Abrir: https://console.aws.amazon.com/events/

2. **Buscar regla**: `crud-app-email-scheduler`

3. **Mostrar**:
   - ✅ Estado: **Enabled** (verde)
   - ✅ Schedule: **rate(5 minutes)**
   - ✅ Targets: **Lambda function** (crud-app-email-lambda)

**Decir**: 
> "Esta regla está activa y dispara la Lambda automáticamente cada 5 minutos. EventBridge es un servicio completamente gestionado."

---

#### **MINUTO 3-4: Mostrar CloudWatch Logs**

1. Abrir: https://console.aws.amazon.com/cloudwatch/

2. Ir a: **Logs** → **Log groups**

3. Buscar: `/aws/lambda/crud-app-email-lambda`

4. **Abrir el stream más reciente**

5. **Mostrar las ejecuciones automáticas**:
   - Buscar: `ENVIANDO CORREO REAL CON AMAZON SES`
   - Mostrar timestamp de múltiples ejecuciones
   - Señalar que ocurren cada 5 minutos

**Decir**: 
> "Aquí vemos las ejecuciones automáticas. Cada 5 minutos EventBridge dispara la Lambda sin intervención manual. Es paralelismo puro: si hay 10 eventos simultáneos, Lambda crea 10 instancias automáticamente."

---

#### **MINUTO 4-5: Mostrar Email y Explicar Conceptos**

1. **Abrir Gmail**: alexfrank.af04@gmail.com

2. **Mostrar correos recibidos**:
   - Asunto: "Correo Automatizado - EventBridge"
   - Múltiples correos espaciados por 5 minutos

3. **Explicar los 3 conceptos clave**:

**PARALELISMO**:
> "Lambda escala automáticamente. Si hay 100 eventos al mismo tiempo, AWS crea 100 instancias de Lambda en paralelo, sin configuración adicional."

**ASINCRONÍA**:
> "EventBridge dispara la Lambda y NO espera respuesta. Es 'fire and forget'. Esto permite procesamiento en background sin bloquear recursos."

**AUTOMATIZACIÓN**:
> "Una vez desplegado con Terraform, el sistema funciona solo. Cero intervención manual. La infraestructura está versionada como código."

---

## 🎤 FRASES CLAVE PARA IMPRESIONAR

1. **Al mostrar el código**:
   > "Infraestructura como código con Terraform permite replicar esto en segundos en cualquier cuenta AWS."

2. **Al mostrar EventBridge**:
   > "EventBridge es un bus de eventos serverless que escala a millones de eventos sin gestión de servidores."

3. **Al mostrar los logs**:
   > "Cada ejecución es independiente y paralela. Lambda puede manejar hasta 1000 instancias concurrentes por región."

4. **Al explicar costos**:
   > "EventBridge tiene capa gratuita generosa. Solo pagamos por las ejecuciones de Lambda, que son centavos por millón."

---

## 📊 FLUJO VISUAL PARA EXPLICAR

```
┌─────────────────────────────────────────────┐
│  EventBridge Rule (cada 5 minutos)          │
│  schedule_expression = "rate(5 minutes)"    │
└──────────────────┬──────────────────────────┘
                   │ trigger automático
                   ↓
┌─────────────────────────────────────────────┐
│  Lambda Email Function                      │
│  Escala automáticamente (paralelismo)       │
└──────────────────┬──────────────────────────┘
                   │ asíncrono (no espera)
                   ↓
┌─────────────────────────────────────────────┐
│  Amazon SES                                 │
│  Envía correo real                          │
└──────────────────┬──────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────┐
│  Email recibido                             │
│  alexfrank.af04@gmail.com                   │
└─────────────────────────────────────────────┘
```

---

## ❓ PREGUNTAS FRECUENTES (y respuestas)

### 1. "¿Cómo escala si hay muchos eventos?"

**Respuesta**: 
> "Lambda escala automáticamente. AWS crea nuevas instancias en milisegundos. El límite por defecto es 1000 instancias concurrentes, pero se puede aumentar."

### 2. "¿Qué pasa si la Lambda falla?"

**Respuesta**: 
> "EventBridge reintenta automáticamente con backoff exponencial. También puedo configurar una Dead Letter Queue para capturar fallos."

### 3. "¿Cuánto cuesta?"

**Respuesta**: 
> "EventBridge: primeras 14 millones de eventos gratis/mes. Lambda: primeras 1 millón de peticiones gratis/mes. Para este proyecto: prácticamente $0."

### 4. "¿Por qué no un servidor tradicional con cron?"

**Respuesta**: 
> "Con servidor tradicional tengo que: aprovisionar, parchear, escalar, monitorear, pagar 24/7. Con EventBridge+Lambda: solo pago por uso, escala automático, cero mantenimiento."

---

## 💰 SOBRE LOS COSTOS (RESPUESTA CLARA)

### ¿Si desactivo SNS/SQS afecta a EventBridge?

**NO. EventBridge NO depende de SNS/SQS.**

```
FLUJO ANTERIOR (con SNS/SQS - lo que hicimos en Tarea 1):
Frontend → BFF → API Gateway → Publisher Lambda → SNS → SQS → Email Lambda

FLUJO ACTUAL (EventBridge - Tarea 2):
EventBridge → Email Lambda (DIRECTO)
```

### ¿Qué puedo desactivar para ahorrar?

✅ **PUEDES DESACTIVAR** (no afecta EventBridge):
- SNS Topic
- SQS Queue
- API Gateway (del flujo manual)
- Publisher Lambda (del flujo manual)

❌ **NO DESACTIVAR** (necesario para EventBridge):
- Email Lambda (EventBridge la necesita)
- EventBridge Rule (es lo que queremos demostrar)

### ¿Cuánto ahorro?

- **SNS + SQS**: ~$0.50-1.00/mes → **Ahorro: $1/mes**
- **EventBridge + Lambda**: ~$0.10/mes (con free tier: $0) → **Costo: $0**

### Comando para desactivar SNS/SQS:

```powershell
cd terraform
.\terraform.exe destroy -target=aws_sqs_queue.email_queue
.\terraform.exe destroy -target=aws_sns_topic.email_topic
```

**Resultado**: Ahorro de costos + EventBridge sigue funcionando perfectamente.

---

## 🛑 CONTROLES IMPORTANTES

### Para pausar EventBridge (sin eliminar):

```powershell
aws events disable-rule --name crud-app-email-scheduler --region us-east-1
```

### Para reactivar:

```powershell
aws events enable-rule --name crud-app-email-scheduler --region us-east-1
```

### Para eliminar completamente:

```powershell
cd terraform
.\terraform.exe destroy
```

---

## ✅ CHECKLIST PRE-DEMOSTRACIÓN

- [ ] Ejecutar `EJECUTAR_TODO_COMPLETO.ps1`
- [ ] Verificar 3 ventanas PowerShell abiertas
- [ ] Verificar app Flutter funcionando
- [ ] Abrir AWS Console en pestaña EventBridge
- [ ] Abrir AWS Console en pestaña CloudWatch Logs
- [ ] Abrir Gmail en otra pestaña
- [ ] Tener `eventbridge_scheduler.tf` abierto en VSCode
- [ ] Esperar al menos 5 minutos después del despliegue (para ver ejecuciones)

---

## 🎓 MENSAJE FINAL POTENTE

> "Con esta implementación demostré tres pilares de la computación en la nube moderna: **paralelismo** mediante auto-escalado de Lambda, **asincronía** con arquitectura event-driven, y **automatización** usando infraestructura como código. Todo sin gestionar un solo servidor, pagando solo por lo que uso, y desplegable en minutos en cualquier entorno."

---

**¡ÉXITO EN TU PRESENTACIÓN!** 🚀

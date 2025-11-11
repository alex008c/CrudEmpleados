# 🔍 SITUACIÓN ACTUAL - AWS

## ❗ IMPORTANTE: AWS CLI NO CONFIGURADO

El script de eliminación se ejecutó, pero **AWS CLI no tiene credenciales configuradas** en esta PC.

Esto significa que **NO PUEDO acceder a tu cuenta AWS desde la línea de comandos**.

---

## 🎯 LO QUE AUTOMATIZASTE CON EVENTBRIDGE

**SÍ automatizaste**: Envío de correos cada 5 minutos con EventBridge + Lambda

**PERO**: Los recursos pueden estar:
1. Solo en configuración Terraform (archivos `.tf`) pero **no desplegados** en AWS
2. Desplegados en AWS desde **otra PC** o **consola web**
3. Desplegados pero con **otras credenciales AWS**

---

## 🔎 CÓMO VERIFICAR TUS RECURSOS EN AWS

### Opción 1: AWS Console (Web) - RECOMENDADO

Abre tu navegador y ve directamente a AWS Console:

#### 1️⃣ **EventBridge** (Lo que automatizaste)
```
URL: https://console.aws.amazon.com/events/
Buscar: "email-scheduler" o "crud-app"
```
**Si encuentras una regla ENABLED**:
- ✅ EventBridge está funcionando
- ✅ Enviando correos cada 5 min

**Si NO encuentras nada**:
- ❌ EventBridge NO está desplegado
- ❌ Necesitas ejecutar `terraform apply`

---

#### 2️⃣ **Lambda Functions** (El trabajador)
```
URL: https://console.aws.amazon.com/lambda/
Buscar: "email-lambda" o "crud-app"
```
**Deberías ver**:
- `crud-app-email-lambda` (NECESARIA para EventBridge)
- `crud-app-bff-lambda` (OPCIONAL, se puede eliminar)

---

#### 3️⃣ **Application Load Balancer** (COSTO: $16-20/mes)
```
URL: https://console.aws.amazon.com/ec2/v2/home#LoadBalancers
Buscar: "crud-app-alb"
```
**Si encuentras un ALB**:
- ❌ **ELIMÍNALO** - Te cuesta $16-20/mes
- ❌ **NO LO NECESITAS** para EventBridge

**Cómo eliminar**:
1. Click en el ALB
2. Actions → Delete
3. Confirmar

---

#### 4️⃣ **SNS Topics** (COSTO: $0.50/mes)
```
URL: https://console.aws.amazon.com/sns/
Buscar: "crud-app-email-topic"
```
**Si encuentras un Topic**:
- ❌ **ELIMÍNALO** - Te cuesta dinero
- ❌ **NO LO NECESITAS** para EventBridge

---

#### 5️⃣ **SQS Queues** (COSTO: $0.40-0.90/mes)
```
URL: https://console.aws.amazon.com/sqs/
Buscar: "crud-app-email-queue"
```
**Si encuentras colas**:
- ❌ **ELIMÍNALAS** - Te cuestan dinero
- ❌ **NO LAS NECESITAS** para EventBridge

---

#### 6️⃣ **API Gateway** (COSTO: $3.50/mes después de free tier)
```
URL: https://console.aws.amazon.com/apigateway/
Buscar: "email"
```
**Si encuentras un API**:
- ❌ **ELIMÍNALO** - Te cuesta dinero
- ❌ **NO LO NECESITAS** para EventBridge

---

#### 7️⃣ **S3 Buckets** (COSTO: Variable)
```
URL: https://console.aws.amazon.com/s3/
Buscar: "crud-app-alb-logs"
```
**Si encuentras buckets con "alb-logs"**:
- ❌ **ELIMÍNALOS** - Almacenamiento cuesta dinero
- ❌ **NO LOS NECESITAS** para EventBridge

---

## ✅ RECURSOS QUE SÍ NECESITAS (NO ELIMINAR)

### Para que EventBridge funcione, NECESITAS:

1. **EventBridge Rule** (`crud-app-email-scheduler`)
   - Costo: **$0.00** (free tier: 14 millones eventos/mes)
   - Función: Dispara Lambda cada 5 minutos

2. **Lambda Email Function** (`crud-app-email-lambda`)
   - Costo: **$0.00** (free tier: 1 millón ejecuciones/mes)
   - Función: Envía correos con SES

3. **IAM Role** (`crud-app-email-lambda-role`)
   - Costo: **$0.00** (IAM siempre gratis)
   - Función: Permisos para Lambda

4. **CloudWatch Logs** (`/aws/lambda/crud-app-email-lambda`)
   - Costo: **$0.00** (free tier: 5 GB/mes)
   - Función: Logs para debugging

5. **SES Verified Identity** (`alexfrank.af04@gmail.com`)
   - Costo: **$0.00** (sandbox mode)
   - Función: Enviar correos

---

## 💰 CÁLCULO DE COSTOS

### SI TIENES TODO DESPLEGADO (Tarea 1 + Tarea 2):
```
ALB                      : $16-20/mes  ← ELIMINAR
SNS Topic                : $0.50/mes   ← ELIMINAR
SQS Queues (2)           : $0.90/mes   ← ELIMINAR
API Gateway              : $3.50/mes   ← ELIMINAR
Lambda BFF               : $0.00       ← ELIMINAR (innecesaria)
CloudWatch Alarms        : $0.10/mes   ← ELIMINAR (opcional)
S3 Buckets (logs)        : $0.05/mes   ← ELIMINAR

TOTAL ACTUAL: $21-25/mes
```

### SI SOLO DEJAS EVENTBRIDGE (Tarea 2):
```
EventBridge Rule         : $0.00  ✅
Lambda Email             : $0.00  ✅
CloudWatch Logs          : $0.00  ✅
IAM Roles                : $0.00  ✅

TOTAL OPTIMIZADO: $0.00/mes 🎉
AHORRO: $21-25/mes ($252-300/año)
```

---

## 🚀 QUÉ HACER AHORA

### Paso 1: Verificar qué está desplegado

1. Inicia sesión en **AWS Console**: https://console.aws.amazon.com/
2. Ve a cada servicio (URLs arriba)
3. Anota qué recursos tienes

### Paso 2: Eliminar servicios con costo

**Desde AWS Console**, elimina MANUALMENTE:
- ❌ ALB (Load Balancers)
- ❌ SNS Topics
- ❌ SQS Queues
- ❌ API Gateway
- ❌ Lambda BFF (solo si tienes 2 Lambdas)
- ❌ S3 Buckets (alb-logs)

**Mantén**:
- ✅ EventBridge Rule (email-scheduler)
- ✅ Lambda Email (crud-app-email-lambda)

### Paso 3: Confirmar que EventBridge funciona

1. **AWS Console → EventBridge**
   - Regla debe estar **Enabled**
   
2. **AWS Console → CloudWatch Logs**
   - Busca: `/aws/lambda/crud-app-email-lambda`
   - Deberías ver ejecuciones cada 5 minutos

3. **Gmail**
   - Revisa: `alexfrank.af04@gmail.com`
   - Deberías recibir correos cada 5 minutos

---

## 🛠️ CONFIGURAR AWS CLI (OPCIONAL)

Si quieres usar scripts automáticos en el futuro:

```powershell
aws configure
```

Te pedirá:
- AWS Access Key ID
- AWS Secret Access Key
- Region: `us-east-1`
- Output format: `json`

**Obtener credenciales**:
1. AWS Console → IAM
2. Users → Tu usuario
3. Security credentials → Create access key

---

## 📝 RESUMEN

### ✅ Lo que SÍ hiciste (Configuración):
- Creaste `eventbridge_scheduler.tf` (automatización cada 5 min)
- Configuraste Terraform para EventBridge
- Documentaste todo en archivos `.md`

### ❓ Lo que NO SABEMOS:
- Si los recursos están **desplegados** en AWS
- Cuánto te está **costando** actualmente

### 🎯 Próximo paso:
**VE A AWS CONSOLE** (web) y verifica qué tienes desplegado.

Usa las URLs de arriba para cada servicio. 

**Luego elimina lo que tiene costo y no necesitas.**

---

## 🆘 AYUDA RÁPIDA

### ¿Cómo sé si EventBridge está funcionando?
→ Revisa tu Gmail: `alexfrank.af04@gmail.com`  
→ Si recibes correos cada 5 min: **SÍ funciona**  
→ Si no recibes nada: **NO está desplegado**

### ¿Qué debo eliminar PRIMERO para ahorrar más?
→ **ALB (Load Balancer)**: $16-20/mes de ahorro inmediato

### ¿Puedo eliminar TODO y empezar de cero?
→ **SÍ**, pero perderás la automatización de EventBridge.  
→ Tendrías que volver a ejecutar `terraform apply`.

---

**CONCLUSIÓN**: Ve a AWS Console (web) y verifica manualmente qué recursos tienes. Usa este documento como guía para saber qué eliminar y qué mantener.

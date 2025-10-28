# 🚀 Guía de Despliegue - Arquitectura Cloud con Terraform

## 📋 Requisitos Previos

1. **AWS CLI configurado**
   ```powershell
   aws configure
   # Ingresa: Access Key, Secret Key, Region (us-east-1), Output format (json)
   ```

2. **Terraform instalado**
   ```powershell
   terraform version  # Debe ser >= 1.0
   ```

3. **Python 3.11+ y pip**

4. **Flutter SDK**

---

## 🏗️ Paso 1: Desplegar Infraestructura AWS

### 1.1 Navegar al directorio de Terraform
```powershell
cd terraform
```

### 1.2 Inicializar Terraform
```powershell
terraform init
```

### 1.3 Ver el plan de despliegue
```powershell
terraform plan
```

### 1.4 Aplicar la infraestructura
```powershell
terraform apply
# Escribir 'yes' cuando pregunte
```

### 1.5 Guardar los outputs importantes
```powershell
terraform output email_api_url
terraform output email_api_key
terraform output sns_topic_arn
terraform output sqs_queue_url
```

**Ejemplo de outputs:**
```
email_api_url = "https://abc123xyz.execute-api.us-east-1.amazonaws.com/dev/publish"
email_api_key = "tu-api-key-aqui"
sns_topic_arn = "arn:aws:sns:us-east-1:123456789:email-topic-dev"
sqs_queue_url = "https://sqs.us-east-1.amazonaws.com/123456789/email-queue-dev"
```

---

## 🔧 Paso 2: Configurar y Arrancar el BFF

### 2.1 Editar el archivo de inicio
Abre `bff/start_bff.ps1` y reemplaza los valores:

```powershell
$env:PUBLISH_API_URL = "https://abc123xyz.execute-api.us-east-1.amazonaws.com/dev/publish"
$env:PUBLISH_API_KEY = "tu-api-key-aqui"
```

### 2.2 Ejecutar el BFF
```powershell
cd bff
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8001
```

El BFF estará disponible en: `http://localhost:8001`

---

## 📱 Paso 3: Ejecutar el Frontend

### 3.1 Arrancar la aplicación Flutter
```powershell
cd frontend
flutter run -d windows
```

### 3.2 Probar el flujo de correo
1. En la aplicación, haz clic en el botón verde de email (📧)
2. Completa el formulario:
   - **Para:** prueba@ejemplo.com
   - **Asunto:** Prueba de correo
   - **Mensaje:** Este es un mensaje de prueba
3. Haz clic en "Enviar"
4. Deberías ver un mensaje de éxito

---

## 🧪 Paso 4: Verificar el Flujo Completo

### 4.1 Ver logs de CloudWatch
En la consola de AWS:
1. Ir a **CloudWatch** → **Log groups**
2. Buscar `/aws/lambda/empleados-email-lambda`
3. Ver los logs recientes
4. Deberías ver:
   ```
   ==========================================
   📧 SIMULACIÓN DE ENVÍO DE CORREO
   ==========================================
   📧 Enviando correo a: prueba@ejemplo.com
   📨 Asunto: Prueba de correo
   📝 Cuerpo: Este es un mensaje de prueba
   ==========================================
   ✅ Correo enviado correctamente
   ==========================================
   ```

### 4.2 Verificar la cola SQS
1. Ir a **SQS** en AWS Console
2. Buscar `empleados-email-queue`
3. Ver métricas de mensajes procesados

### 4.3 Verificar SNS
1. Ir a **SNS** → **Topics**
2. Buscar `empleados-email-topic`
3. Ver métricas de publicaciones

---

## 🔍 Troubleshooting

### Error: "Connection refused" en el frontend
**Solución:** Asegúrate de que el BFF esté corriendo en `http://localhost:8001`

### Error: "403 Forbidden" desde el BFF
**Solución:** Verifica que la API Key esté correctamente configurada en las variables de entorno del BFF

### Los mensajes no llegan a la Lambda
**Solución:**
1. Verifica la suscripción SQS en SNS
2. Revisa los permisos IAM de la Lambda
3. Chequea el Event Source Mapping entre SQS y Lambda

### No aparecen logs en CloudWatch
**Solución:** Espera 1-2 minutos, CloudWatch puede tardar en mostrar los logs

---

## 📊 Arquitectura Desplegada

```
Frontend (Flutter)
    ↓ POST /notify/email
BFF (FastAPI - localhost:8001)
    ↓ POST /publish (x-api-key)
API Gateway
    ↓
Lambda Publisher
    ↓
SNS Topic (email-topic)
    ↓
SQS Queue (email-queue) ← DLQ (email-dlq)
    ↓
Lambda Email
    ↓
CloudWatch Logs
```

---

## 🧹 Limpieza (Destruir Infraestructura)

Cuando termines de probar:

```powershell
cd terraform
terraform destroy
# Escribir 'yes' cuando pregunte
```

Esto eliminará **todos** los recursos creados en AWS.

---

## 📝 Notas Importantes

1. **API Key:** Nunca la subas a GitHub. Usa variables de entorno o AWS Secrets Manager en producción.

2. **Costos:** Los recursos de esta arquitectura están en el Free Tier de AWS, pero verifica los límites.

3. **DLQ (Dead Letter Queue):** Ya está implementada. Los mensajes que fallen 3 veces irán a `empleados-email-dlq`.

4. **Rate Limiting:** El API Gateway tiene configurado:
   - Burst: 100 peticiones
   - Rate: 50 peticiones/segundo
   - Quota: 10,000 peticiones/mes

5. **Timeouts:**
   - Publisher Lambda: 30 segundos
   - Email Lambda: 60 segundos
   - BFF request timeout: 10 segundos

---

## ✅ Checklist de Entregables

- [ ] Terraform desplegado exitosamente
- [ ] API Gateway con API Key funcionando
- [ ] BFF recibiendo peticiones del frontend
- [ ] SNS Topic recibiendo publicaciones
- [ ] SQS Queue procesando mensajes
- [ ] Lambda Email escribiendo logs en CloudWatch
- [ ] DLQ configurada (BONUS)
- [ ] Frontend con modal de correo funcionando
- [ ] Logs visibles en CloudWatch
- [ ] Capturas de pantalla tomadas para el PDF

---

## 🎯 Para la Presentación (3 minutos)

1. **Mostrar login + CRUD** (30 seg)
2. **Abrir modal y enviar correo** (30 seg)
3. **Mostrar AWS Console:**
   - API Gateway (20 seg)
   - SNS Topic (20 seg)
   - SQS Queue (20 seg)
   - CloudWatch Logs con el correo simulado (40 seg)

# GUÍA DE PRESENTACIÓN - PROYECTO CRUD EMPLEADOS CON AWS

## 🎯 RESUMEN EJECUTIVO

Este proyecto implementa una **arquitectura desacoplada y asíncrona en AWS** con:
- **35 recursos AWS desplegados** con Terraform
- **Backend CRUD** (login + empleados) con FastAPI + PostgreSQL (Supabase)
- **Servicio de correo asíncrono** usando SNS → SQS → Lambda
- **BFF (Backend For Frontend)** como único punto de entrada
- **Frontend Flutter** para Windows

---

## 📊 ARQUITECTURA IMPLEMENTADA

### Flujo 1: CRUD de Empleados
```
Frontend (Flutter)
    ↓
Backend (FastAPI local/AWS Lambda)
    ↓
Supabase PostgreSQL
```

### Flujo 2: Envío de Correos (100% AWS)
```
Frontend (Flutter)
    ↓
BFF (FastAPI - localhost:8001)
    ↓ (x-api-key)
API Gateway (REST API con API Key)
    ↓
Lambda: publisher-lambda
    ↓
SNS Topic (email-topic)
    ↓
SQS Queue (email-queue + DLQ)
    ↓
Lambda: email-lambda (auto-triggered)
    ↓
CloudWatch Logs (simulación de envío)
```

---

## 🎬 GUIÓN DE DEMOSTRACIÓN (3 MINUTOS)

### Minuto 1: Introducción y CRUD (30 seg)
**QUÉ MOSTRAR:**
1. Abrir la aplicación Flutter
2. Registrarse con usuario nuevo
3. Iniciar sesión
4. Mostrar lista de empleados
5. Crear un empleado nuevo
6. Editar un empleado
7. Eliminar un empleado

**QUÉ DECIR:**
> "Este es el frontend desarrollado en Flutter que se comunica con un backend FastAPI. 
> El backend está conectado a una base de datos PostgreSQL en Supabase.
> Aquí tenemos las operaciones CRUD básicas: crear, leer, actualizar y eliminar empleados."

### Minuto 2: Flujo de Correo AWS (1 min)
**QUÉ MOSTRAR:**
1. En la app, hacer clic en el botón verde de email
2. Llenar el formulario:
   - **Para**: `profesor@universidad.edu`
   - **Asunto**: `Demo AWS - Arquitectura Asíncrona`
   - **Mensaje**: `Este correo fue enviado mediante SNS → SQS → Lambda en AWS`
3. Hacer clic en "Enviar"
4. Mostrar mensaje de éxito

**QUÉ DECIR:**
> "Ahora demostraré el flujo de correo completamente desacoplado en AWS.
> El frontend solo conoce al BFF, que es el único punto de entrada.
> El BFF se comunica con API Gateway usando una API Key.
> API Gateway dispara una Lambda que publica el mensaje en SNS.
> SNS envía el mensaje a una cola SQS.
> SQS dispara automáticamente otra Lambda que simula el envío del correo.
> Todo esto está desplegado con Terraform."

### Minuto 3: Verificación en AWS (1 min)
**QUÉ MOSTRAR:**
1. Abrir AWS Console (ya abierta en navegador)
2. Ir a CloudWatch → Log groups
3. Buscar: `/aws/lambda/crud-app-email-lambda`
4. Abrir el log stream más reciente
5. Mostrar el log con el correo enviado:
   ```
   SIMULACION DE ENVIO DE CORREO
   Destinatario: profesor@universidad.edu
   Asunto: Demo AWS - Arquitectura Asíncrona
   Cuerpo: Este correo fue enviado mediante SNS → SQS → Lambda en AWS
   Correo enviado correctamente
   ```

**QUÉ DECIR:**
> "Como pueden ver en CloudWatch, la Lambda procesó el mensaje de la cola SQS
> y simuló el envío del correo. En producción, aquí se integraría con 
> servicios como SES, SendGrid o Mailgun para enviar correos reales."

### Cierre (30 seg)
**QUÉ MOSTRAR:**
- Abrir Visual Studio Code con el código
- Mostrar carpeta `terraform/` con archivos .tf
- Mostrar `bff/main.py` brevemente

**QUÉ DECIR:**
> "Toda la infraestructura está definida como código con Terraform.
> Tenemos 35 recursos en AWS incluyendo Lambdas, API Gateway, SNS, SQS,
> roles IAM, políticas, y logs en CloudWatch.
> El BFF actúa como middleware de seguridad, manejando las API Keys
> para que el frontend no tenga acceso directo a AWS."

---

## 🔑 PUNTOS CLAVE A MENCIONAR

### Arquitectura Desacoplada
- ✅ Frontend solo conoce al BFF (no tiene URLs de AWS)
- ✅ BFF maneja autenticación con API Gateway
- ✅ SNS/SQS desacoplan publicación de procesamiento
- ✅ Lambdas procesan de forma asíncrona

### Escalabilidad
- ✅ Lambdas escalan automáticamente
- ✅ SQS actúa como buffer (maneja picos de carga)
- ✅ Dead Letter Queue para mensajes fallidos

### Seguridad
- ✅ API Key en API Gateway
- ✅ Passwords hasheados con bcrypt
- ✅ JWT para autenticación
- ✅ CORS configurado
- ✅ Variables de entorno para secrets

### Infraestructura como Código
- ✅ Todo desplegable con `terraform apply`
- ✅ Reproducible en cualquier cuenta AWS
- ✅ Versionado en Git

---

## 📈 RECURSOS AWS DESPLEGADOS (35 TOTAL)

### Servicio de Correo (26 recursos)
- 2 Lambda Functions (publisher + email)
- 1 API Gateway REST API
- 1 SNS Topic
- 2 SQS Queues (queue + DLQ)
- 1 API Key + Usage Plan
- 2 CloudWatch Log Groups
- 6 IAM Roles y Policies
- Múltiples integraciones y permisos

### Backend CRUD (9 recursos)
- 1 Lambda Function
- 1 API Gateway HTTP API
- 2 IAM Roles y Policies
- Integraciones y permisos

---

## 🛠️ TECNOLOGÍAS UTILIZADAS

### Backend
- **FastAPI** - Framework web moderno para APIs
- **SQLAlchemy** - ORM para bases de datos
- **Pydantic** - Validación de datos
- **Mangum** - Adaptador ASGI para AWS Lambda
- **bcrypt** - Hash de contraseñas
- **JWT** - Tokens de autenticación

### Frontend
- **Flutter** - Framework multiplataforma
- **Provider** - Gestión de estado
- **MVVM** - Patrón arquitectónico

### Infraestructura
- **Terraform** - Infrastructure as Code
- **AWS Lambda** - Compute serverless
- **API Gateway** - Gestión de APIs
- **SNS** - Pub/Sub messaging
- **SQS** - Cola de mensajes
- **CloudWatch** - Monitoreo y logs

### Base de Datos
- **PostgreSQL** (Supabase) - Base de datos relacional en la nube

---

## 📝 PREGUNTAS FRECUENTES DEL MAESTRO

### "¿Por qué usar BFF si ya tienes API Gateway?"
> "El BFF actúa como capa de abstracción y seguridad. Maneja las API Keys
> de AWS y puede agregar lógica de negocio adicional. El frontend solo
> conoce una URL local, lo que facilita cambios en la infraestructura AWS
> sin modificar el código del frontend."

### "¿Qué pasa si falla el envío del correo?"
> "Tenemos un Dead Letter Queue (DLQ) configurado. Si un mensaje falla
> después de 3 intentos, se mueve al DLQ donde podemos revisarlo y
> reprocesarlo manualmente. Esto evita perder mensajes importantes."

### "¿Por qué Lambda y no EC2?"
> "Lambda es serverless: no hay que administrar servidores, escala
> automáticamente, y solo pagas por el tiempo de ejecución. Para cargas
> variables como emails, es más económico y eficiente que tener un EC2
> corriendo 24/7."

### "¿El backend CRUD también está en AWS?"
> "Sí, tenemos la Lambda y API Gateway desplegados. Para la demo uso
> la versión local por simplicidad, pero la infraestructura AWS está
> lista y funcional. El código es el mismo gracias a Mangum."

---

## 📸 CAPTURAS IMPORTANTES A MOSTRAR

1. **Frontend Flutter** - Lista de empleados y modal de correo
2. **CloudWatch Logs** - Log del correo procesado
3. **AWS Console SNS** - Topic creado
4. **AWS Console SQS** - Cola con métricas
5. **AWS Console Lambda** - Funciones desplegadas
6. **Código Terraform** - Archivos .tf en VS Code
7. **Arquitectura (diagrama)** - Si tienes tiempo, mostrar en README

---

## ⏰ TIMING SUGERIDO

- 0:00 - 0:30: Introducción + mostrar CRUD
- 0:30 - 1:30: Demo flujo de correo (frontend)
- 1:30 - 2:30: Verificación en AWS (CloudWatch)
- 2:30 - 3:00: Mostrar código Terraform + cierre

---

## 🎓 MENSAJE FINAL

> "Este proyecto demuestra una arquitectura moderna, escalable y desacoplada
> que sigue las mejores prácticas de desarrollo en la nube. La comunicación
> asíncrona mediante SNS y SQS permite procesar cargas variables sin bloquear
> el flujo principal de la aplicación. El uso de Terraform garantiza que toda
> la infraestructura sea reproducible, versionada y fácil de mantener."

---

## 🚀 EJECUCIÓN RÁPIDA ANTES DE PRESENTAR

```powershell
# 1. Navegar al proyecto
cd CrudEmpleados

# 2. Ejecutar todo
.\EJECUTAR_TODO.ps1

# 3. Esperar a que se abra el frontend Flutter (30-60 segundos)

# 4. Abrir navegador con AWS Console en CloudWatch
# https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups

# ¡Listo para presentar!
```

---

## 📚 DOCUMENTACIÓN ADICIONAL

Si el maestro quiere profundizar:
- `README.md` - Visión general del proyecto
- `docs/EVIDENCIAS.md` - Diagramas y capturas detalladas
- `.github/copilot-instructions.md` - Arquitectura MVVM y patrones
- `GUIA_INSTALACION.md` - Cómo replicar el proyecto

**¡Éxito en tu presentación! 🎉**

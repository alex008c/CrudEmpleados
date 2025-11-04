# Sistema CRUD de Empleados con AWS# CRUD Empleados con AWS# CRUD Empleados - Flutter + FastAPI + AWS# 🚀 CRUD Empleados - Flutter + FastAPI



Sistema completo de gestión de empleados implementado con arquitectura serverless en AWS, utilizando Application Load Balancer, Lambda Functions, API Gateway, PostgreSQL y sistema de notificaciones.



## Tareas CompletadasSistema de gestión de empleados con arquitectura serverless en AWS, implementando comunicación asíncrona mediante SNS/SQS.



- ✅ **Tarea 1:** Sistema CRUD con SNS/SQS/SES (35 recursos AWS)

- ✅ **Tarea 2:** Load Balancing con ALB + Auto Scaling Lambda (51 recursos AWS)

## DescripciónSistema completo de gestión de empleados con arquitectura MVVM, autenticación JWT, operaciones CRUD asíncronas y arquitectura cloud desacoplada en AWS.Sistema completo de gestión de empleados con **arquitectura MVVM**, autenticación JWT, operaciones CRUD y concurrencia medible con Future.wait.

## Arquitectura



```

Cliente → ALB (Multi-AZ) → Lambda BFF → API Gateway → Lambda CRUD → PostgreSQLProyecto que implementa:

                                                              ↓

                                                         SNS → SQS → Lambda Email → SES- Backend CRUD con FastAPI y autenticación JWT

```

- Servicio de correo electrónico asíncrono en AWS## Inicio Rápido## ⚡ Inicio Rápido

### Componentes

- Frontend Flutter con arquitectura MVVM

**Networking:**

- VPC 10.0.0.0/16 con 2 subnets públicas (Multi-AZ)- Infraestructura como código con Terraform

- Internet Gateway y Route Tables

- Security Groups- 35 recursos AWS desplegados



**Load Balancing:**### Desarrollo Local### 🎯 Opción 1: Script Automático (TODO EN UNO)

- Application Load Balancer (internet-facing)

- Target Group con health checks (/health cada 35s)## Arquitectura

- Listener HTTP puerto 80

```powershell

**Compute:**

- Lambda BFF (proxy ALB → API Gateway)### Backend CRUD

- Lambda CRUD (SQLAlchemy + PostgreSQL + SNS)

- Lambda Email (procesamiento SQS → SES)```**Script automático (Backend + Frontend):**.\start_all.ps1



**API Gateway:**Frontend Flutter → Backend FastAPI → PostgreSQL (Supabase)

- HTTP API CRUD

- HTTP API Email Publisher``````powershell```



**Messaging:**

- SNS Topic (notificaciones)

- SQS Queue + DLQ### Servicio de Correo (AWS).\dev.ps1Este script inicia backend y frontend automáticamente en terminales separadas.

- SES (envío de emails)

```

**Monitoring:**

- CloudWatch DashboardFrontend → BFF → API Gateway → Lambda Publisher ```

- 5 alarmas configuradas

- Logs centralizados  → SNS Topic → SQS Queue → Lambda Email → Amazon SES



## Estructura del Proyecto```### 🔧 Opción 2: Scripts Individuales (2 TERMINALES)



```

CrudEmpleados/

├── backend/              # FastAPI CRUD (desarrollo local)## Tecnologías**Solo Backend:**

├── bff/                  # Lambda BFF (proxy ALB → API Gateway)

├── lambda_crud_simple/   # Lambda CRUD con PostgreSQL + SNS

├── terraform/            # IaC (51 recursos AWS)

│   ├── alb.tf           # Application Load Balancer**Backend:**```powershell**Terminal 1 - Backend:**

│   ├── networking.tf    # VPC, Subnets, IGW

│   ├── crud_backend_simple.tf  # Lambda CRUD- FastAPI

│   ├── bff_lambda.tf    # Lambda BFF

│   ├── messaging.tf     # SNS, SQS, Lambda Email- SQLAlchemy.\run_backend.ps1```powershell

│   ├── monitoring.tf    # CloudWatch

│   └── main.tf          # Variables y provider- JWT (python-jose)

├── frontend/            # Flutter App (arquitectura MVVM)

├── docs/                # Documentación técnica- bcrypt```.\start_backend.ps1

└── infra/lambdas/       # Deployment packages (.zip)

```- PostgreSQL



## Inicio Rápido```



### Requisitos**Frontend:**



- Terraform >= 1.0- Flutter**Solo Frontend:**

- AWS CLI configurado

- Python 3.11+- Provider (State Management)

- Node.js (para frontend opcional)

- MVVM Architecture```powershell**Terminal 2 - Frontend:**

### 1. Configurar Variables



```bash

cd terraform**AWS:**cd frontend```powershell

cp terraform.tfvars.example terraform.tfvars

# Editar terraform.tfvars con tu DATABASE_URL- Lambda (3 funciones)

```

- API Gateway (2 APIs)flutter run -d windows.\start_frontend.ps1

### 2. Desplegar Infraestructura

- SNS (1 topic)

```bash

terraform init- SQS (2 queues con DLQ)``````

terraform plan

terraform apply- Amazon SES

```

- CloudWatch

Esto despliega:

- ALB con DNS público- IAM

- 3 Lambda Functions

- VPC con Multi-AZ---### 💻 Opción 3: Comandos Manuales

- CloudWatch monitoring

- SNS/SQS/SES messaging**Infraestructura:**



### 3. Verificar Deployment- Terraform



```bash- 35 recursos AWS

# Ver ALB

aws elbv2 describe-load-balancers --names crud-app-alb## Características Principales**Terminal 1 - Backend:**



# Probar endpoint## Requisitos Previos

curl http://crud-app-alb-XXXXXXXXX.us-east-1.elb.amazonaws.com/empleados

``````powershell



## Comandos Útiles- Python 3.11



### Terraform- Flutter 3.x### Backend (FastAPI + Python)cd backend



```bash- AWS CLI

# Ver recursos desplegados

terraform state list- Terraform 1.x- Autenticación con JWTpython -m uvicorn main:app --reload



# Ver outputs

terraform output

## Instalación- API REST completa con async/await```

# Destruir infraestructura

terraform destroy

```

### 1. Clonar el Repositorio- PostgreSQL (Supabase) en producción

### AWS CLI

```bash

```bash

# Ver Lambda Functionsgit clone <repository-url>- Documentación automática (Swagger)**Terminal 2 - Frontend:**

aws lambda list-functions --query "Functions[?contains(FunctionName, 'crud-app')]"

cd CrudEmpleados

# Ver logs de Lambda CRUD

aws logs tail /aws/lambda/crud-app-crud-lambda --follow```- Upload de imágenes con validación```powershell



# Estado del ALB

aws elbv2 describe-load-balancers --names crud-app-alb

### 2. Instalar Dependencias Backend- CORS configuradocd frontend

# Health de targets

aws elbv2 describe-target-health --target-group-arn <ARN>```powershell

```

cd backendflutter run -d windows  # O: flutter run -d chrome

### Prueba de Carga

pip install -r requirements.txt

```powershell

.\test_carga_v2.ps1```### Frontend (Flutter + Dart)```

```



Ejecuta 50 requests secuenciales al ALB y muestra métricas de performance.

### 3. Instalar Dependencias BFF- Arquitectura MVVM (Model-View-ViewModel)

## Documentación

```powershell

- **TAREA2_ENTREGA_FINAL.md** - Documento completo de Tarea 2 (Load Balancing)

- **COMANDOS_ALB.md** - Comandos para gestionar ALBcd ../bff- Login con persistencia de tokens (SharedPreferences)---

- **GUIA_INSTALACION.md** - Guía de instalación completa

- **docs/** - Documentación técnica adicionalpip install -r requirements.txt



## Costos AWS```- Concurrencia medible (Future.wait vs secuencial)



### Servicios con Costo



- **ALB:** $0.0225/hora (~$16/mes)### 4. Instalar Dependencias Frontend- Gestión de estado con Provider## 📋 Características Principales



### Servicios Free Tier```powershell



- Lambda (1M requests/mes)cd ../frontend- UI Material Design 3

- API Gateway (1M requests/mes)

- SNS (1M publishes/mes)flutter pub get

- SQS (1M requests/mes)

- CloudWatch (10 métricas, 5 alarmas)```- Selección y upload de imágenes### ✅ **Backend FastAPI (Python)**



**Total estimado:** ~$16-20/mes



### Optimización## Ejecución- ✨ Autenticación con JWT (30 min expiration)



Para minimizar costos después de desarrollo:



```bash### Opción 1: Script Automatizado (Recomendado)### Arquitectura AWS- 🔄 API REST completa (CRUD)

# Destruir solo el ALB

terraform destroy -target=aws_lb.crud_alb```powershell



# O destruir todo.\EJECUTAR_TODO.ps1- API Gateway con API Key- 💾 SQLite (desarrollo) / PostgreSQL (producción)

terraform destroy

``````



## Resultados de Pruebas- SNS (Simple Notification Service)- ⚡ Endpoints async/await



### Prueba de Carga (50 requests)Este script inicia:



```- Backend en puerto 8000- SQS (Simple Queue Service) + Dead Letter Queue- 🌐 CORS configurado

Success Rate: 100%

Latencia Promedio: 221.78ms- BFF en puerto 8001

P50: 189ms

P90: 285ms- Frontend Flutter- Lambda Functions (Python 3.11)- 📚 Documentación automática (Swagger)

Throughput: 4.48 req/seg

```



### Métricas Lambda### Opción 2: Manual- CloudWatch Logs- 📸 **Upload de imágenes** con validación (5MB máx)



```

Cold start: ~2 segundos

Warm execution: 150-220ms**Backend:**- Infraestructura como código (Terraform)- 📁 Servicio de archivos estáticos

Concurrent executions: Auto-scaling 0-1000

Success rate: 93%+```powershell

```

cd backend

## Características Implementadas

$env:DATABASE_URL="postgresql://postgres.fnokvvuodtuewfasqrvp:e0dFVQPJeZLdLAV2@aws-1-us-east-2.pooler.supabase.com:6543/postgres"

### Alta Disponibilidad

- Multi-AZ deployment (us-east-1a, us-east-1b)python -m uvicorn main:app --reload---### ✅ **Frontend Flutter (Dart)**

- Health checks automáticos

- Auto-scaling serverless```



### Seguridad- 🏛️ **Arquitectura MVVM** (Model-View-ViewModel)

- Security Groups restrictivos

- IAM roles con permisos mínimos**BFF:**

- JWT authentication (en desarrollo local)

```powershell## Estructura del Proyecto- 🔐 Login con validación y persistencia de tokens

### Monitoreo

- CloudWatch Dashboardcd bff

- Alarmas configuradas:

  - ALB 5XX errors$env:PUBLISH_API_URL="https://bnxlpofo59.execute-api.us-east-1.amazonaws.com/dev/publish"- 🏃‍♂️ **Concurrencia medible** (Future.wait vs secuencial)

  - Response time > 1s

  - Unhealthy targets$env:PUBLISH_API_KEY="eCR8TZw9xf6zHrf5so2sE3vhKIxKJbqk9BqE4vgJ"

  - Lambda errors

  - High concurrencypython -m uvicorn main:app --reload --port 8001```- 🔄 Actualización automática con Provider



### Integración```

- CRUD completo (GET, POST, PUT, DELETE)

- Notificaciones email automáticasCrudEmpleados/- 🎨 UI Material Design 3

- Logs centralizados en CloudWatch

**Frontend:**

## Recursos AWS Desplegados

```powershell├── backend/                    # API FastAPI- 💾 Gestión de estado con ChangeNotifier

**Total:** 51 recursos

cd frontend

- 1 VPC

- 2 Subnetsflutter run -d windows│   ├── main.py                # Endpoints REST- 📷 **Selección de imágenes** (galería/cámara)

- 1 Internet Gateway

- 2 Route Tables```

- 1 Security Group

- 1 Application Load Balancer│   ├── models.py              # SQLAlchemy + Pydantic- 🖼️ Vista previa y subida de fotos

- 1 Target Group

- 1 Listener## Despliegue AWS

- 3 Lambda Functions

- 2 API Gateways│   ├── auth.py                # JWT

- 1 SNS Topic

- 2 SQS Queues### Configurar AWS CLI

- 5 CloudWatch Alarms

- 1 CloudWatch Dashboard```powershell│   ├── database.py            # PostgreSQL (Supabase)### 🎯 **Criterios de Evaluación (10 puntos)**

- 10+ IAM Roles/Policies

aws configure

## Tecnologías

```│   └── requirements.txt- ✅ **Arquitectura MVVM** - Separación View/ViewModel/Repository (2 pts)

**Backend:**

- FastAPI (desarrollo)

- Python 3.11

- SQLAlchemy### Desplegar Infraestructura│- ✅ **Concurrencia medible** - Demo con tiempos visibles (2 pts)

- PostgreSQL (Supabase)

- JWT Authentication```powershell



**Frontend:**cd terraform├── frontend/lib/              # Flutter App- ✅ **Login con Backend** - JWT + persistencia (2 pts)

- Flutter

- Provider (state management)terraform init

- HTTP client

terraform apply│   ├── models/                # Data models- ✅ **CRUD funcional** - CREATE, READ, UPDATE, DELETE (2 pts)

**Infrastructure:**

- Terraform```

- AWS Lambda

- Application Load Balancer│   ├── repositories/          # Data access layer- ✅ **Documentación completa** - Evidencias y guías (2 pts)

- API Gateway

- SNS/SQS/SES## Endpoints

- CloudWatch

│   ├── viewmodels/            # Business logic

## Referencias

### Backend Local

- ALB DNS: Obtener con `terraform output alb_dns_name`

- Region: us-east-1- API: http://localhost:8000│   └── screens/               # UI (Views)## 🏗️ Arquitectura MVVM

- Repositorio: GitHub/alex008c/CrudEmpleados

- Documentación: http://localhost:8000/docs

## Autor

│

Proyecto universitario - Sistema de gestión de empleados con arquitectura serverless AWS

### BFF Local

---

- API: http://localhost:8001├── bff/                       # Backend For Frontend```

**Última actualización:** 4 de Noviembre de 2025  

**Estado:** Producción - 51 recursos AWS activos- Documentación: http://localhost:8001/docs


│   ├── main.py               # FastAPI middlewareCrudEmpleados/

### AWS

- API Gateway Email: https://bnxlpofo59.execute-api.us-east-1.amazonaws.com/dev/publish│   └── requirements.txt├── backend/                    # API FastAPI (Python)

- API Gateway CRUD: https://sv2ern4elf.execute-api.us-east-1.amazonaws.com/

- CloudWatch Logs: `/aws/lambda/crud-app-email-lambda`││   ├── main.py                # Endpoints REST



## Estructura del Proyecto├── terraform/                 # Infrastructure as Code│   ├── models.py              # Modelos SQLAlchemy + Pydantic



```│   ├── main.tf│   ├── auth.py                # JWT generation/validation

CrudEmpleados/

├── backend/              # API FastAPI con CRUD│   ├── vpc.tf│   ├── database.py            # DB config (SQLite/PostgreSQL)

│   ├── main.py

│   ├── auth.py│   ├── crud_backend.tf│   └── requirements.txt       # Dependencias Python

│   ├── models.py

│   ├── database.py│   ├── messaging.tf│

│   └── requirements.txt

├── bff/                  # Backend For Frontend│   └── api_gateway_email.tf├── frontend/                  # Aplicación Flutter (Dart)

│   ├── main.py

│   └── requirements.txt││   ├── lib/

├── frontend/             # Aplicación Flutter

│   ├── lib/└── infra/lambdas/            # AWS Lambda Functions│   │   ├── main.dart         # MultiProvider setup

│   │   ├── models/

│   │   ├── repositories/    ├── publisher_lambda/│   │   ├── models/

│   │   ├── viewmodels/

│   │   └── screens/    └── email_lambda/│   │   │   └── empleado.dart # Data model

│   └── pubspec.yaml

├── terraform/            # Infraestructura AWS```│   │   ├── repositories/     # 📁 DATA LAYER

│   ├── main.tf

│   ├── api_gateway_email.tf│   │   │   ├── auth_repository.dart      # Login, tokens

│   ├── messaging.tf

│   └── crud_backend_simple.tf---│   │   │   └── empleado_repository.dart  # CRUD + concurrencia

├── infra/

│   └── lambdas/         # Funciones Lambda│   │   ├── viewmodels/       # 📁 BUSINESS LOGIC

│       ├── publisher_lambda/

│       ├── email_lambda/## Arquitectura MVVM│   │   │   ├── auth_viewmodel.dart       # Auth state

│       └── crud_backend/

└── EJECUTAR_TODO.ps1    # Script de ejecución│   │   │   └── empleado_viewmodel.dart   # CRUD coordination

```

**View (Screens):**│   │   └── screens/          # 📁 UI LAYER (VIEWS)

## Funcionalidades

- Renderiza UI│   │       ├── login_screen.dart         # Consumer<AuthViewModel>

### Backend CRUD

- Registro de usuarios- Captura eventos del usuario│   │       ├── home_screen.dart          # Consumer<EmpleadoViewModel>

- Login con JWT

- CRUD completo de empleados- No contiene lógica de negocio│   │       └── empleado_form_screen.dart # Create/Edit form

- Passwords hasheados con bcrypt

│   └── pubspec.yaml          # Dependencias

### Servicio de Correo

- Envío asíncrono mediante SNS/SQS**ViewModel:**│

- Procesamiento con Lambda

- Envío real con Amazon SES- Gestiona estado de la UI├── docs/                      # 📚 Documentación

- Dead Letter Queue para errores

- Logs en CloudWatch- Coordina operaciones│   ├── INDICE.md             # Índice completo



### Frontend- Notifica cambios a las Views│   ├── EVIDENCIAS.md         # ⭐ EVIDENCIAS DE EVALUACIÓN

- Autenticación de usuarios

- Gestión de empleados (crear, listar, editar, eliminar)│   ├── GUIA_DESARROLLADORES.md  # Guía técnica

- Envío de correos electrónicos

- Interfaz responsive**Repository:**│   ├── DOCUMENTACION.md      # Arquitectura detallada



## Seguridad- Maneja peticiones HTTP│   └── ...más docs



- Autenticación JWT con expiración- Persistencia local│

- Passwords hasheados con bcrypt

- API Key para API Gateway- Abstrae la fuente de datos└── Scripts de inicio          # 🚀 Automatización

- Tokens almacenados de forma segura

- Variables de entorno para credenciales    ├── start_all.ps1         # Inicia todo automáticamente



## Monitoreo**Model:**    ├── start_backend.ps1     # Solo backend



Los logs de las funciones Lambda están disponibles en CloudWatch:- Estructuras de datos    └── start_frontend.ps1    # Solo frontend

- `/aws/lambda/crud-app-publisher-lambda`

- `/aws/lambda/crud-app-email-lambda`- Serialización JSON```

- `/aws/lambda/crud-app-backend-lambda`



## Recursos AWS Desplegados

------

Total: 35 recursos



**Lambda Functions:**

- publisher-lambda## Flujo de Arquitectura Cloud## 🔧 Instalación (Solo primera vez)

- email-lambda

- crud-backend-lambda



**API Gateway:**```### **Requisitos:**

- REST API (servicio email)

- HTTP API (backend CRUD)Frontend- Python 3.11+



**Mensajería:**    ↓- Flutter 3.0+

- SNS Topic (email-topic)

- SQS Queue (email-queue)BFF (Backend For Frontend)- VS Code (recomendado)

- SQS DLQ (email-dlq)

    ↓

**Monitoreo:**

- 3 CloudWatch Log GroupsAPI Gateway (x-api-key)### **Instalación automática:**



**IAM:**    ↓Ejecuta cualquier script de inicio y las dependencias se instalarán automáticamente:

- Roles y políticas para Lambda

- Permisos para SNS, SQS y SESLambda Publisher```powershell



## Costos    ↓.\start_all.ps1



El proyecto utiliza la capa gratuita de AWS:SNS Topic```

- Lambda: 1M invocaciones/mes gratis

- SNS: 1M publicaciones/mes gratis    ↓DATABASE_URL = "postgresql://usuario:password@localhost:5432/empleados_db"

- SQS: 1M requests/mes gratis

- API Gateway: 1M llamadas/mes gratisSQS Queue → Dead Letter Queue```

- SES: 62,000 emails/mes gratis

- CloudWatch: 5GB logs/mes gratis    ↓



Para uso universitario: Costo $0Lambda Email**Opción B: SQLite (Rápido para desarrollo)**



## Guía de Presentación    ↓



### Preparación (1 minuto antes)CloudWatch LogsEdita `database.py` línea 6:

1. Ejecutar `.\EJECUTAR_TODO.ps1`

2. Esperar a que Flutter inicie```

3. Abrir AWS Console en CloudWatch

```python

### Demostración (3 minutos)

1. **Minuto 1:** Login y CRUD de empleados---DATABASE_URL = "sqlite:///./empleados.db"

2. **Minuto 2:** Enviar correo mediante modal

3. **Minuto 3:** Mostrar logs en CloudWatch```



### Puntos Clave a Mencionar## Despliegue en AWS

- Arquitectura desacoplada y asíncrona

- 35 recursos AWS con Terraform#### 3. Ejecutar el servidor

- Dead Letter Queue para confiabilidad

- Infrastructure as Code### Requisitos

- Serverless y auto-escalable

- AWS CLI configurado```powershell

## Troubleshooting

- Terraform instaladouvicorn main:app --reload --host 0.0.0.0 --port 8000

**Error de conexión en puerto 8001:**

- Verificar que el BFF esté ejecutándose- Python 3.11+```

- Revisar que no haya otro proceso en el puerto

- Flutter SDK

**Backend no responde:**

- Verificar DATABASE_URLEl backend estará en: `http://localhost:8000`

- Confirmar que PostgreSQL está accesible

### Pasos

**Flutter no compila:**

- Ejecutar `flutter clean`Documentación interactiva: `http://localhost:8000/docs`

- Ejecutar `flutter pub get`

- Verificar `flutter doctor`1. **Desplegar infraestructura:**



**AWS no muestra logs:**```powershell### **Frontend (Flutter)**

- Esperar 10-15 segundos

- Refrescar CloudWatchcd terraform

- Verificar región us-east-1

terraform init#### 1. Instalar Flutter

## Licencia

terraform apply

Este es un proyecto académico desarrollado para fines educativos.

```Descarga desde: https://flutter.dev/docs/get-started/install

## Autor



Proyecto desarrollado para la asignatura de Cloud Computing.

2. **Configurar BFF:**#### 2. Verificar instalación

---

```powershell

**Última actualización:** Noviembre 2025

**Estado:** Producción# Copiar outputs de Terraform```powershell

**Versión:** 1.0.0

terraform output email_api_urlflutter doctor

terraform output email_api_key```



# Configurar variables de entorno#### 3. Instalar dependencias

$env:PUBLISH_API_URL = "https://..."

$env:PUBLISH_API_KEY = "..."```powershell

```cd frontend

flutter pub get

3. **Iniciar BFF:**```

```powershell

cd bff#### 4. Configurar URL del backend

pip install -r requirements.txt

uvicorn main:app --reload --port 8001Edita `lib/services/api_service.dart` línea 9:

```

```dart

4. **Probar el flujo completo:**static const String baseUrl = 'http://TU_IP:8000';

- Ejecutar frontend```

- Usar modal de envío de correo

- Verificar logs en CloudWatch**Nota importante:**

- Para Android emulator: usa `http://10.0.2.2:8000`

Ver documentación completa en: `docs/DESPLIEGUE_AWS.md`- Para iOS simulator: usa `http://localhost:8000`

- Para dispositivo físico: usa tu IP local (ej: `http://192.168.1.100:8000`)

---

#### 5. Ejecutar la aplicación

## Endpoints API

```powershell

### Autenticaciónflutter run

- `POST /auth/register` - Registro de usuarios```

- `POST /auth/login` - Login (retorna JWT)

O presiona **F5** en VS Code con el dispositivo/emulador conectado.

### CRUD Empleados (requiere JWT)

- `GET /empleados` - Listar empleados (paginado)## 🔐 Uso del Sistema

- `GET /empleados/{id}` - Obtener empleado

- `POST /empleados` - Crear empleado### 1. Primera vez - Registrar usuario

- `PUT /empleados/{id}` - Actualizar empleado

- `DELETE /empleados/{id}` - Eliminar empleado1. Abre la app Flutter

2. Clic en "¿No tienes cuenta? Regístrate"

### Archivos3. Ingresa usuario y contraseña

- `POST /upload-image` - Subir imagen (5MB máx)4. Luego haz login normalmente



### Mensajería (BFF)### 2. Login

- `POST /notify/email` - Enviar correo (vía SNS/SQS)

- Usuario: `tu_usuario`

---- Contraseña: `tu_contraseña`



## Variables de Entorno### 3. Operaciones CRUD



### Backend- **Crear**: Botón `+` flotante

```powershell- **Leer**: Lista principal (pull to refresh)

$env:DATABASE_URL = "postgresql://user:pass@host:port/db"- **Actualizar**: Clic en lápiz o en la tarjeta

```- **Eliminar**: Clic en icono de basura



### BFF### 4. Demo de carga paralela

```powershell

$env:PUBLISH_API_URL = "https://api-id.execute-api.region.amazonaws.com/stage/publish"- Botón de sincronización ⟳ en el AppBar

$env:PUBLISH_API_KEY = "your-api-key"- Carga múltiples empleados simultáneamente usando `Future.wait`

```

## 📡 Endpoints de la API

---

### Autenticación

## Tecnologías

```

**Backend:**POST /auth/login       - Login (retorna JWT)

- FastAPI, UvicornPOST /auth/register    - Registro de usuario

- SQLAlchemy, psycopg2-binary```

- PyJWT, passlib[bcrypt]

### CRUD Empleados (requieren token JWT)

**Frontend:**

- Flutter, Provider```

- http, shared_preferencesGET    /empleados           - Listar todos

- image_pickerGET    /empleados/{id}      - Obtener uno

POST   /empleados           - Crear nuevo

**Infrastructure:**PUT    /empleados/{id}      - Actualizar

- TerraformDELETE /empleados/{id}      - Eliminar

- AWS (Lambda, API Gateway, SNS, SQS, CloudWatch)```

- Docker (para despliegue)

## 🧪 Pruebas Rápidas

---

### Probar Backend con curl:

## Documentación

```powershell

- `docs/DESPLIEGUE_AWS.md` - Guía completa de despliegue# Registrar usuario

- `docs/GUIA_DESARROLLADORES.md` - Para desarrolladores nuevoscurl -X POST http://localhost:8000/auth/register -H "Content-Type: application/json" -d '{\"username\":\"admin\",\"password\":\"admin123\"}'

- `docs/INDICE.md` - Índice de documentación

- `docs/EVIDENCIAS.md` - Diagramas y capturas# Login

curl -X POST http://localhost:8000/auth/login -H "Content-Type: application/json" -d '{\"username\":\"admin\",\"password\":\"admin123\"}'

---

# Usar el token recibido

## Autorcurl -X GET http://localhost:8000/empleados -H "Authorization: Bearer TU_TOKEN_AQUI"

```

Proyecto universitario - Arquitectura Cloud con Terraform

## 🐛 Solución de Problemas

## Licencia

### Backend no inicia

MIT

- Verifica que instalaste todas las dependencias: `pip install -r requirements.txt`
- Verifica la conexión a la base de datos en `database.py`
- Revisa los logs en la terminal

### Flutter no compila

- Ejecuta: `flutter clean && flutter pub get`
- Verifica que tengas Flutter instalado: `flutter doctor`

### No se conecta al backend

- Verifica que el backend esté corriendo
- Verifica la URL en `api_service.dart`
- Para Android: usa `10.0.2.2` en lugar de `localhost`

### Error de CORS

- Ya está configurado en `main.py`, pero si usas otro dominio, agrégalo en `allow_origins`

## 📚 Recursos Adicionales

- [📑 Índice de Documentación](docs/INDICE.md) - Navegación completa
- [⚡ Inicio Rápido](docs/INICIO_RAPIDO.md) - Setup en 10 minutos
- [🎓 Guía para Principiantes](docs/GUIA_PRINCIPIANTES.md) - Explicación didáctica
- [🔧 Documentación Técnica](docs/DOCUMENTACION.md) - Detalles completos
- [💻 Ejemplos de Código](docs/EJEMPLOS_CODIGO.md) - Código comentado
- [📊 Estructura del Proyecto](docs/ESTRUCTURA.md) - Vista general
- [✅ Características](docs/FEATURES.md) - Lista completa
- [❓ FAQ](docs/FAQ.md) - Preguntas frecuentes
- [Documentación FastAPI](https://fastapi.tiangolo.com/)
- [Documentación Flutter](https://flutter.dev/docs)

## 👨‍💻 Desarrollo

### Tecnologías utilizadas

**Backend:**
- FastAPI 0.104
- SQLAlchemy 2.0
- PostgreSQL / SQLite
- JWT (python-jose)
- Uvicorn

**Frontend:**
- Flutter 3.0+
- Dart 3.0+
- http package
- shared_preferences

## 📝 Notas Importantes

1. **Seguridad**: Cambia `SECRET_KEY` en `auth.py` antes de producción
2. **Base de datos**: Las tablas se crean automáticamente al iniciar el backend
3. **Tokens**: Expiran en 30 minutos (configurable en `auth.py`)
4. **CORS**: En producción, especifica los orígenes permitidos exactos

---

**¡Listo para usar! 🎉**

📖 **Para más información, consulta la [documentación completa en la carpeta docs/](docs/INDICE.md)**

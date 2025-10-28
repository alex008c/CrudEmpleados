# CRUD Empleados - Flutter + FastAPI + AWS# 🚀 CRUD Empleados - Flutter + FastAPI



Sistema completo de gestión de empleados con arquitectura MVVM, autenticación JWT, operaciones CRUD asíncronas y arquitectura cloud desacoplada en AWS.Sistema completo de gestión de empleados con **arquitectura MVVM**, autenticación JWT, operaciones CRUD y concurrencia medible con Future.wait.



## Inicio Rápido## ⚡ Inicio Rápido



### Desarrollo Local### 🎯 Opción 1: Script Automático (TODO EN UNO)

```powershell

**Script automático (Backend + Frontend):**.\start_all.ps1

```powershell```

.\dev.ps1Este script inicia backend y frontend automáticamente en terminales separadas.

```

### 🔧 Opción 2: Scripts Individuales (2 TERMINALES)

**Solo Backend:**

```powershell**Terminal 1 - Backend:**

.\run_backend.ps1```powershell

```.\start_backend.ps1

```

**Solo Frontend:**

```powershell**Terminal 2 - Frontend:**

cd frontend```powershell

flutter run -d windows.\start_frontend.ps1

``````



---### 💻 Opción 3: Comandos Manuales



## Características Principales**Terminal 1 - Backend:**

```powershell

### Backend (FastAPI + Python)cd backend

- Autenticación con JWTpython -m uvicorn main:app --reload

- API REST completa con async/await```

- PostgreSQL (Supabase) en producción

- Documentación automática (Swagger)**Terminal 2 - Frontend:**

- Upload de imágenes con validación```powershell

- CORS configuradocd frontend

flutter run -d windows  # O: flutter run -d chrome

### Frontend (Flutter + Dart)```

- Arquitectura MVVM (Model-View-ViewModel)

- Login con persistencia de tokens (SharedPreferences)---

- Concurrencia medible (Future.wait vs secuencial)

- Gestión de estado con Provider## 📋 Características Principales

- UI Material Design 3

- Selección y upload de imágenes### ✅ **Backend FastAPI (Python)**

- ✨ Autenticación con JWT (30 min expiration)

### Arquitectura AWS- 🔄 API REST completa (CRUD)

- API Gateway con API Key- 💾 SQLite (desarrollo) / PostgreSQL (producción)

- SNS (Simple Notification Service)- ⚡ Endpoints async/await

- SQS (Simple Queue Service) + Dead Letter Queue- 🌐 CORS configurado

- Lambda Functions (Python 3.11)- 📚 Documentación automática (Swagger)

- CloudWatch Logs- 📸 **Upload de imágenes** con validación (5MB máx)

- Infraestructura como código (Terraform)- 📁 Servicio de archivos estáticos



---### ✅ **Frontend Flutter (Dart)**

- 🏛️ **Arquitectura MVVM** (Model-View-ViewModel)

## Estructura del Proyecto- 🔐 Login con validación y persistencia de tokens

- 🏃‍♂️ **Concurrencia medible** (Future.wait vs secuencial)

```- 🔄 Actualización automática con Provider

CrudEmpleados/- 🎨 UI Material Design 3

├── backend/                    # API FastAPI- 💾 Gestión de estado con ChangeNotifier

│   ├── main.py                # Endpoints REST- 📷 **Selección de imágenes** (galería/cámara)

│   ├── models.py              # SQLAlchemy + Pydantic- 🖼️ Vista previa y subida de fotos

│   ├── auth.py                # JWT

│   ├── database.py            # PostgreSQL (Supabase)### 🎯 **Criterios de Evaluación (10 puntos)**

│   └── requirements.txt- ✅ **Arquitectura MVVM** - Separación View/ViewModel/Repository (2 pts)

│- ✅ **Concurrencia medible** - Demo con tiempos visibles (2 pts)

├── frontend/lib/              # Flutter App- ✅ **Login con Backend** - JWT + persistencia (2 pts)

│   ├── models/                # Data models- ✅ **CRUD funcional** - CREATE, READ, UPDATE, DELETE (2 pts)

│   ├── repositories/          # Data access layer- ✅ **Documentación completa** - Evidencias y guías (2 pts)

│   ├── viewmodels/            # Business logic

│   └── screens/               # UI (Views)## 🏗️ Arquitectura MVVM

│

├── bff/                       # Backend For Frontend```

│   ├── main.py               # FastAPI middlewareCrudEmpleados/

│   └── requirements.txt├── backend/                    # API FastAPI (Python)

││   ├── main.py                # Endpoints REST

├── terraform/                 # Infrastructure as Code│   ├── models.py              # Modelos SQLAlchemy + Pydantic

│   ├── main.tf│   ├── auth.py                # JWT generation/validation

│   ├── vpc.tf│   ├── database.py            # DB config (SQLite/PostgreSQL)

│   ├── crud_backend.tf│   └── requirements.txt       # Dependencias Python

│   ├── messaging.tf│

│   └── api_gateway_email.tf├── frontend/                  # Aplicación Flutter (Dart)

││   ├── lib/

└── infra/lambdas/            # AWS Lambda Functions│   │   ├── main.dart         # MultiProvider setup

    ├── publisher_lambda/│   │   ├── models/

    └── email_lambda/│   │   │   └── empleado.dart # Data model

```│   │   ├── repositories/     # 📁 DATA LAYER

│   │   │   ├── auth_repository.dart      # Login, tokens

---│   │   │   └── empleado_repository.dart  # CRUD + concurrencia

│   │   ├── viewmodels/       # 📁 BUSINESS LOGIC

## Arquitectura MVVM│   │   │   ├── auth_viewmodel.dart       # Auth state

│   │   │   └── empleado_viewmodel.dart   # CRUD coordination

**View (Screens):**│   │   └── screens/          # 📁 UI LAYER (VIEWS)

- Renderiza UI│   │       ├── login_screen.dart         # Consumer<AuthViewModel>

- Captura eventos del usuario│   │       ├── home_screen.dart          # Consumer<EmpleadoViewModel>

- No contiene lógica de negocio│   │       └── empleado_form_screen.dart # Create/Edit form

│   └── pubspec.yaml          # Dependencias

**ViewModel:**│

- Gestiona estado de la UI├── docs/                      # 📚 Documentación

- Coordina operaciones│   ├── INDICE.md             # Índice completo

- Notifica cambios a las Views│   ├── EVIDENCIAS.md         # ⭐ EVIDENCIAS DE EVALUACIÓN

│   ├── GUIA_DESARROLLADORES.md  # Guía técnica

**Repository:**│   ├── DOCUMENTACION.md      # Arquitectura detallada

- Maneja peticiones HTTP│   └── ...más docs

- Persistencia local│

- Abstrae la fuente de datos└── Scripts de inicio          # 🚀 Automatización

    ├── start_all.ps1         # Inicia todo automáticamente

**Model:**    ├── start_backend.ps1     # Solo backend

- Estructuras de datos    └── start_frontend.ps1    # Solo frontend

- Serialización JSON```



------



## Flujo de Arquitectura Cloud## 🔧 Instalación (Solo primera vez)



```### **Requisitos:**

Frontend- Python 3.11+

    ↓- Flutter 3.0+

BFF (Backend For Frontend)- VS Code (recomendado)

    ↓

API Gateway (x-api-key)### **Instalación automática:**

    ↓Ejecuta cualquier script de inicio y las dependencias se instalarán automáticamente:

Lambda Publisher```powershell

    ↓.\start_all.ps1

SNS Topic```

    ↓DATABASE_URL = "postgresql://usuario:password@localhost:5432/empleados_db"

SQS Queue → Dead Letter Queue```

    ↓

Lambda Email**Opción B: SQLite (Rápido para desarrollo)**

    ↓

CloudWatch LogsEdita `database.py` línea 6:

```

```python

---DATABASE_URL = "sqlite:///./empleados.db"

```

## Despliegue en AWS

#### 3. Ejecutar el servidor

### Requisitos

- AWS CLI configurado```powershell

- Terraform instaladouvicorn main:app --reload --host 0.0.0.0 --port 8000

- Python 3.11+```

- Flutter SDK

El backend estará en: `http://localhost:8000`

### Pasos

Documentación interactiva: `http://localhost:8000/docs`

1. **Desplegar infraestructura:**

```powershell### **Frontend (Flutter)**

cd terraform

terraform init#### 1. Instalar Flutter

terraform apply

```Descarga desde: https://flutter.dev/docs/get-started/install



2. **Configurar BFF:**#### 2. Verificar instalación

```powershell

# Copiar outputs de Terraform```powershell

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

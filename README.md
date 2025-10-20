# 🚀 CRUD Empleados - Flutter + FastAPI

Sistema completo de gestión de empleados con **arquitectura MVVM**, autenticación JWT, operaciones CRUD y concurrencia medible con Future.wait.

## ⚡ Inicio Rápido

### 🎯 Opción 1: Script Automático (TODO EN UNO)
```powershell
.\start_all.ps1
```
Este script inicia backend y frontend automáticamente en terminales separadas.

### 🔧 Opción 2: Scripts Individuales (2 TERMINALES)

**Terminal 1 - Backend:**
```powershell
.\start_backend.ps1
```

**Terminal 2 - Frontend:**
```powershell
.\start_frontend.ps1
```

### 💻 Opción 3: Comandos Manuales

**Terminal 1 - Backend:**
```powershell
cd backend
python -m uvicorn main:app --reload
```

**Terminal 2 - Frontend:**
```powershell
cd frontend
flutter run -d windows  # O: flutter run -d chrome
```

---

## 📋 Características Principales

### ✅ **Backend FastAPI (Python)**
- ✨ Autenticación con JWT (30 min expiration)
- 🔄 API REST completa (CRUD)
- 💾 SQLite (desarrollo) / PostgreSQL (producción)
- ⚡ Endpoints async/await
- 🌐 CORS configurado
- 📚 Documentación automática (Swagger)
- 📸 **Upload de imágenes** con validación (5MB máx)
- 📁 Servicio de archivos estáticos

### ✅ **Frontend Flutter (Dart)**
- 🏛️ **Arquitectura MVVM** (Model-View-ViewModel)
- 🔐 Login con validación y persistencia de tokens
- 🏃‍♂️ **Concurrencia medible** (Future.wait vs secuencial)
- 🔄 Actualización automática con Provider
- 🎨 UI Material Design 3
- 💾 Gestión de estado con ChangeNotifier
- 📷 **Selección de imágenes** (galería/cámara)
- 🖼️ Vista previa y subida de fotos

### 🎯 **Criterios de Evaluación (10 puntos)**
- ✅ **Arquitectura MVVM** - Separación View/ViewModel/Repository (2 pts)
- ✅ **Concurrencia medible** - Demo con tiempos visibles (2 pts)
- ✅ **Login con Backend** - JWT + persistencia (2 pts)
- ✅ **CRUD funcional** - CREATE, READ, UPDATE, DELETE (2 pts)
- ✅ **Documentación completa** - Evidencias y guías (2 pts)

## 🏗️ Arquitectura MVVM

```
CrudEmpleados/
├── backend/                    # API FastAPI (Python)
│   ├── main.py                # Endpoints REST
│   ├── models.py              # Modelos SQLAlchemy + Pydantic
│   ├── auth.py                # JWT generation/validation
│   ├── database.py            # DB config (SQLite/PostgreSQL)
│   └── requirements.txt       # Dependencias Python
│
├── frontend/                  # Aplicación Flutter (Dart)
│   ├── lib/
│   │   ├── main.dart         # MultiProvider setup
│   │   ├── models/
│   │   │   └── empleado.dart # Data model
│   │   ├── repositories/     # 📁 DATA LAYER
│   │   │   ├── auth_repository.dart      # Login, tokens
│   │   │   └── empleado_repository.dart  # CRUD + concurrencia
│   │   ├── viewmodels/       # 📁 BUSINESS LOGIC
│   │   │   ├── auth_viewmodel.dart       # Auth state
│   │   │   └── empleado_viewmodel.dart   # CRUD coordination
│   │   └── screens/          # 📁 UI LAYER (VIEWS)
│   │       ├── login_screen.dart         # Consumer<AuthViewModel>
│   │       ├── home_screen.dart          # Consumer<EmpleadoViewModel>
│   │       └── empleado_form_screen.dart # Create/Edit form
│   └── pubspec.yaml          # Dependencias
│
├── docs/                      # 📚 Documentación
│   ├── INDICE.md             # Índice completo
│   ├── EVIDENCIAS.md         # ⭐ EVIDENCIAS DE EVALUACIÓN
│   ├── GUIA_DESARROLLADORES.md  # Guía técnica
│   ├── DOCUMENTACION.md      # Arquitectura detallada
│   └── ...más docs
│
└── Scripts de inicio          # 🚀 Automatización
    ├── start_all.ps1         # Inicia todo automáticamente
    ├── start_backend.ps1     # Solo backend
    └── start_frontend.ps1    # Solo frontend
```

---

## 🔧 Instalación (Solo primera vez)

### **Requisitos:**
- Python 3.11+
- Flutter 3.0+
- VS Code (recomendado)

### **Instalación automática:**
Ejecuta cualquier script de inicio y las dependencias se instalarán automáticamente:
```powershell
.\start_all.ps1
```
DATABASE_URL = "postgresql://usuario:password@localhost:5432/empleados_db"
```

**Opción B: SQLite (Rápido para desarrollo)**

Edita `database.py` línea 6:

```python
DATABASE_URL = "sqlite:///./empleados.db"
```

#### 3. Ejecutar el servidor

```powershell
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

El backend estará en: `http://localhost:8000`

Documentación interactiva: `http://localhost:8000/docs`

### **Frontend (Flutter)**

#### 1. Instalar Flutter

Descarga desde: https://flutter.dev/docs/get-started/install

#### 2. Verificar instalación

```powershell
flutter doctor
```

#### 3. Instalar dependencias

```powershell
cd frontend
flutter pub get
```

#### 4. Configurar URL del backend

Edita `lib/services/api_service.dart` línea 9:

```dart
static const String baseUrl = 'http://TU_IP:8000';
```

**Nota importante:**
- Para Android emulator: usa `http://10.0.2.2:8000`
- Para iOS simulator: usa `http://localhost:8000`
- Para dispositivo físico: usa tu IP local (ej: `http://192.168.1.100:8000`)

#### 5. Ejecutar la aplicación

```powershell
flutter run
```

O presiona **F5** en VS Code con el dispositivo/emulador conectado.

## 🔐 Uso del Sistema

### 1. Primera vez - Registrar usuario

1. Abre la app Flutter
2. Clic en "¿No tienes cuenta? Regístrate"
3. Ingresa usuario y contraseña
4. Luego haz login normalmente

### 2. Login

- Usuario: `tu_usuario`
- Contraseña: `tu_contraseña`

### 3. Operaciones CRUD

- **Crear**: Botón `+` flotante
- **Leer**: Lista principal (pull to refresh)
- **Actualizar**: Clic en lápiz o en la tarjeta
- **Eliminar**: Clic en icono de basura

### 4. Demo de carga paralela

- Botón de sincronización ⟳ en el AppBar
- Carga múltiples empleados simultáneamente usando `Future.wait`

## 📡 Endpoints de la API

### Autenticación

```
POST /auth/login       - Login (retorna JWT)
POST /auth/register    - Registro de usuario
```

### CRUD Empleados (requieren token JWT)

```
GET    /empleados           - Listar todos
GET    /empleados/{id}      - Obtener uno
POST   /empleados           - Crear nuevo
PUT    /empleados/{id}      - Actualizar
DELETE /empleados/{id}      - Eliminar
```

## 🧪 Pruebas Rápidas

### Probar Backend con curl:

```powershell
# Registrar usuario
curl -X POST http://localhost:8000/auth/register -H "Content-Type: application/json" -d '{\"username\":\"admin\",\"password\":\"admin123\"}'

# Login
curl -X POST http://localhost:8000/auth/login -H "Content-Type: application/json" -d '{\"username\":\"admin\",\"password\":\"admin123\"}'

# Usar el token recibido
curl -X GET http://localhost:8000/empleados -H "Authorization: Bearer TU_TOKEN_AQUI"
```

## 🐛 Solución de Problemas

### Backend no inicia

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

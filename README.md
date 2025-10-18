# 🚀 CRUD Empleados - Flutter + FastAPI

Sistema completo de gestión de empleados con autenticación JWT, operaciones CRUD y carga paralela de datos.

## 📋 Características

✅ **Backend FastAPI (Python)**
- Autenticación con JWT
- API REST completa (CRUD)
- PostgreSQL / SQLite
- Endpoints async/await
- CORS configurado

✅ **Frontend Flutter (Dart)**
- Login con validación asíncrona
- Carga paralela con Future.wait
- Actualización automática de listas
- UI Material Design
- Gestión de tokens

## 🏗️ Arquitectura del Proyecto

```
CrudEmpleados/
├── backend/                    # API FastAPI (Python)
│   ├── main.py                # Punto de entrada, endpoints
│   ├── models.py              # Modelos SQLAlchemy y Pydantic
│   ├── auth.py                # Autenticación JWT
│   ├── database.py            # Configuración de BD
│   └── requirements.txt       # Dependencias Python
│
├── frontend/                  # Aplicación Flutter (Dart)
│   ├── lib/
│   │   ├── main.dart         # Punto de entrada
│   │   ├── models/
│   │   │   └── empleado.dart # Modelo de datos
│   │   ├── services/
│   │   │   └── api_service.dart  # Cliente HTTP, Future.wait
│   │   └── screens/
│   │       ├── login_screen.dart      # Login async/await
│   │       ├── home_screen.dart       # Lista de empleados
│   │       └── empleado_form_screen.dart  # Formulario CRUD
│   └── pubspec.yaml          # Dependencias Flutter
│
└── docs/                      # 📚 Documentación completa
    ├── INDICE.md             # Índice de toda la documentación
    ├── INICIO_RAPIDO.md      # Setup rápido
    ├── GUIA_PRINCIPIANTES.md # Explicación didáctica
    ├── DOCUMENTACION.md      # Documentación técnica
    ├── EJEMPLOS_CODIGO.md    # Código comentado
    ├── ESTRUCTURA.md         # Vista general
    ├── FEATURES.md           # Características
    └── FAQ.md                # Preguntas frecuentes
```

## 🔧 Instalación y Configuración

### **Backend (FastAPI)**

#### 1. Instalar dependencias de Python

```powershell
cd backend
pip install -r requirements.txt
```

#### 2. Configurar base de datos

**Opción A: PostgreSQL (Recomendado para producción)**

1. Instala PostgreSQL o usa Supabase
2. Crea una base de datos: `empleados_db`
3. Edita `database.py` línea 6:

```python
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

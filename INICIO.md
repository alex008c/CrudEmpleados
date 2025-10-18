# 🚀 Inicio Rápido - CRUD Empleados

## ⚡ Iniciar la Aplicación (2 pasos)

### 1️⃣ Iniciar Backend (Terminal 1)
```powershell
.\start_backend.ps1
```

### 2️⃣ Iniciar Frontend (Terminal 2)
```powershell
.\start_frontend.ps1
```

**¡Y listo!** La aplicación se abrirá automáticamente.

---

## 📋 Requisitos (solo primera vez)

- ✅ **Python 3.11+** instalado
- ✅ **Flutter 3.0+** instalado
- ✅ **VS Code** (recomendado)

Las dependencias se instalan automáticamente la primera vez.

---

## 🔗 URLs Importantes

| Servicio | URL |
|----------|-----|
| 🖥️ **Aplicación Frontend** | Se abre automáticamente |
| 🔧 **API Backend** | http://localhost:8000 |
| 📚 **Documentación API** | http://localhost:8000/docs |
| 💾 **Base de datos** | `backend/empleados.db` (SQLite) |

---

## 🎮 Uso de la Aplicación

### Primer Uso - Registro

1. **Registrar usuario:**
   - Click en "¿No tienes cuenta? Regístrate aquí"
   - Username: `admin`
   - Email: `admin@test.com`
   - Password: `admin123`

2. **Iniciar sesión** con tus credenciales

### Funcionalidades

#### ✨ CRUD de Empleados
- ➕ **Crear**: Botón `+` flotante (esquina inferior derecha)
- ✏️ **Editar**: Ícono de lápiz en cada empleado
- 🗑️ **Eliminar**: Ícono de basura
- 👁️ **Ver lista**: Se actualiza automáticamente

#### 🏃‍♂️ Demo de Concurrencia (Evaluación)
- Click en el botón **⚡ Demo** (flotante inferior derecho)
- Verás un diálogo mostrando:
  - ⏱️ Tiempo secuencial (sin concurrencia)
  - ⚡ Tiempo paralelo (con Future.wait)
  - 📊 Mejora en porcentaje
- **Importante**: Crea al menos 3-5 empleados antes de probar esto

---

## 🛑 Detener la Aplicación

En cada terminal presiona:
```
Ctrl + C
```

---

## 🔄 Comandos Alternativos (Modo Manual)

Si prefieres control total:

### Backend
```powershell
cd backend
python -m uvicorn main:app --reload
```

### Frontend (Windows)
```powershell
cd frontend
flutter run -d windows
```

### Frontend (Chrome)
```powershell
cd frontend
flutter run -d chrome
```

---

## 📸 Captura de Evidencias (para PDF)

### Screenshots recomendados:

1. **Pantalla de Login**
2. **Lista de empleados** (con datos)
3. **Formulario de crear/editar**
4. **Diálogo de Demo Concurrencia** (con tiempos medidos) ⭐
5. **Estructura de carpetas** (MVVM)
6. **Documentación API** (http://localhost:8000/docs)

---

## ⚙️ Configuración de Base de Datos

Por defecto usa **SQLite** (no requiere instalación).

### Cambiar a PostgreSQL (opcional)

Edita `backend/database.py`:

```python
# Descomentar esta línea:
DATABASE_URL = "postgresql://usuario:password@localhost:5432/empleados_db"

# Comentar esta línea:
# DATABASE_URL = "sqlite:///./empleados.db"
```

---

## 🐛 Solución de Problemas

### Error: "Flutter no encontrado"
```powershell
flutter doctor -v
```
Si falla, instala Flutter desde: https://flutter.dev

### Error: "Python no encontrado"
```powershell
python --version
```
Si falla, instala Python 3.11+ desde: https://python.org

### Error: "Puerto 8000 en uso"
Detén el backend anterior con `Ctrl+C` o usa otro puerto:
```powershell
cd backend
python -m uvicorn main:app --reload --port 8001
```

Luego actualiza la URL en `frontend/lib/repositories/auth_repository.dart`:
```dart
final String baseUrl = 'http://localhost:8001';
```

### Base de datos corrupta
Elimina el archivo y reinicia:
```powershell
Remove-Item backend\empleados.db
.\start_backend.ps1
```

---

## 📚 Documentación Completa

- **Arquitectura MVVM**: `docs/DOCUMENTACION.md`
- **Guía para desarrolladores**: `docs/GUIA_DESARROLLADORES.md`
- **Evidencias de evaluación**: `docs/EVIDENCIAS.md`
- **Índice completo**: `docs/INDICE.md`

---

## ✅ Checklist de Evaluación

- ✅ Arquitectura MVVM (View/ViewModel/Repository)
- ✅ Concurrencia medible (Future.wait vs secuencial)
- ✅ Login con JWT (Backend FastAPI)
- ✅ CRUD funcional (CREATE, READ, UPDATE, DELETE)
- ✅ Documentación completa

---

**¡Listo para desarrollar y presentar!** 🎉

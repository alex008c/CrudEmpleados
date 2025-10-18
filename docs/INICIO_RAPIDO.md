# 🚀 INICIO RÁPIDO - Ejecuta Esto Primero

## ⚡ Para Windows (PowerShell)

### 1. Instalar Backend (Solo la primera vez)

```powershell
cd backend
pip install -r requirements.txt
```

### 2. Configurar Base de Datos

**Opción Fácil (SQLite):**

Edita `backend/database.py` línea 6 y cambia a:
```python
DATABASE_URL = "sqlite:///./empleados.db"
```

**Opción Avanzada (PostgreSQL con DBeaver):**

1. Instala PostgreSQL o usa Supabase
2. Abre DBeaver
3. Crea una conexión a PostgreSQL
4. Crea una base de datos llamada `empleados_db`
5. Edita `backend/database.py` línea 6:
```python
DATABASE_URL = "postgresql://usuario:password@localhost:5432/empleados_db"
```

### 3. Iniciar Backend

```powershell
# Desde la carpeta raíz del proyecto:
.\start_backend.ps1

# O manualmente:
cd backend
uvicorn main:app --reload
```

Verifica que funciona: http://localhost:8000/docs

### 4. Configurar Frontend (Solo la primera vez)

```powershell
cd frontend
flutter pub get
```

### 5. Configurar URL del Backend en Flutter

Edita `frontend/lib/services/api_service.dart` línea 9:

**Para emulador Android:**
```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```

**Para simulador iOS:**
```dart
static const String baseUrl = 'http://localhost:8000';
```

**Para dispositivo físico:**
```dart
static const String baseUrl = 'http://TU_IP_LOCAL:8000';  // Ej: http://192.168.1.100:8000
```

Para saber tu IP local:
```powershell
ipconfig
# Busca "Dirección IPv4"
```

### 6. Iniciar Frontend

```powershell
# Desde la carpeta raíz del proyecto:
.\start_frontend.ps1

# O manualmente:
cd frontend
flutter run
```

---

## 📋 Checklist Rápido

### Backend ✅
- [ ] Python instalado
- [ ] Dependencias instaladas: `pip install -r requirements.txt`
- [ ] Base de datos configurada en `database.py`
- [ ] Servidor corriendo: `uvicorn main:app --reload`
- [ ] Puedes acceder a: http://localhost:8000/docs

### Frontend ✅
- [ ] Flutter instalado (verifica con `flutter doctor`)
- [ ] Dependencias instaladas: `flutter pub get`
- [ ] URL correcta en `api_service.dart`
- [ ] Emulador/dispositivo conectado: `flutter devices`
- [ ] App corriendo: `flutter run`

---

## 🧪 Prueba Rápida

### 1. Backend funcionando

Abre: http://localhost:8000

Deberías ver:
```json
{
  "message": "API CRUD Empleados está funcionando correctamente",
  "version": "1.0.0"
}
```

### 2. Crear primer usuario

**Opción A: Desde la app Flutter**
1. Abre la app
2. Clic en "¿No tienes cuenta? Regístrate"
3. Usuario: `admin`, Contraseña: `admin123`

**Opción B: Desde PowerShell con curl**

```powershell
curl -X POST http://localhost:8000/auth/register -H "Content-Type: application/json" -d '{\"username\":\"admin\",\"password\":\"admin123\"}'
```

### 3. Hacer login

En la app Flutter:
- Usuario: `admin`
- Contraseña: `admin123`

Deberías ver la pantalla principal vacía (sin empleados todavía).

### 4. Crear primer empleado

1. Presiona el botón flotante `+`
2. Llena el formulario:
   - Nombre: Juan
   - Apellido: Pérez
   - Puesto: Gerente
   - Salario: 5000
   - Email: juan@example.com
   - Teléfono: 555-1234
3. Presiona "CREAR"

¡Listo! Deberías ver el empleado en la lista.

---

## 🐛 Problemas Comunes

### Backend no inicia

```powershell
# Error: "No module named 'fastapi'"
pip install -r requirements.txt

# Error: "Could not connect to database"
# Verifica DATABASE_URL en backend/database.py
```

### Flutter no compila

```powershell
# Limpiar y reinstalar
flutter clean
flutter pub get
flutter run
```

### No conecta al backend

**Verifica la URL en `lib/services/api_service.dart`**

- ❌ `http://localhost:8000` → No funciona en Android
- ✅ `http://10.0.2.2:8000` → Funciona en Android emulator
- ✅ `http://localhost:8000` → Funciona en iOS simulator
- ✅ `http://192.168.1.X:8000` → Funciona en dispositivo físico (tu IP local)

### Error 401 Unauthorized

- Token expirado (duran 30 min)
- Haz logout y login nuevamente

---

## 📚 Próximos Pasos

1. ✅ Lee el [README.md](README.md) para entender el proyecto completo
2. ✅ Consulta [DOCUMENTACION.md](DOCUMENTACION.md) para detalles técnicos
3. ✅ Revisa [GUIA_PRINCIPIANTES.md](GUIA_PRINCIPIANTES.md) si eres nuevo

---

## 🔑 Credenciales de Prueba

Por defecto, puedes crear cualquier usuario desde la app.

Sugerencia para pruebas:
- **Usuario:** `admin`
- **Contraseña:** `admin123`

---

## 📞 Ayuda Rápida

### Ver logs del backend
Los mensajes se muestran en la terminal donde ejecutaste `uvicorn`

### Ver logs de Flutter
Los mensajes se muestran en la terminal donde ejecutaste `flutter run`

### Reiniciar todo

```powershell
# Backend: Ctrl+C y volver a ejecutar
cd backend
uvicorn main:app --reload

# Frontend: 'r' para hot reload, 'R' para hot restart
# O Ctrl+C y volver a ejecutar
cd frontend
flutter run
```

---

**¡Todo listo! 🎉**

Si algo no funciona, revisa los archivos de documentación mencionados arriba.

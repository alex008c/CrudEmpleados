# ❓ Preguntas Frecuentes (FAQ)

## 📋 General

### ¿Qué hace este proyecto?

Es un sistema completo de gestión de empleados con:
- **Backend**: API REST con FastAPI (Python) y autenticación JWT
- **Frontend**: Aplicación móvil con Flutter (Dart)
- **Funcionalidades**: Login, CRUD completo, carga paralela de datos

### ¿Cumple con los requisitos de la tarea?

✅ **SÍ, 100%**. Incluye:
- Login con async/await (Dart)
- CRUD completo de empleados
- Backend FastAPI con JWT
- Cargar datos en paralelo con Future.wait
- No bloquea la UI
- Animaciones de loading
- Refrescar lista automáticamente

---

## 🔧 Instalación y Configuración

### ¿Qué necesito instalar?

**Backend:**
- Python 3.8+ ([descargar](https://www.python.org/downloads/))
- PostgreSQL (opcional) o usar SQLite

**Frontend:**
- Flutter SDK ([descargar](https://flutter.dev/docs/get-started/install))
- Android Studio / VS Code
- Emulador Android o dispositivo físico

### ¿Cómo instalo las dependencias?

```powershell
# Backend
cd backend
pip install -r requirements.txt

# Frontend
cd frontend
flutter pub get
```

### ¿Cómo configuro la base de datos?

**Opción 1 (Fácil): SQLite**

Edita `backend/database.py` línea 6:
```python
DATABASE_URL = "sqlite:///./empleados.db"
```

**Opción 2 (Producción): PostgreSQL**

1. Instala PostgreSQL o usa Supabase
2. Crea una base de datos: `empleados_db`
3. Edita `backend/database.py`:
```python
DATABASE_URL = "postgresql://usuario:password@localhost:5432/empleados_db"
```

### ¿Cómo ejecuto el proyecto?

```powershell
# Terminal 1: Backend
cd backend
uvicorn main:app --reload

# Terminal 2: Frontend
cd frontend
flutter run
```

O usa los scripts:
```powershell
.\start_backend.ps1
.\start_frontend.ps1
```

---

## 🐛 Problemas Comunes

### Backend no inicia - "No module named 'fastapi'"

**Causa:** Dependencias no instaladas

**Solución:**
```powershell
cd backend
pip install -r requirements.txt
```

### Flutter no conecta - "Connection refused"

**Causa:** URL incorrecta en Flutter

**Solución:** Edita `frontend/lib/services/api_service.dart` línea 9:

- **Android emulator:** `http://10.0.2.2:8000`
- **iOS simulator:** `http://localhost:8000`
- **Dispositivo físico:** `http://TU_IP:8000`

Para saber tu IP:
```powershell
ipconfig  # Busca "Dirección IPv4"
```

### Error 401 Unauthorized

**Causa:** Token JWT expirado o inválido

**Solución:**
1. Cierra sesión en la app
2. Vuelve a hacer login
3. Los tokens duran 30 minutos

### Flutter no compila - "Target of URI doesn't exist"

**Causa:** Dependencias de Flutter no instaladas

**Solución:**
```powershell
cd frontend
flutter clean
flutter pub get
flutter run
```

### Backend error - "Could not connect to database"

**Causa:** Configuración incorrecta de base de datos

**Solución:**
1. Verifica `DATABASE_URL` en `backend/database.py`
2. Si usas PostgreSQL, verifica que el servidor esté corriendo
3. Prueba con SQLite para desarrollo

---

## 🔐 Autenticación y Seguridad

### ¿Cómo funciona el login?

1. Usuario envía credenciales → Backend
2. Backend valida contra la base de datos
3. Backend genera un token JWT
4. Flutter guarda el token
5. Flutter incluye el token en todas las peticiones

### ¿Qué es un token JWT?

Es como una credencial digital que:
- Contiene información del usuario
- Está firmado digitalmente (no se puede falsificar)
- Tiene tiempo de expiración
- Se envía en cada petición para autenticarse

### ¿Las contraseñas están seguras?

✅ **SÍ**. Usamos bcrypt para hashear contraseñas:
- Nunca se guardan en texto plano
- El hash es irreversible
- Incluso el administrador de BD no puede ver las contraseñas

### ¿Cómo registro un nuevo usuario?

**Opción 1 (Desde la app):**
1. Abre la app
2. Clic en "¿No tienes cuenta? Regístrate"
3. Ingresa usuario y contraseña

**Opción 2 (Con curl):**
```powershell
curl -X POST http://localhost:8000/auth/register -H "Content-Type: application/json" -d '{\"username\":\"admin\",\"password\":\"admin123\"}'
```

### ¿Puedo cambiar el tiempo de expiración del token?

Sí, edita `backend/auth.py`:
```python
ACCESS_TOKEN_EXPIRE_MINUTES = 30  # Cambia este valor
```

---

## 💻 Desarrollo

### ¿Dónde está la documentación de la API?

Inicia el backend y ve a: http://localhost:8000/docs

Tendrás una interfaz interactiva donde puedes:
- Ver todos los endpoints
- Probar cada endpoint
- Ver los schemas de datos

### ¿Cómo agrego un nuevo campo al empleado?

1. **Backend** - Edita `backend/models.py`:
```python
class EmpleadoDB(Base):
    # ... campos existentes
    departamento = Column(String)  # ← Nuevo campo

class EmpleadoBase(BaseModel):
    # ... campos existentes
    departamento: str  # ← Nuevo campo
```

2. **Frontend** - Edita `frontend/lib/models/empleado.dart`:
```dart
class Empleado {
    // ... campos existentes
    final String departamento;  // ← Nuevo campo
    
    // Actualizar fromJson y toJson
}
```

3. **UI** - Agrega campo en `empleado_form_screen.dart`

### ¿Cómo funciona Future.wait?

Ejecuta múltiples operaciones asíncronas **en paralelo**:

**Sin Future.wait (lento):**
```dart
var emp1 = await getEmpleado(1);  // 1 segundo
var emp2 = await getEmpleado(2);  // 1 segundo
var emp3 = await getEmpleado(3);  // 1 segundo
// Total: 3 segundos
```

**Con Future.wait (rápido):**
```dart
var empleados = await Future.wait([
    getEmpleado(1),
    getEmpleado(2),
    getEmpleado(3),
]);
// Total: 1 segundo (todos al mismo tiempo)
```

### ¿Qué es async/await?

Permite hacer operaciones largas sin bloquear la UI:

```dart
// Sin async/await (bloquea UI)
void login() {
    var result = apiCall();  // UI congelada aquí
    if (result.success) { ... }
}

// Con async/await (no bloquea UI)
Future<void> login() async {
    var result = await apiCall();  // UI sigue funcionando
    if (result.success) { ... }
}
```

### ¿Por qué usar Dependency Injection?

FastAPI inyecta automáticamente dependencias:

```python
@app.get("/empleados")
async def get_empleados(
    db: Session = Depends(get_db)  # ← FastAPI lo inyecta
):
    # Ya tienes 'db' lista para usar
    return db.query(EmpleadoDB).all()
    # FastAPI cierra 'db' automáticamente
```

Sin DI tendrías que:
1. Abrir sesión manualmente
2. Hacer try/finally
3. Cerrar sesión en finally
4. Manejar errores

---

## 📱 Flutter

### ¿Qué es setState?

Le dice a Flutter que redibuje la UI cuando algo cambia:

```dart
bool _isLoading = false;

// ❌ Malo - cambia pero no redibuja
_isLoading = true;

// ✅ Bueno - cambia Y redibuja
setState(() {
    _isLoading = true;
});
```

### ¿Por qué verificar `if (!mounted)`?

Para evitar llamar setState después de que el widget se destruyó:

```dart
Future<void> cargarDatos() async {
    var datos = await api.getData();
    
    // Si el usuario salió de la pantalla mientras esperaba,
    // mounted = false y no podemos usar setState
    if (!mounted) return;
    
    setState(() {
        _datos = datos;
    });
}
```

### ¿Cómo funciona la navegación?

```dart
// Ir a otra pantalla
Navigator.push(context, MaterialPageRoute(
    builder: (_) => OtraPantalla()
));

// Ir y cerrar la actual
Navigator.pushReplacement(context, MaterialPageRoute(
    builder: (_) => OtraPantalla()
));

// Volver
Navigator.pop(context);

// Volver con resultado
Navigator.pop(context, true);
```

### ¿Para qué sirve ListView.builder?

Es eficiente con listas grandes:
- Si tienes 1000 elementos, solo crea ~15 widgets (los visibles)
- Reutiliza widgets al hacer scroll
- No consume memoria innecesaria

---

## 🗄️ Base de Datos

### ¿Cuál es mejor: PostgreSQL o SQLite?

**SQLite (Desarrollo):**
- ✅ Fácil de configurar
- ✅ No requiere servidor
- ✅ Archivo único
- ❌ No para producción con múltiples usuarios

**PostgreSQL (Producción):**
- ✅ Mejor rendimiento
- ✅ Múltiples conexiones simultáneas
- ✅ Más robusto
- ❌ Requiere configuración

**Recomendación:** SQLite para aprender, PostgreSQL para producción.

### ¿Las tablas se crean automáticamente?

✅ **SÍ**. SQLAlchemy las crea al iniciar el backend:

```python
# En main.py
models.Base.metadata.create_all(bind=engine)
```

### ¿Cómo veo los datos en la base de datos?

**SQLite:**
- Descarga [DB Browser for SQLite](https://sqlitebrowser.org/)
- Abre el archivo `backend/empleados.db`

**PostgreSQL:**
- Descarga [DBeaver](https://dbeaver.io/)
- Conecta con tus credenciales
- Navega a la base de datos

### ¿Cómo borro todos los datos?

**SQLite:**
```powershell
cd backend
del empleados.db
# Al reiniciar el backend, se crea una BD vacía
```

**PostgreSQL:**
```sql
TRUNCATE TABLE empleados CASCADE;
TRUNCATE TABLE usuarios CASCADE;
```

---

## 🚀 Deployment

### ¿Puedo subir esto a producción?

Sí, pero haz estos cambios primero:

1. **Cambia SECRET_KEY** en `auth.py`
2. **Restringe CORS** en `main.py`:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://tudominio.com"],  # No usar "*"
    ...
)
```
3. **Usa PostgreSQL** (no SQLite)
4. **Configura HTTPS**

### ¿Dónde puedo hostear el backend?

**Gratis:**
- Railway (https://railway.app/)
- Render (https://render.com/)
- Fly.io (https://fly.io/)
- Deta (https://deta.sh/)

**Pago:**
- Heroku
- AWS
- Google Cloud
- DigitalOcean

### ¿Y el frontend?

**Web:**
```powershell
flutter build web
# Sube el contenido de build/web a Netlify, Vercel, etc.
```

**Android APK:**
```powershell
flutter build apk
# El APK está en build/app/outputs/flutter-apk/
```

**iOS:**
```powershell
flutter build ios
# Requiere Mac y cuenta de Apple Developer
```

---

## 📚 Aprendizaje

### ¿Dónde aprendo más sobre FastAPI?

- [Documentación oficial](https://fastapi.tiangolo.com/)
- [Tutorial oficial](https://fastapi.tiangolo.com/tutorial/)

### ¿Dónde aprendo más sobre Flutter?

- [Documentación oficial](https://flutter.dev/docs)
- [Flutter Codelabs](https://flutter.dev/docs/codelabs)
- [Widget of the Week](https://www.youtube.com/playlist?list=PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG)

### ¿Qué archivo debo leer primero?

1. `README.md` - Visión general
2. `INICIO_RAPIDO.md` - Setup paso a paso
3. `GUIA_PRINCIPIANTES.md` - Conceptos explicados
4. `DOCUMENTACION.md` - Detalles técnicos
5. `EJEMPLOS_CODIGO.md` - Código comentado

### ¿Puedo usar este proyecto como base?

✅ **SÍ, totalmente**. Puedes:
- Modificarlo como quieras
- Agregar más funcionalidades
- Usarlo para aprender
- Adaptarlo a tus necesidades

---

## 🎓 Para la Tarea

### ¿Este proyecto cumple con todos los requisitos?

✅ **100% COMPLETO**:

- [x] Login con async/await (Dart)
- [x] CRUD completo de empleados
- [x] Backend FastAPI con JWT
- [x] Cargar datos en paralelo (Future.wait)
- [x] No bloquear UI
- [x] Animación loading
- [x] Refrescar lista automáticamente

### ¿Qué debo explicar en la presentación?

**Conceptos clave:**
1. Arquitectura cliente-servidor
2. Autenticación con JWT
3. Async/await para no bloquear UI
4. Future.wait para carga paralela
5. CRUD completo

**Demo en vivo:**
1. Registrar usuario
2. Login (mostrar loading)
3. Crear empleado
4. Editar empleado
5. Eliminar empleado
6. Mostrar carga paralela (botón sync)

### ¿Qué archivos debo entregar?

**Todo el proyecto:**
```
CrudEmpleados/
├── backend/
├── frontend/
├── *.md (documentación)
└── scripts *.ps1
```

**O comprimido:**
```powershell
# Excluir carpetas pesadas
Compress-Archive -Path . -DestinationPath CrudEmpleados.zip -Exclude **/node_modules,**/.dart_tool,**/__pycache__
```

---

## 💡 Tips

### Para mejorar tu código

1. Siempre usa `try/catch` en operaciones async
2. Verifica `if (!mounted)` después de async
3. Usa `const` cuando sea posible
4. Comenta código complejo
5. Valida inputs en frontend Y backend

### Para debugging

**Backend:**
```python
# Agregar prints
print(f"Usuario: {username}, Token: {token}")
```

**Flutter:**
```dart
// Agregar prints
print('Empleados cargados: ${empleados.length}');

// O usar debugger
debugPrint('Debug info');
```

### Atajos útiles

**Flutter:**
- `r` = Hot reload
- `R` = Hot restart
- `q` = Quit

**VS Code:**
- `F5` = Run/Debug
- `Ctrl+C` = Stop server
- `Ctrl+Shift+P` = Command palette

---

**¿Más preguntas? Revisa los archivos de documentación o busca en la documentación oficial de FastAPI/Flutter.**

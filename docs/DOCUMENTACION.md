# 📖 Documentación Técnica - CRUD Empleados

Esta documentación explica la arquitectura, patrones de diseño y funcionalidades clave del proyecto.

## 🏛️ Arquitectura General

### Patrón de Diseño: Cliente-Servidor REST

```
┌─────────────────┐         HTTP/JSON         ┌─────────────────┐
│                 │  ←──────────────────────→  │                 │
│  Flutter App    │     Requests/Responses     │  FastAPI Server │
│  (Frontend)     │                            │  (Backend)      │
│                 │                            │                 │
└─────────────────┘                            └────────┬────────┘
                                                        │
                                                        ↓
                                                ┌───────────────┐
                                                │  PostgreSQL   │
                                                │   Database    │
                                                └───────────────┘
```

### Flujo de Autenticación

```
1. Usuario ingresa credenciales
2. Flutter → POST /auth/login → FastAPI
3. FastAPI valida contra BD (async)
4. FastAPI genera JWT token
5. FastAPI → Token → Flutter
6. Flutter guarda token en SharedPreferences
7. Flutter incluye token en todas las peticiones subsiguientes
```

---

## 🔙 Backend (FastAPI)

### Estructura de Archivos

#### `main.py` - Punto de entrada y endpoints

**Responsabilidades:**
- Define todos los endpoints de la API
- Configura CORS para permitir peticiones desde Flutter
- Crea las tablas de base de datos automáticamente
- Maneja la lógica de negocio de cada endpoint

**Endpoints clave:**

```python
# Autenticación
@app.post("/auth/login", response_model=Token)
async def login(login_data: LoginRequest, db: Session = Depends(get_db))
# → Valida credenciales y retorna JWT

# CRUD Empleados (todos requieren token)
@app.get("/empleados", response_model=List[Empleado])
async def get_empleados(current_user: str = Depends(auth.verify_token), ...)
# → Lista todos los empleados (con paginación)

@app.post("/empleados", response_model=Empleado)
async def create_empleado(empleado: EmpleadoCreate, ...)
# → Crea nuevo empleado

@app.put("/empleados/{empleado_id}", response_model=Empleado)
async def update_empleado(empleado_id: int, empleado_update: EmpleadoUpdate, ...)
# → Actualiza empleado existente

@app.delete("/empleados/{empleado_id}")
async def delete_empleado(empleado_id: int, ...)
# → Elimina empleado
```

#### `models.py` - Modelos de datos

Define dos tipos de modelos:

**1. Modelos SQLAlchemy (BD):**
```python
class EmpleadoDB(Base):
    __tablename__ = "empleados"
    id = Column(Integer, primary_key=True)
    nombre = Column(String)
    # ... más campos
```

**2. Schemas Pydantic (Validación):**
```python
class EmpleadoCreate(BaseModel):
    nombre: str
    apellido: str
    # ... valida datos de entrada
```

**¿Por qué dos modelos?**
- SQLAlchemy: interactúa con la base de datos
- Pydantic: valida y serializa datos JSON

#### `auth.py` - Autenticación y seguridad

**Funciones clave:**

```python
# Hashear contraseña
def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

# Verificar contraseña
def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

# Crear token JWT
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    # Codifica datos del usuario en un token firmado
    # Incluye tiempo de expiración
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

# Verificar token (Dependency)
def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    # Decodifica y valida el token
    # Lanza excepción si es inválido o expirado
    payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    return username
```

**Seguridad:**
- Contraseñas hasheadas con bcrypt (no se guardan en texto plano)
- JWT firmado digitalmente (no se puede falsificar)
- Tokens con expiración (30 minutos por defecto)

#### `database.py` - Configuración de base de datos

```python
DATABASE_URL = "postgresql://usuario:password@localhost:5432/empleados_db"

# Crea el motor de conexión
engine = create_engine(DATABASE_URL)

# Factory de sesiones
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Dependency injection para obtener sesión de BD
def get_db():
    db = SessionLocal()
    try:
        yield db  # Presta la sesión
    finally:
        db.close()  # Siempre cierra al terminar
```

**Patrón Dependency Injection:**
- FastAPI inyecta automáticamente la sesión de BD en cada endpoint
- Garantiza que la conexión se cierre siempre

---

## 🎨 Frontend (Flutter)

### Estructura de Archivos

#### `lib/models/empleado.dart` - Modelo de datos

```dart
class Empleado {
    final int? id;
    final String nombre;
    // ... campos

    // Deserialización: JSON → Objeto
    factory Empleado.fromJson(Map<String, dynamic> json) {
        return Empleado(
            id: json['id'],
            nombre: json['nombre'],
            // ...
        );
    }

    // Serialización: Objeto → JSON
    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'nombre': nombre,
            // ...
        };
    }
}
```

#### `lib/services/api_service.dart` - Cliente HTTP

**Responsabilidades:**
- Comunicación con el backend
- Gestión de tokens JWT
- Implementa TODAS las operaciones CRUD
- **Carga paralela con Future.wait**

**Gestión de Tokens:**

```dart
// Guardar token después del login
Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
}

// Cargar token antes de cada petición
Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
}

// Incluir token en headers
Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
        headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
}
```

**Login Asíncrono (async/await):**

```dart
Future<bool> login(String username, String password) async {
    try {
        // Petición HTTP asíncrona - NO BLOQUEA LA UI
        final response = await http.post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
                'username': username,
                'password': password,
            }),
        );

        if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            await _saveToken(data['access_token']);
            return true;
        }
        return false;
    } catch (e) {
        print('Error en login: $e');
        return false;
    }
}
```

**Carga Paralela con Future.wait:**

```dart
Future<Map<String, dynamic>> cargarDatosYFotosEnParalelo(List<int> empleadoIds) async {
    try {
        // Crear múltiples Futures
        final futures = empleadoIds.map((id) => getEmpleado(id)).toList();
        
        // Ejecutar TODAS las peticiones AL MISMO TIEMPO
        // Espera a que TODAS terminen
        final empleados = await Future.wait(futures);
        
        return {
            'success': true,
            'empleados': empleados,
        };
    } catch (e) {
        return {'success': false, 'error': e.toString()};
    }
}
```

**¿Qué hace Future.wait?**
- Sin Future.wait: peticiones secuenciales (una tras otra) = LENTO
- Con Future.wait: peticiones paralelas (todas a la vez) = RÁPIDO

Ejemplo:
```
Sin Future.wait:
Petición 1: ████████ (2s)
Petición 2:         ████████ (2s)
Petición 3:                 ████████ (2s)
Total: 6 segundos

Con Future.wait:
Petición 1: ████████ (2s)
Petición 2: ████████ (2s)
Petición 3: ████████ (2s)
Total: 2 segundos
```

#### `lib/screens/login_screen.dart` - Pantalla de login

**Características clave:**

```dart
Future<void> _handleLogin() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) return;

    // Mostrar loading - NO BLOQUEA LA UI
    setState(() => _isLoading = true);

    try {
        // Llamada asíncrona
        final success = await _apiService.login(
            _usernameController.text.trim(),
            _passwordController.text,
        );

        if (!mounted) return;  // Importante: verificar si el widget sigue montado

        if (success) {
            // Navegar a home
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
        } else {
            _showErrorDialog('Credenciales incorrectas');
        }
    } catch (e) {
        _showErrorDialog('Error: ${e.toString()}');
    } finally {
        if (mounted) {
            setState(() => _isLoading = false);
        }
    }
}
```

**¿Por qué async/await?**
- Permite que la UI siga respondiendo durante operaciones largas
- Muestra animaciones de loading sin bloqueos
- Experiencia de usuario fluida

#### `lib/screens/home_screen.dart` - Lista de empleados

**Características:**

1. **Carga inicial con Future.wait optimizado:**
```dart
Future<void> _cargarEmpleados() async {
    setState(() => _isLoading = true);
    try {
        // Usa versión optimizada con carga paralela
        final empleados = await _apiService.cargarEmpleadosOptimizado();
        setState(() {
            _empleados = empleados;
            _isLoading = false;
        });
    } catch (e) {
        setState(() => _isLoading = false);
        _showSnackBar('Error: $e', isError: true);
    }
}
```

2. **Actualización automática después de operaciones:**
```dart
void _navegarAFormulario({Empleado? empleado}) async {
    final resultado = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => EmpleadoFormScreen(empleado: empleado)),
    );

    // Si hubo cambios (creación/edición), refrescar lista
    if (resultado == true) {
        _cargarEmpleados();  // ← Refresco automático
    }
}
```

3. **Pull to refresh:**
```dart
RefreshIndicator(
    onRefresh: _cargarEmpleados,  // Arrastra hacia abajo para refrescar
    child: ListView.builder(...),
)
```

4. **Eliminación optimista:**
```dart
Future<void> _eliminarEmpleado(int id) async {
    // Confirmar con diálogo
    final confirmar = await showDialog<bool>(...);
    
    if (confirmar == true) {
        final success = await _apiService.deleteEmpleado(id);
        if (success) {
            _showSnackBar('Empleado eliminado');
            _cargarEmpleados();  // Refrescar lista automáticamente
        }
    }
}
```

#### `lib/screens/empleado_form_screen.dart` - Formulario CRUD

**Modo dual: Crear/Editar:**

```dart
@override
void initState() {
    super.initState();
    _isEditMode = widget.empleado != null;  // ¿Editar o crear?

    // Pre-llenar campos si es edición
    _nombreController = TextEditingController(
        text: widget.empleado?.nombre ?? ''
    );
    // ...
}

Future<void> _guardarEmpleado() async {
    // ...
    if (_isEditMode) {
        await _apiService.updateEmpleado(widget.empleado!.id!, empleado);
    } else {
        await _apiService.createEmpleado(empleado);
    }
    
    // Retornar true para indicar que hubo cambios
    Navigator.of(context).pop(true);
}
```

---

## 🔄 Flujos de Datos Completos

### Flujo de Login

```
1. Usuario ingresa credenciales
   ↓
2. LoginScreen._handleLogin() [async]
   ↓
3. ApiService.login() [async] → POST /auth/login
   ↓
4. Backend valida credenciales
   ↓
5. Backend genera JWT token
   ↓
6. ApiService guarda token en SharedPreferences
   ↓
7. Navigator navega a HomeScreen
   ↓
8. HomeScreen carga empleados automáticamente
```

### Flujo de Creación de Empleado

```
1. Usuario presiona botón +
   ↓
2. Navigator.push → EmpleadoFormScreen (sin empleado)
   ↓
3. Usuario llena formulario
   ↓
4. Usuario presiona "CREAR"
   ↓
5. EmpleadoFormScreen._guardarEmpleado() [async]
   ↓
6. ApiService.createEmpleado() → POST /empleados (con token JWT)
   ↓
7. Backend valida token
   ↓
8. Backend crea registro en BD
   ↓
9. Backend retorna empleado creado
   ↓
10. EmpleadoFormScreen hace pop(true)
   ↓
11. HomeScreen detecta resultado == true
   ↓
12. HomeScreen._cargarEmpleados() (refresco automático)
   ↓
13. Lista actualizada muestra nuevo empleado
```

### Flujo de Carga Paralela

```
1. Usuario presiona botón sync ⟳
   ↓
2. HomeScreen._cargarDatosYFotosEnParalelo()
   ↓
3. ApiService.cargarDatosYFotosEnParalelo([1, 2, 3])
   ↓
4. Crea 3 Futures: getEmpleado(1), getEmpleado(2), getEmpleado(3)
   ↓
5. Future.wait ejecuta los 3 en PARALELO
   ├─→ GET /empleados/1 (simultáneo)
   ├─→ GET /empleados/2 (simultáneo)
   └─→ GET /empleados/3 (simultáneo)
   ↓
6. Espera a que TODOS terminen
   ↓
7. Retorna lista de 3 empleados
   ↓
8. Muestra SnackBar con cantidad cargada
```

---

## 🔐 Seguridad

### Almacenamiento Seguro de Contraseñas

```python
# ❌ NUNCA hacer esto:
password = "admin123"  # Texto plano en BD

# ✅ Hacer esto:
hashed = get_password_hash("admin123")
# Resultado: $2b$12$KIxS... (hash bcrypt)
# Imposible revertir a texto plano
```

### Validación de Tokens JWT

```python
@app.get("/empleados")
async def get_empleados(
    current_user: str = Depends(auth.verify_token),  # ← Validación automática
    db: Session = Depends(get_db)
):
    # Si el token es inválido/expirado, FastAPI retorna 401 automáticamente
    # Este código solo se ejecuta si el token es válido
    empleados = db.query(EmpleadoDB).all()
    return empleados
```

---

## 📊 Base de Datos

### Esquema de Tablas

**Tabla: empleados**
```sql
CREATE TABLE empleados (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR NOT NULL,
    apellido VARCHAR NOT NULL,
    puesto VARCHAR NOT NULL,
    salario FLOAT NOT NULL,
    email VARCHAR UNIQUE NOT NULL,
    telefono VARCHAR NOT NULL,
    foto_url VARCHAR NULL,
    fecha_ingreso TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Tabla: usuarios**
```sql
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    username VARCHAR UNIQUE NOT NULL,
    password_hash VARCHAR NOT NULL,
    email VARCHAR UNIQUE NOT NULL
);
```

### Migración Automática

SQLAlchemy crea las tablas automáticamente:

```python
# En main.py
models.Base.metadata.create_all(bind=engine)
```

Esto detecta los modelos definidos y crea las tablas si no existen.

---

## 🚀 Optimizaciones

### Backend

1. **Async/await en endpoints:**
   - Permite manejar múltiples peticiones simultáneas
   - No bloquea el servidor durante I/O (base de datos)

2. **Paginación en lista:**
   ```python
   @app.get("/empleados")
   async def get_empleados(skip: int = 0, limit: int = 100, ...):
       empleados = db.query(EmpleadoDB).offset(skip).limit(limit).all()
   ```

3. **Índices en BD:**
   ```python
   email = Column(String, unique=True, index=True)  # ← Búsquedas rápidas
   ```

### Frontend

1. **Future.wait para carga paralela:**
   - Múltiples peticiones HTTP simultáneas
   - Reduce tiempo de carga significativamente

2. **SharedPreferences para tokens:**
   - Persistencia local sin necesidad de re-login
   - Acceso rápido al token

3. **Actualización optimista:**
   - Actualiza UI inmediatamente
   - No espera confirmación del servidor para feedback visual

---

## 📝 Convenciones del Código

### Backend (Python)

- Nombres de funciones: `snake_case`
- Clases: `PascalCase`
- Constantes: `UPPER_SNAKE_CASE`
- Async para I/O: Siempre usar `async def`

### Frontend (Dart/Flutter)

- Variables privadas: `_nombrePrivado`
- Clases: `PascalCase`
- Funciones: `camelCase`
- Constantes: `camelCase` o `const`
- Widgets: Siempre `const` cuando sea posible

---

## 🔍 Debugging

### Backend

```python
# Agregar prints para debug
print(f"Usuario intentando login: {login_data.username}")

# Ver logs en terminal donde corre uvicorn
# Muestra cada petición HTTP recibida
```

### Flutter

```dart
// Agregar prints
print('Empleados cargados: ${_empleados.length}');

// Ver logs en:
// - Terminal de VS Code
// - Debug Console
// - DevTools
```

---

**Esta documentación cubre los aspectos técnicos clave del proyecto. Para una explicación más didáctica, consulta [GUIA_PRINCIPIANTES.md](./GUIA_PRINCIPIANTES.md)**

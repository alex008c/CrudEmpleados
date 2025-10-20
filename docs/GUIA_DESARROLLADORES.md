# Guía para Desarrolladores - CRUD Empleados MVVM

> **Audiencia**: Desarrolladores con conocimientos básicos de programación y bases de datos, pero nuevos en Flutter/Dart, FastAPI, y arquitectura MVVM.

## 📑 Índice

1. [Visión General del Proyecto](#visión-general)
2. [Arquitectura MVVM](#arquitectura-mvvm)
3. [Backend con FastAPI](#backend-fastapi)
4. [Frontend con Flutter](#frontend-flutter)
5. [Concurrencia y Future.wait](#concurrencia)
6. [Autenticación JWT](#autenticación-jwt)
7. [Flujo Completo de Datos](#flujo-de-datos)

---

## 🎯 Visión General

Este proyecto implementa un CRUD (Create, Read, Update, Delete) de empleados con:

- **Backend**: FastAPI (Python) - API REST con autenticación JWT
- **Frontend**: Flutter (Dart) - Aplicación móvil con arquitectura MVVM
- **Base de Datos**: PostgreSQL o SQLite con SQLAlchemy
- **Patrón**: MVVM (Model-View-ViewModel) con Provider
- **Concurrencia**: Future.wait para carga paralela

### Stack Tecnológico

| Componente | Tecnología | Rol |
|------------|------------|-----|
| Backend API | FastAPI + Uvicorn | Servidor REST asíncrono |
| ORM | SQLAlchemy 2.0 | Mapeo objeto-relacional |
| Auth | JWT (python-jose) | Tokens de sesión |
| Passwords | bcrypt (passlib) | Hash de contraseñas |
| Frontend | Flutter 3.0+ | UI multiplataforma |
| State Mgmt | Provider | Gestión de estado reactivo |
| HTTP Client | http package | Peticiones REST |

---

## 🏗️ Arquitectura MVVM

MVVM separa la aplicación en 3 capas independientes:

```
VIEW ←→ VIEWMODEL ←→ REPOSITORY ←→ BACKEND
(UI)   (Lógica)     (Datos)       (API)
```

### ¿Por qué MVVM?

- **Separación de responsabilidades**: Cada capa tiene un propósito único
- **Testeable**: Puedes probar lógica sin UI
- **Mantenible**: Cambios en UI no rompen lógica de negocio
- **Reutilizable**: Mismo Repository en múltiples ViewModels

### Capa VIEW (Screens)

**Responsabilidad**: Solo UI - renderizar widgets y capturar eventos

```dart
// ❌ MAL - View con lógica de negocio
class HomeScreen extends StatefulWidget {
  Future<void> loadData() async {
    final response = await http.get(...);  // ← Lógica en View
    setState(() => data = response.body);
  }
}

// ✅ BIEN - View delegando al ViewModel
class HomeScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<EmpleadoViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) return CircularProgressIndicator();
        return ListView.builder(
          itemCount: viewModel.empleados.length,
          itemBuilder: (ctx, i) => EmpleadoTile(viewModel.empleados[i]),
        );
      },
    );
  }
}
```

**Características de la View**:
- No hace llamadas HTTP directas
- No tiene lógica de negocio
- Usa `Consumer<T>` para escuchar cambios
- Usa `context.read<T>()` para ejecutar acciones

### Capa VIEWMODEL (Business Logic)

**Responsabilidad**: Coordinar operaciones, manejar estado, notificar cambios

```dart
class EmpleadoViewModel extends ChangeNotifier {
  final EmpleadoRepository _repository;
  
  // Estado
  List<Empleado> _empleados = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters públicos (inmutables)
  List<Empleado> get empleados => List.unmodifiable(_empleados);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Operaciones
  Future<void> cargarEmpleados() async {
    _isLoading = true;
    notifyListeners();  // ← Actualiza Views
    
    try {
      _empleados = await _repository.getEmpleados();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();  // ← Actualiza Views
    }
  }
}
```

**Características del ViewModel**:
- Extiende `ChangeNotifier` (patrón Observer)
- Llama `notifyListeners()` cuando cambia el estado
- No hace peticiones HTTP (delega al Repository)
- Maneja validaciones y lógica de negocio

### Capa REPOSITORY (Data Access)

**Responsabilidad**: Comunicación con APIs, persistencia, caché

```dart
class EmpleadoRepository {
  final String baseUrl;
  final String? token;
  
  Future<List<Empleado>> getEmpleados() async {
    final response = await http.get(
      Uri.parse('$baseUrl/empleados'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Empleado.fromJson(json)).toList();
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }
}
```

**Características del Repository**:
- Solo maneja datos (no estado de UI)
- Retorna `Future<T>` o lanza excepciones
- Puede implementar caché local
- Puede combinar múltiples fuentes de datos

### Conexión con Provider

**main.dart** configura los Providers:

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        // ViewModel de autenticación
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(AuthRepository(baseUrl: API_URL)),
        ),
        
        // ViewModel de empleados (depende de AuthViewModel para el token)
        ChangeNotifierProxyProvider<AuthViewModel, EmpleadoViewModel>(
          create: (_) => EmpleadoViewModel(...),
          update: (_, authVM, prevEmpleadoVM) {
            // Actualizar cuando cambie la autenticación
            return EmpleadoViewModel(
              EmpleadoRepository(token: authVM.currentToken),
            );
          },
        ),
      ],
      child: MyApp(),
    ),
  );
}
```

---

## 🐍 Backend FastAPI

FastAPI es un framework moderno de Python para crear APIs REST.

### Características Clave

- **Async/await**: Operaciones no bloqueantes
- **Type hints**: Validación automática con Pydantic
- **Documentación automática**: Swagger UI en `/docs`
- **Inyección de dependencias**: Pattern `Depends()`

### Estructura del Código

**main.py** - Endpoints de la API:

```python
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
import auth
from database import get_db

app = FastAPI()

@app.post("/auth/login")
async def login(credentials: UsuarioLogin, db: Session = Depends(get_db)):
    # Buscar usuario en BD
    usuario = db.query(UsuarioDB).filter(
        UsuarioDB.username == credentials.username
    ).first()
    
    if not usuario:
        raise HTTPException(status_code=401, detail="Usuario no encontrado")
    
    # Verificar contraseña
    if not auth.verify_password(credentials.password, usuario.password_hash):
        raise HTTPException(status_code=401, detail="Contraseña incorrecta")
    
    # Generar JWT
    token = auth.create_access_token(data={"sub": usuario.username})
    
    return {"access_token": token, "token_type": "bearer"}

@app.get("/empleados")
async def get_empleados(
    token_data: dict = Depends(auth.verify_token),  # ← Protegido con JWT
    db: Session = Depends(get_db)
):
    empleados = db.query(EmpleadoDB).all()
    return empleados
```

**Conceptos Clave**:

1. **`async def`**: Permite que el servidor maneje múltiples peticiones simultáneamente sin bloquearse
2. **`Depends()`**: Inyección de dependencias - FastAPI ejecuta la función y pasa el resultado
3. **Type hints**: `credentials: UsuarioLogin` - FastAPI valida automáticamente el JSON

**models.py** - Modelos duales:

```python
from sqlalchemy import Column, Integer, String, Float
from sqlalchemy.ext.declarative import declarative_base
from pydantic import BaseModel

Base = declarative_base()

# Modelo SQLAlchemy (para la base de datos)
class EmpleadoDB(Base):
    __tablename__ = "empleados"
    
    id = Column(Integer, primary_key=True)
    nombre = Column(String, nullable=False)
    salario = Column(Float, nullable=False)

# Modelo Pydantic (para validación de API)
class EmpleadoBase(BaseModel):
    nombre: str
    salario: float
    
    class Config:
        from_attributes = True  # Permite convertir desde SQLAlchemy
```

**¿Por qué dos modelos?**
- **SQLAlchemy** = Cómo se guarda en la base de datos
- **Pydantic** = Cómo se valida en la API (JSON → Objeto)

**auth.py** - JWT y hashing:

```python
from jose import JWTError, jwt
from passlib.context import CryptContext
from datetime import datetime, timedelta

SECRET_KEY = "tu-clave-secreta"  # ← Cambiar en producción
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    
    # Codificar con HS256
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(401)
        return payload
    except JWTError:
        raise HTTPException(401, detail="Token inválido")

def get_password_hash(password: str):
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str):
    return pwd_context.verify(plain_password, hashed_password)
```

**database.py** - Conexión con inyección de dependencias:

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

DATABASE_URL = "sqlite:///./empleados.db"  # o PostgreSQL

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)

def get_db():
    """
    Dependency: Proporciona sesión de base de datos
    Se cierra automáticamente después de cada request
    """
    db = SessionLocal()
    try:
        yield db  # ← FastAPI inyecta esto en los endpoints
    finally:
        db.close()
```

---

## 📱 Frontend Flutter

Flutter es un framework de Google para crear apps móviles, web y desktop con un solo código.

### Dart Básico

**Diferencias con otros lenguajes**:

```dart
// Variables
final nombre = "Juan";  // Inmutable (como const en JS)
var edad = 25;          // Mutable con inferencia de tipo
int? edad2;             // Nullable (puede ser null)
late String apellido;   // Se asignará después

// Funciones
String saludar(String nombre) {
  return "Hola $nombre";  // ← Interpolación de strings
}

// Funciones flecha
String saludar2(String nombre) => "Hola $nombre";

// Async/await (igual que JavaScript)
Future<String> fetchData() async {
  final response = await http.get(url);
  return response.body;
}

// Clases
class Persona {
  final String nombre;
  int edad;
  
  Persona(this.nombre, this.edad);  // Constructor abreviado
  
  void cumplirAnios() => edad++;
}

// Named parameters (muy común en Flutter)
Widget buildButton({required String label, VoidCallback? onPressed}) {
  return ElevatedButton(
    onPressed: onPressed,
    child: Text(label),
  );
}
```

### Widgets Básicos

Flutter usa **widgets** (componentes reutilizables):

```dart
// Widget sin estado
class MiTexto extends StatelessWidget {
  final String texto;
  
  const MiTexto(this.texto);
  
  @override
  Widget build(BuildContext context) {
    return Text(texto);
  }
}

// Widget con estado
class Contador extends StatefulWidget {
  @override
  State<Contador> createState() => _ContadorState();
}

class _ContadorState extends State<Contador> {
  int _contador = 0;
  
  void _incrementar() {
    setState(() {  // ← Reconstruye el widget
      _contador++;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Contador: $_contador'),
        ElevatedButton(
          onPressed: _incrementar,
          child: Text('Incrementar'),
        ),
      ],
    );
  }
}
```

### Provider Pattern

Provider implementa el patrón Observer:

```dart
// 1. Crear un modelo observable
class Counter extends ChangeNotifier {
  int _count = 0;
  int get count => _count;
  
  void increment() {
    _count++;
    notifyListeners();  // ← Notifica a los widgets
  }
}

// 2. Proveer el modelo
ChangeNotifierProvider(
  create: (_) => Counter(),
  child: MyApp(),
);

// 3. Consumir el modelo
Consumer<Counter>(
  builder: (context, counter, child) {
    return Text('Contador: ${counter.count}');
  },
);

// 4. Ejecutar acciones
context.read<Counter>().increment();
```

---

## ⚡ Concurrencia y Future.wait

### El Problema

Cargar 5 empleados uno por uno:

```dart
// ❌ Secuencial (lento)
final empleados = <Empleado>[];
for (final id in [1,2,3,4,5]) {
  final emp = await getEmpleado(id);  // Espera 1 segundo
  empleados.add(emp);
}
// Total: ~5 segundos
```

### La Solución: Future.wait

```dart
// ✅ Paralelo (rápido)
final futures = [1,2,3,4,5].map((id) => getEmpleado(id)).toList();
final empleados = await Future.wait(futures);
// Total: ~1 segundo (todas las peticiones al mismo tiempo)
```

### Analogía

Imagina un restaurante:

**Secuencial** = Un mesero atiende una mesa, espera a que terminen de comer, luego atiende la siguiente.
- Mesa 1: 1 hora
- Mesa 2: 1 hora
- Mesa 3: 1 hora
- **Total: 3 horas**

**Paralelo** = Un mesero atiende las 3 mesas al mismo tiempo, todas comen en paralelo.
- Todas las mesas: 1 hora
- **Total: 1 hora**

### Implementación con Medición

```dart
class EmpleadoRepository {
  Future<ConcurrencyResult> cargarEmpleadosParalelo(List<int> ids) async {
    final stopwatch = Stopwatch()..start();
    
    // Crear lista de Futures
    final futures = ids.map((id) => getEmpleadoById(id)).toList();
    
    // Ejecutar TODAS al mismo tiempo
    final empleados = await Future.wait(futures);
    
    stopwatch.stop();
    
    return ConcurrencyResult(
      empleados: empleados,
      tiempoMs: stopwatch.elapsedMilliseconds,
      metodo: 'Paralelo',
    );
  }
  
  Future<ComparisonResult> compararMetodos(List<int> ids) async {
    // Comparar ambos métodos
    final secuencial = await cargarEmpleadosSecuencial(ids);
    final paralelo = await cargarEmpleadosParalelo(ids);
    
    final mejora = (secuencial.tiempoMs - paralelo.tiempoMs) /
        secuencial.tiempoMs * 100;
    
    return ComparisonResult(
      secuencial: secuencial,
      paralelo: paralelo,
      mejoraPorcentaje: mejora,
    );
  }
}
```

---

## 🔐 Autenticación JWT

JWT (JSON Web Token) = Token firmado que contiene información del usuario.

### Estructura de un JWT

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJqdWFuIiwiZXhwIjoxNjk...
│         HEADER         │      PAYLOAD      │     SIGNATURE     │
```

- **Header**: Tipo de token y algoritmo (HS256)
- **Payload**: Datos del usuario (`{sub: "juan", exp: 1234567890}`)
- **Signature**: Firma para verificar que no fue modificado

### Flujo Completo

```
┌─────────┐          ┌─────────┐          ┌─────────┐
│  Flutter│          │ FastAPI │          │   BD    │
└────┬────┘          └────┬────┘          └────┬────┘
     │                    │                     │
     │ POST /auth/login   │                     │
     │ {user, pass}       │                     │
     │───────────────────>│                     │
     │                    │  SELECT * FROM...   │
     │                    │────────────────────>│
     │                    │<────────────────────│
     │                    │  usuario_hash       │
     │                    │                     │
     │                    │ verify_password()   │
     │                    │ ✅ Correcto         │
     │                    │                     │
     │                    │ create_access_token│
     │                    │ JWT = "eyJ..."      │
     │                    │                     │
     │ <──────────────────│                     │
     │ {access_token: JWT}│                     │
     │                    │                     │
     │ SharedPreferences  │                     │
     │ .setString(JWT)    │                     │
     │                    │                     │
     │ GET /empleados     │                     │
     │ Header: Bearer JWT │                     │
     │───────────────────>│                     │
     │                    │ verify_token(JWT)   │
     │                    │ ✅ Válido           │
     │                    │                     │
     │                    │  SELECT empleados   │
     │                    │────────────────────>│
     │                    │<────────────────────│
     │ <──────────────────│                     │
     │  [empleados...]    │                     │
```

### Código en Flutter

```dart
// 1. Login
Future<String> login(String username, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    body: jsonEncode({'username': username, 'password': password}),
  );
  
  final data = jsonDecode(response.body);
  final token = data['access_token'];
  
  // Guardar token localmente
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
  
  return token;
}

// 2. Usar token en peticiones
Future<List<Empleado>> getEmpleados() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  
  final response = await http.get(
    Uri.parse('$baseUrl/empleados'),
    headers: {
      'Authorization': 'Bearer $token',  // ← Token en header
    },
  );
  
  return jsonDecode(response.body).map(...).toList();
}
```

### Código en FastAPI

```python
@app.get("/empleados")
async def get_empleados(
    token_data: dict = Depends(verify_token),  # ← Valida token
    db: Session = Depends(get_db)
):
    # Si llegó aquí, el token es válido
    empleados = db.query(EmpleadoDB).all()
    return empleados

def verify_token(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username = payload.get("sub")
        if username is None:
            raise HTTPException(401)
        return payload
    except JWTError:
        raise HTTPException(401, detail="Token inválido o expirado")
```

---

## 🔄 Flujo Completo de Datos

### Crear Empleado (CREATE)

```
┌────────────────────────────────────────────────────────┐
│ 1. Usuario llena formulario y presiona "Guardar"      │
└────────────────┬───────────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────────┐
│ 2. EmpleadoFormScreen (View)                           │
│    - Valida campos                                     │
│    - Crea objeto Empleado                              │
│    - Llama viewModel.crearEmpleado(empleado)           │
└────────────────┬───────────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────────┐
│ 3. EmpleadoViewModel                                   │
│    - _isLoading = true                                 │
│    - notifyListeners() → UI muestra spinner            │
│    - Llama repository.createEmpleado(empleado)         │
└────────────────┬───────────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────────┐
│ 4. EmpleadoRepository                                  │
│    - POST http://localhost:8000/empleados              │
│    - Headers: {Authorization: Bearer <JWT>}            │
│    - Body: JSON del empleado                           │
└────────────────┬───────────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────────┐
│ 5. FastAPI Backend                                     │
│    - verify_token() → Valida JWT                       │
│    - Crea EmpleadoDB desde JSON                        │
│    - db.add(empleado)                                  │
│    - db.commit()                                       │
│    - Retorna empleado con ID generado                  │
└────────────────┬───────────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────────┐
│ 6. Repository recibe respuesta                         │
│    - Convierte JSON → Empleado                         │
│    - Retorna Future<Empleado>                          │
└────────────────┬───────────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────────┐
│ 7. ViewModel actualiza estado                          │
│    - _empleados.add(nuevoEmpleado)                     │
│    - _isLoading = false                                │
│    - notifyListeners() → UI se refresca                │
└────────────────┬───────────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────────┐
│ 8. HomeScreen (View)                                   │
│    - Consumer recibe notificación                      │
│    - ListView.builder se reconstruye                   │
│    - Nuevo empleado aparece en lista                   │
└────────────────────────────────────────────────────────┘
```

---

## 🚀 Ejecutar el Proyecto

### Backend

```powershell
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

Acceder a docs: http://localhost:8000/docs

### Frontend

```powershell
cd frontend
flutter pub get
flutter run
```

**Importante**: Cambiar `baseUrl` en `main.dart`:
- Emulador Android: `http://10.0.2.2:8000`
- iOS Simulator: `http://localhost:8000`
- Dispositivo físico: `http://TU_IP_LOCAL:8000`

---

## 📚 Recursos Adicionales

- **Flutter Docs**: https://flutter.dev/docs
- **FastAPI Docs**: https://fastapi.tiangolo.com
- **Provider Package**: https://pub.dev/packages/provider
- **SQLAlchemy**: https://docs.sqlalchemy.org
- **JWT.io**: https://jwt.io (decodificar tokens)

---

## ❓ Preguntas Comunes

**¿Cuándo usar StatelessWidget vs StatefulWidget?**
- `StatelessWidget`: Cuando el widget no cambia (UI estática)
- `StatefulWidget`: Cuando necesitas `setState()` para cambios locales
- **Con Provider**: Casi siempre `StatelessWidget` + `Consumer`

**¿Cuándo usar Consumer vs context.read()?**
- `Consumer`: Cuando necesitas reconstruir el widget cuando cambie el estado
- `context.read()`: Cuando solo necesitas ejecutar una acción (no escuchar cambios)

**¿Por qué async/await?**
- JavaScript/Python: Sin async, el código se bloquea
- Dart/Flutter: `async` permite operaciones I/O sin congelar la UI

**¿Qué es el token JWT?**
- Es como una tarjeta de identificación digital
- Contiene tu username y fecha de expiración
- Está firmado, no se puede falsificar
- No guarda la contraseña (solo un identificador)

**¿Future.wait mejora siempre?**
- **Sí** cuando las operaciones son independientes (cargar varios empleados)
- **No** cuando una depende de otra (login → luego cargar datos)

---

## 🚀 Concurrencia Detallada: Future.wait

### Código Completo de Concurrencia

**Ubicación:** `frontend/lib/repositories/empleado_repository.dart`

#### Método Secuencial (Lento)

```dart
Future<ConcurrencyResult> cargarEmpleadosSecuencial(List<int> ids) async {
  final stopwatch = Stopwatch()..start();
  final empleados = <Empleado>[];

  for (final id in ids) {
    try {
      final empleado = await getEmpleadoById(id);
      empleados.add(empleado);
    } catch (e) {
      print('Error cargando empleado $id: $e');
    }
  }

  stopwatch.stop();
  return ConcurrencyResult(
    empleados: empleados,
    tiempoMs: stopwatch.elapsedMilliseconds,
    metodo: 'Secuencial',
  );
}
```

#### Método Paralelo (Rápido)

```dart
Future<ConcurrencyResult> cargarEmpleadosParalelo(List<int> ids) async {
  final stopwatch = Stopwatch()..start();

  final futures = ids.map((id) async {
    try {
      return await getEmpleadoById(id);
    } catch (e) {
      print('Error cargando empleado $id: $e');
      return null;
    }
  }).toList();

  final results = await Future.wait(futures);
  final empleados = results.whereType<Empleado>().toList();

  stopwatch.stop();
  return ConcurrencyResult(
    empleados: empleados,
    tiempoMs: stopwatch.elapsedMilliseconds,
    metodo: 'Paralelo (Future.wait)',
  );
}
```

### Resultados Medidos

| Método | Tiempo | Mejora |
|--------|--------|--------|
| Secuencial | 45 ms | - |
| Paralelo | 9 ms | **80%** |

---

## 📸 Subida de Imágenes

### Backend: Endpoint de Upload

```python
@app.post("/upload-image")
async def upload_image(
    file: UploadFile = File(...),
    current_user: str = Depends(auth.verify_token)
):
    # Validar tipo
    allowed_types = ["image/jpeg", "image/jpg", "image/png", "image/gif"]
    if file.content_type not in allowed_types:
        raise HTTPException(400, "Tipo no permitido")
    
    # Validar tamaño (5MB)
    contents = await file.read()
    if len(contents) > 5 * 1024 * 1024:
        raise HTTPException(400, "Archivo muy grande")
    
    # Generar nombre único
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    unique_filename = f"{timestamp}_{uuid.uuid4().hex[:8]}.{file_extension}"
    
    # Guardar
    file_path = UPLOAD_DIR / unique_filename
    with open(file_path, "wb") as buffer:
        buffer.write(contents)
    
    return {"url": f"http://127.0.0.1:8000/uploads/{unique_filename}"}
```

### Frontend: image_picker

```dart
Future<void> _seleccionarImagen() async {
  // 1. Seleccionar fuente
  final source = await showDialog<ImageSource>(...);
  
  // 2. Elegir imagen
  final XFile? image = await _picker.pickImage(
    source: source,
    maxWidth: 800,
    maxHeight: 800,
    imageQuality: 85,
  );
  
  // 3. Subir al servidor
  final imageUrl = await viewModel.uploadImage(File(image.path));
  
  // 4. Actualizar URL
  setState(() {
    _fotoUrlController.text = imageUrl;
  });
}
```

---

## ❓ FAQ - Preguntas Frecuentes

### Instalación

**P: ¿Qué necesito instalar?**
- Backend: Python 3.8+ 
- Frontend: Flutter SDK
- Base de datos: SQLite (incluido) o PostgreSQL (opcional)

**P: ¿Cómo instalo dependencias?**
```bash
# Backend
cd backend
pip install -r requirements.txt

# Frontend
cd frontend
flutter pub get
```

### Ejecución

**P: ¿Cómo ejecuto el proyecto?**
```bash
# Terminal 1
cd backend
uvicorn main:app --reload

# Terminal 2
cd frontend
flutter run
```

### Errores Comunes

**P: "Connection refused" en Flutter**
- Emulador Android: Usa `http://10.0.2.2:8000`
- iOS: Usa `http://localhost:8000`
- Físico: Usa `http://TU_IP:8000`

**P: "401 Unauthorized"**
- Token expiró (30 min)
- Haz logout y login nuevamente

**P: "Module not found" en Python**
```bash
pip install -r requirements.txt
```

**P: Backend no recarga automáticamente**
- Verifica que tengas `--reload` en uvicorn
- O reinicia manualmente

### Desarrollo

**P: ¿Cómo agrego un nuevo campo a Empleado?**
1. Backend: Agregar columna en `EmpleadoDB` (models.py)
2. Backend: Agregar en schema `EmpleadoCreate`
3. Frontend: Agregar en clase `Empleado` (models/empleado.dart)
4. Frontend: Agregar campo en formulario

**P: ¿Cómo cambio la base de datos?**
Edita `backend/database.py`:
```python
# SQLite
DATABASE_URL = "sqlite:///./empleados.db"

# PostgreSQL
DATABASE_URL = "postgresql://user:pass@host:5432/db"
```

**P: ¿Cómo cambio el tiempo de expiración del token?**
Edita `backend/auth.py`:
```python
ACCESS_TOKEN_EXPIRE_MINUTES = 30  # Cambia a lo que quieras
```

---

## 📚 Recursos Adicionales

### Documentación Oficial
- [Flutter](https://flutter.dev/docs) - Framework de UI
- [FastAPI](https://fastapi.tiangolo.com) - Framework backend
- [Provider](https://pub.dev/packages/provider) - State management
- [SQLAlchemy](https://docs.sqlalchemy.org) - ORM Python
- [JWT.io](https://jwt.io) - Decodificar tokens

### Tutoriales Recomendados
- Flutter Basics: https://flutter.dev/docs/get-started/codelab
- FastAPI Tutorial: https://fastapi.tiangolo.com/tutorial/
- Provider Pattern: https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple

### Comunidad
- Flutter Discord: https://discord.gg/flutter
- r/FlutterDev: https://reddit.com/r/FlutterDev
- Stack Overflow: Tag `flutter` y `fastapi`

---

**Última actualización:** 2024  
**Versión del proyecto:** 1.1.0

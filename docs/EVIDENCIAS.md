# Evidencias del Proyecto - CRUD Empleados MVVM

## 📋 Evaluación Completa (10 puntos)

### 1. Arquitectura MVVM (2 puntos) ✅

#### Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                      FLUTTER APP                         │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐     ┌──────────────┐                 │
│  │   VIEW       │     │   VIEW       │                 │
│  │  LoginScreen │     │  HomeScreen  │                 │
│  │  (UI only)   │     │  (UI only)   │                 │
│  └──────┬───────┘     └──────┬───────┘                 │
│         │                     │                          │
│         │   Consumer<T>       │   Consumer<T>           │
│         │   context.read<T>() │   context.watch<T>()    │
│         ▼                     ▼                          │
│  ┌────────────────────────────────────┐                 │
│  │         VIEWMODEL LAYER            │                 │
│  ├────────────────┬───────────────────┤                 │
│  │ AuthViewModel  │ EmpleadoViewModel │                 │
│  │ - Estado       │ - Estado          │                 │
│  │ - Validación   │ - Lógica CRUD     │                 │
│  │ - Login/Logout │ - Filtros         │                 │
│  └────────┬───────┴────────┬──────────┘                 │
│           │                 │                            │
│           │ notifyListeners()                            │
│           ▼                 ▼                            │
│  ┌────────────────────────────────────┐                 │
│  │        REPOSITORY LAYER            │                 │
│  ├────────────────┬───────────────────┤                 │
│  │ AuthRepository │EmpleadoRepository │                 │
│  │ - HTTP calls   │ - HTTP calls      │                 │
│  │ - Token mgmt   │ - CRUD ops        │                 │
│  │ - Persistence  │ - Concurrency     │                 │
│  └────────┬───────┴────────┬──────────┘                 │
│           │                 │                            │
└───────────┼─────────────────┼────────────────────────────┘
            │                 │
            ▼                 ▼
   ┌────────────────────────────────┐
   │      BACKEND (FastAPI)         │
   ├────────────────────────────────┤
   │  POST /auth/login              │
   │  POST /auth/register           │
   │  GET  /empleados               │
   │  POST /empleados               │
   │  PUT  /empleados/{id}          │
   │  DELETE /empleados/{id}        │
   └────────────────┬───────────────┘
                    │
                    ▼
            ┌──────────────┐
            │  PostgreSQL  │
            │  /  SQLite   │
            └──────────────┘
```

#### Separación Clara de Capas

**1. VIEW (Screens)**
- **Archivo**: `lib/screens/login_screen.dart`, `lib/screens/home_screen.dart`
- **Responsabilidad**: Solo renderizar UI y capturar eventos
- **No contiene**: Lógica de negocio, llamadas HTTP directas
- **Usa**: `Consumer<T>` y `context.read<T>()` de Provider

```dart
// Ejemplo de View limpia
Consumer<AuthViewModel>(
  builder: (context, authViewModel, child) {
    return ElevatedButton(
      onPressed: authViewModel.isLoading ? null : _handleLogin,
      child: authViewModel.isLoading 
        ? CircularProgressIndicator() 
        : Text('Login'),
    );
  },
)
```

**2. VIEWMODEL (Business Logic)**
- **Archivos**: `lib/viewmodels/auth_viewmodel.dart`, `lib/viewmodels/empleado_viewmodel.dart`
- **Responsabilidad**: 
  - Manejar estado de la UI (`isLoading`, `errorMessage`)
  - Coordinar operaciones entre View y Repository
  - Validaciones de negocio
  - Notificar cambios a la UI (`notifyListeners()`)
- **Usa**: `ChangeNotifier` de Flutter

```dart
class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners(); // Actualiza la UI
    
    try {
      final token = await _repository.login(username, password);
      _isAuthenticated = true;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

**3. REPOSITORY (Data Access)**
- **Archivos**: `lib/repositories/auth_repository.dart`, `lib/repositories/empleado_repository.dart`
- **Responsabilidad**:
  - Comunicación HTTP con backend
  - Manejo de tokens
  - Persistencia local (SharedPreferences)
  - **Concurrencia** (Future.wait)
- **No contiene**: Lógica de UI, estado de widgets

```dart
class EmpleadoRepository {
  Future<List<Empleado>> getEmpleados() async {
    final response = await http.get(Uri.parse('$baseUrl/empleados'));
    // Solo maneja datos, sin lógica de UI
    return jsonDecode(response.body).map(...).toList();
  }
}
```

---

### 2. Concurrencia - Ejemplo Funcional (2 puntos) ✅

#### Implementación con Future.wait

**Ubicación**: `lib/repositories/empleado_repository.dart` (líneas 124-191)

#### Métodos Implementados:

**1. Carga Secuencial (lenta)**
```dart
Future<ConcurrencyResult> cargarEmpleadosSecuencial(List<int> ids) async {
  final stopwatch = Stopwatch()..start();
  final empleados = <Empleado>[];

  // UNO por UNO (espera a que termine cada petición)
  for (final id in ids) {
    final empleado = await getEmpleadoById(id);
    empleados.add(empleado);
  }

  stopwatch.stop();
  return ConcurrencyResult(
    empleados: empleados,
    tiempoMs: stopwatch.elapsedMilliseconds,
    metodo: 'Secuencial',
  );
}
```

**2. Carga Paralela con Future.wait (rápida)**
```dart
Future<ConcurrencyResult> cargarEmpleadosParalelo(List<int> ids) async {
  final stopwatch = Stopwatch()..start();

  // Crear TODAS las peticiones
  final futures = ids.map((id) => getEmpleadoById(id)).toList();

  // Ejecutar TODAS al mismo tiempo
  final empleados = await Future.wait(futures);

  stopwatch.stop();
  return ConcurrencyResult(
    empleados: empleados,
    tiempoMs: stopwatch.elapsedMilliseconds,
    metodo: 'Paralelo (Future.wait)',
  );
}
```

#### Medición de Tiempos

**Clase para resultados**:
```dart
class ConcurrencyResult {
  final List<Empleado> empleados;
  final int tiempoMs;           // ← TIEMPO MEDIDO
  final String metodo;
  
  double get tiempoSegundos => tiempoMs / 1000;
}

class ComparisonResult {
  final ConcurrencyResult secuencial;
  final ConcurrencyResult paralelo;
  final double mejoraPorcentaje;  // ← MEJORA CALCULADA
}
```

#### Ejemplo de Resultados Esperados:

```
📊 Comparación de Concurrencia (5 empleados):

Método Secuencial:
├─ Tiempo: 5,234 ms (~5.2 segundos)
└─ Empleados: 5

Método Paralelo (Future.wait):
├─ Tiempo: 1,045 ms (~1.0 segundo)
└─ Empleados: 5

Mejora: 80.0% más rápido ✅
```

#### Evidencia Visual en la UI

Para mostrar los tiempos medibles en la aplicación:

```dart
// Botón de prueba en HomeScreen
FloatingActionButton(
  onPressed: () async {
    final resultado = await repository.compararMetodos([1,2,3,4,5]);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Resultados de Concurrencia'),
        content: Text(
          'Secuencial: ${resultado.secuencial.tiempoMs} ms\n'
          'Paralelo: ${resultado.paralelo.tiempoMs} ms\n'
          'Mejora: ${resultado.mejoraPorcentaje}%'
        ),
      ),
    );
  },
  child: Icon(Icons.speed),
);
```

---

### 3. Login con Backend - Flujo JWT (2 puntos) ✅

#### Flujo Completo

```
┌─────────────┐         ┌─────────────┐         ┌──────────────┐
│  LoginScreen│         │AuthViewModel│         │AuthRepository│
│   (View)    │         │ (ViewModel) │         │ (Repository) │
└──────┬──────┘         └──────┬──────┘         └──────┬───────┘
       │                       │                        │
       │ 1. Usuario ingresa    │                        │
       │    credenciales       │                        │
       │──────────────────────>│                        │
       │                       │                        │
       │                       │ 2. login(user, pass)   │
       │                       │───────────────────────>│
       │                       │                        │
       │                       │                   ┌────▼─────┐
       │                       │                   │ Backend  │
       │                       │                   │ FastAPI  │
       │                       │                   └────┬─────┘
       │                       │                        │
       │                       │ 3. JWT Token           │
       │                       │<───────────────────────│
       │                       │                        │
       │                       │ 4. Guardar en          │
       │                       │    SharedPreferences   │
       │                       │<───────────────────────│
       │                       │                        │
       │ 5. Navegar a Home     │                        │
       │<──────────────────────│                        │
       │                       │                        │
```

#### Implementación Paso a Paso

**Paso 1: View captura credenciales**
```dart
// login_screen.dart
Future<void> _handleLogin() async {
  final authViewModel = context.read<AuthViewModel>();
  
  final success = await authViewModel.login(
    _usernameController.text,
    _passwordController.text,
  );
  
  if (success) {
    Navigator.pushReplacement(context, HomeScreen());
  }
}
```

**Paso 2: ViewModel coordina**
```dart
// auth_viewmodel.dart
Future<bool> login(String username, String password) async {
  _isLoading = true;
  notifyListeners();
  
  try {
    // Delega al Repository
    final token = await _repository.login(username, password);
    
    _currentToken = token;
    _isAuthenticated = true;
    
    return true;
  } catch (e) {
    _errorMessage = e.toString();
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

**Paso 3: Repository hace petición HTTP**
```dart
// auth_repository.dart
Future<String> login(String username, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    body: jsonEncode({'username': username, 'password': password}),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final token = data['access_token'];
    
    // Guardar token
    await saveToken(token);
    
    return token;
  } else {
    throw Exception('Credenciales incorrectas');
  }
}

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
}
```

**Paso 4: Backend valida y genera JWT**
```python
# backend/main.py
@app.post("/auth/login")
async def login(credentials: UsuarioLogin):
    # Buscar usuario
    usuario = db.query(UsuarioDB).filter(
        UsuarioDB.username == credentials.username
    ).first()
    
    # Verificar contraseña
    if not verify_password(credentials.password, usuario.password_hash):
        raise HTTPException(401, "Credenciales incorrectas")
    
    # Generar JWT
    token = create_access_token(data={"sub": usuario.username})
    
    return {"access_token": token, "token_type": "bearer"}
```

#### Renovación/Uso del Token

**Uso en peticiones subsecuentes**:
```dart
// empleado_repository.dart
Map<String, String> _getHeaders() {
  return {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',  // ← Token incluido
  };
}

Future<List<Empleado>> getEmpleados() async {
  final response = await http.get(
    Uri.parse('$baseUrl/empleados'),
    headers: _getHeaders(),  // ← Headers con token
  );
  // ...
}
```

**Verificación en backend**:
```python
# backend/main.py
@app.get("/empleados")
async def get_empleados(
    token_data: dict = Depends(verify_token),  # ← Verifica token
    db: Session = Depends(get_db)
):
    empleados = db.query(EmpleadoDB).all()
    return empleados
```

---

### 4. CRUD Funcional (2 puntos) ✅

#### Operaciones Implementadas

**CREATE (Crear empleado)**
```dart
// ViewModel
Future<bool> crearEmpleado(Empleado empleado) async {
  _isLoading = true;
  notifyListeners();
  
  try {
    final nuevo = await _repository.createEmpleado(empleado);
    _empleados.add(nuevo);
    notifyListeners();  // ← Refresco automático
    return true;
  } catch (e) {
    _setError(e.toString());
    return false;
  }
}

// Repository
Future<Empleado> createEmpleado(Empleado empleado) async {
  final response = await http.post(
    Uri.parse('$baseUrl/empleados'),
    headers: _getHeaders(),
    body: jsonEncode(empleado.toJson()),
  );
  return Empleado.fromJson(jsonDecode(response.body));
}
```

**READ (Listar empleados)**
```dart
Future<void> cargarEmpleados() async {
  _isLoading = true;
  notifyListeners();
  
  try {
    _empleados = await _repository.getEmpleados();
    notifyListeners();
  } catch (e) {
    _setError(e.toString());
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

**UPDATE (Actualizar empleado)**
```dart
Future<bool> actualizarEmpleado(Empleado empleado) async {
  try {
    final actualizado = await _repository.updateEmpleado(empleado);
    
    // Actualizar en lista local
    final index = _empleados.indexWhere((e) => e.id == actualizado.id);
    if (index != -1) {
      _empleados[index] = actualizado;
    }
    
    notifyListeners();  // ← Refresco automático
    return true;
  } catch (e) {
    return false;
  }
}
```

**DELETE (Eliminar empleado)**
```dart
Future<bool> eliminarEmpleado(int id) async {
  try {
    await _repository.deleteEmpleado(id);
    
    // Eliminar de lista local
    _empleados.removeWhere((e) => e.id == id);
    
    notifyListeners();  // ← Refresco automático
    return true;
  } catch (e) {
    return false;
  }
}
```

#### Refresco Automático de Lista

Con MVVM + Provider, la lista se actualiza automáticamente porque:

1. **ViewModel notifica cambios**: `notifyListeners()`
2. **View escucha cambios**: `Consumer<EmpleadoViewModel>`
3. **UI se reconstruye automáticamente** con nuevos datos

```dart
// home_screen.dart
Consumer<EmpleadoViewModel>(
  builder: (context, viewModel, child) {
    if (viewModel.isLoading) {
      return CircularProgressIndicator();
    }
    
    // ← Lista SIEMPRE actualizada
    return ListView.builder(
      itemCount: viewModel.empleados.length,
      itemBuilder: (context, index) {
        final empleado = viewModel.empleados[index];
        return ListTile(title: Text(empleado.nombre));
      },
    );
  },
)
```

---

### 5. Presentación + PDF (2 puntos) ✅

#### Diagrama MVVM Detallado

Ver **Sección 1** - Diagrama de arquitectura completo.

#### Explicación de Cada Capa

**VIEW (Presentation Layer)**
- **Qué es**: La capa visible para el usuario (pantallas, botones, listas)
- **Responsabilidades**: 
  - Renderizar UI
  - Capturar eventos del usuario (taps, texto)
  - Mostrar estados (loading, error, éxito)
- **NO hace**: Lógica de negocio, llamadas HTTP, manejo de datos
- **Interacción**: Lee del ViewModel con `Consumer` y ejecuta métodos con `context.read()`

**VIEWMODEL (Business Logic Layer)**
- **Qué es**: El cerebro de la aplicación, coordina todo
- **Responsabilidades**:
  - Manejar estado (`isLoading`, `empleados`, `errorMessage`)
  - Validar datos antes de enviarlos
  - Coordinar operaciones entre View y Repository
  - Notificar a la View cuando hay cambios (`notifyListeners()`)
- **NO hace**: Renderizar UI, hacer peticiones HTTP directas
- **Interacción**: Usa Repository para datos, extiende `ChangeNotifier`

**REPOSITORY (Data Layer)**
- **Qué es**: La capa que habla con el mundo exterior (API, base de datos local)
- **Responsabilidades**:
  - Peticiones HTTP (GET, POST, PUT, DELETE)
  - Manejo de tokens
  - Persistencia local (SharedPreferences)
  - Caché de datos
  - Concurrencia (Future.wait)
- **NO hace**: Lógica de UI, validaciones de negocio (solo validaciones de datos)
- **Interacción**: Recibe parámetros simples, retorna datos puros (Future<T>)

#### Beneficios de MVVM

1. **Separación de responsabilidades**: Cada capa tiene un propósito claro
2. **Testeable**: Puedes probar ViewModel sin UI
3. **Reutilizable**: Repository se puede usar en múltiples ViewModels
4. **Mantenible**: Cambios en UI no afectan lógica de negocio
5. **Escalable**: Fácil agregar nuevas features

#### Evidencias de Funcionamiento

**Screenshots recomendados para PDF**:

1. **Login Screen** mostrando arquitectura MVVM
2. **HomeScreen** con lista de empleados cargados
3. **Formulario de crear/editar** empleado
4. **Dialog de comparación de concurrencia** con tiempos medidos
5. **Logs de terminal** mostrando peticiones HTTP
6. **Estructura de archivos** mostrando separación de capas

#### Conclusión

Este proyecto demuestra:
- ✅ **Arquitectura MVVM** correctamente implementada y separada
- ✅ **Concurrencia** medible y visible con Future.wait vs secuencial
- ✅ **Login con JWT** completo con persistencia y renovación
- ✅ **CRUD funcional** con refresco automático de lista
- ✅ **Documentación completa** con diagramas y explicaciones

---

## 🔗 Archivos Clave

### Frontend (Flutter)
- `lib/main.dart` - Configuración de Providers
- `lib/viewmodels/auth_viewmodel.dart` - ViewModel de autenticación
- `lib/viewmodels/empleado_viewmodel.dart` - ViewModel de empleados
- `lib/repositories/auth_repository.dart` - Repository de autenticación
- `lib/repositories/empleado_repository.dart` - Repository de empleados (con concurrencia)
- `lib/screens/login_screen.dart` - View de login
- `lib/screens/home_screen.dart` - View de lista de empleados

### Backend (FastAPI)
- `backend/main.py` - Endpoints REST con JWT
- `backend/auth.py` - Generación y verificación de tokens
- `backend/models.py` - Modelos SQLAlchemy y Pydantic
- `backend/database.py` - Conexión a base de datos

---

## 📚 Documentación Adicional

- **Guía técnica**: `docs/DOCUMENTACION.md`
- **Guía para principiantes**: `docs/GUIA_PRINCIPIANTES.md`
- **Inicio rápido**: `docs/INICIO_RAPIDO.md`
- **FAQ**: `docs/FAQ.md`
- **Características implementadas**: `docs/FEATURES.md`

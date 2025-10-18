# Copilot Instructions - CRUD Empleados

## Project Overview

Flutter + FastAPI employee management system with **MVVM architecture**, JWT authentication, async operations, and parallel data loading with measurable concurrency.

## Architecture

**MVVM Pattern (Model-View-ViewModel):**
- **View** (`screens/`) - UI only, no business logic
- **ViewModel** (`viewmodels/`) - Business logic, state management, coordinates operations
- **Repository** (`repositories/`) - Data access, HTTP calls, persistence
- **Model** (`models/`) - Data structures

**Backend (FastAPI):**
- `backend/main.py` - API endpoints, CORS config
- `backend/models.py` - SQLAlchemy models + Pydantic schemas
- `backend/auth.py` - JWT generation/validation, password hashing
- `backend/database.py` - DB connection with dependency injection

**Frontend (Flutter):**
- `frontend/lib/main.dart` - App entry point with MultiProvider setup
- `frontend/lib/models/empleado.dart` - Data model with JSON serialization
- `frontend/lib/repositories/` - Data access layer (HTTP + local storage)
  - `auth_repository.dart` - Authentication, token management
  - `empleado_repository.dart` - CRUD operations, concurrency measurement
- `frontend/lib/viewmodels/` - Business logic and state management
  - `auth_viewmodel.dart` - Auth state, login/logout coordination
  - `empleado_viewmodel.dart` - Employee CRUD coordination
- `frontend/lib/screens/` - UI layer (Views)
  - `login_screen.dart` - Uses AuthViewModel
  - `home_screen.dart` - Uses EmpleadoViewModel
  - `empleado_form_screen.dart` - Create/edit form

## Key Patterns

### MVVM Architecture
**View (Screens):**
- Only renders UI and captures user events
- Uses `Consumer<T>` to listen to ViewModel changes
- Uses `context.read<T>()` to execute ViewModel methods
- No business logic, no HTTP calls

```dart
// View example
Consumer<EmpleadoViewModel>(
  builder: (context, viewModel, child) {
    if (viewModel.isLoading) return CircularProgressIndicator();
    return ListView.builder(
      itemCount: viewModel.empleados.length,
      itemBuilder: (ctx, i) => EmpleadoTile(viewModel.empleados[i]),
    );
  },
)
```

**ViewModel (Business Logic):**
- Extends `ChangeNotifier`
- Manages UI state (`isLoading`, `errorMessage`, data)
- Coordinates operations between View and Repository
- Calls `notifyListeners()` to update Views
- Contains business validations

```dart
// ViewModel example
class EmpleadoViewModel extends ChangeNotifier {
  final EmpleadoRepository _repository;
  
  List<Empleado> _empleados = [];
  bool _isLoading = false;
  
  Future<void> cargarEmpleados() async {
    _isLoading = true;
    notifyListeners(); // Updates UI
    
    try {
      _empleados = await _repository.getEmpleados();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

**Repository (Data Access):**
- Handles HTTP requests
- Manages token persistence (SharedPreferences)
- Implements caching if needed
- Contains concurrency logic (Future.wait)
- Returns `Future<T>` or throws exceptions
- No UI state management

```dart
// Repository example
class EmpleadoRepository {
  Future<List<Empleado>> getEmpleados() async {
    final response = await http.get(
      Uri.parse('$baseUrl/empleados'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body).map(...).toList();
  }
}
```

**Provider Setup in main.dart:**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => AuthViewModel(AuthRepository(baseUrl: API_URL)),
    ),
    ChangeNotifierProxyProvider<AuthViewModel, EmpleadoViewModel>(
      create: (_) => EmpleadoViewModel(...),
      update: (_, authVM, __) => EmpleadoViewModel(
        EmpleadoRepository(token: authVM.currentToken),
      ),
    ),
  ],
  child: MyApp(),
)
```

### Authentication Flow
1. Login → POST /auth/login → JWT token returned
2. Token stored in SharedPreferences
3. All subsequent requests include `Authorization: Bearer <token>`
4. Tokens expire in 30 minutes (configurable in `auth.py`)

### Async/Await Usage
- **Backend**: All endpoints use `async def` for non-blocking I/O
- **Frontend**: All API calls use `async/await` to prevent UI blocking
- **Critical**: Always check `if (!mounted)` before `setState` after async operations

### Parallel Loading (Future.wait)
**Ubicación**: `lib/repositories/empleado_repository.dart` → `cargarEmpleadosParalelo()`, `cargarEmpleadosSecuencial()`, `compararMetodos()`

**Secuencial (lento)**:
```dart
for (final id in ids) {
  final empleado = await getEmpleadoById(id); // Espera uno por uno
  empleados.add(empleado);
}
// Tiempo total: n * tiempo_peticion
```

**Paralelo con Future.wait (rápido)**:
```dart
final futures = ids.map((id) => getEmpleadoById(id)).toList();
final empleados = await Future.wait(futures); // Todas al mismo tiempo
// Tiempo total: ~tiempo_peticion
```

**Medición de tiempos**:
```dart
class ConcurrencyResult {
  final List<Empleado> empleados;
  final int tiempoMs;           // ← Tiempo medido con Stopwatch
  final String metodo;
}

Future<ComparisonResult> compararMetodos(List<int> ids) async {
  final secuencial = await cargarEmpleadosSecuencial(ids);
  final paralelo = await cargarEmpleadosParalelo(ids);
  
  return ComparisonResult(
    secuencial: secuencial,
    paralelo: paralelo,
    mejoraPorcentaje: ((secuencial.tiempoMs - paralelo.tiempoMs) / secuencial.tiempoMs * 100),
  );
}
```

Ejecuta múltiples peticiones HTTP simultáneamente. Incluye clases `ConcurrencyResult` y `ComparisonResult` para medición visible de tiempos.

### Auto-refresh Pattern
After CREATE/UPDATE/DELETE operations, screens automatically refresh:
```dart
Navigator.pop(context, true); // Return success flag
if (result == true) _cargarEmpleados(); // Refresh list
```

## Database Configuration

**PostgreSQL (Production):**
```python
DATABASE_URL = "postgresql://user:pass@host:5432/db_name"
```

**SQLite (Development):**
```python
DATABASE_URL = "sqlite:///./empleados.db"
```

Edit in `backend/database.py` line 6.

## Running the Project

**Backend:**
```powershell
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```
Access docs at: http://localhost:8000/docs

**Frontend:**
```powershell
cd frontend
flutter pub get
flutter run
```

**Important**: Update API URL in `lib/services/api_service.dart`:
- Android emulator: `http://10.0.2.2:8000`
- iOS simulator: `http://localhost:8000`
- Physical device: `http://<LOCAL_IP>:8000`

## Code Conventions

**Backend (Python):**
- Use `async def` for all endpoints
- Pydantic models for validation
- `Depends(auth.verify_token)` for protected endpoints
- `Depends(get_db)` for database sessions

**Frontend (Dart):**
- Private state variables: `_variableName`
- Always dispose controllers in `dispose()`
- Use `const` constructors when possible
- `setState()` only for UI updates

## Security Notes

- Passwords hashed with bcrypt (never stored plain)
- JWT tokens signed with SECRET_KEY (change in production)
- CORS configured in `main.py` - restrict origins in production
- Tokens auto-expire (see `auth.py`)

## Common Tasks

**Add new field to Empleado:**
1. Update `EmpleadoDB` in `backend/models.py`
2. Update `EmpleadoBase` schema
3. Update `Empleado` model in `frontend/lib/models/empleado.dart`
4. Update form in `empleado_form_screen.dart`

**Add new endpoint:**
1. Define in `backend/main.py`
2. Add corresponding method in `frontend/lib/services/api_service.dart`
3. Use `Depends(auth.verify_token)` if protected

**Change token expiration:**
Edit `ACCESS_TOKEN_EXPIRE_MINUTES` in `backend/auth.py`

## Documentation Files

All documentation is in the `docs/` folder:
- `README.md` - Main project overview (root)
- `docs/INDICE.md` - Documentation index and navigation
- `docs/DOCUMENTACION.md` - Technical architecture details
- `docs/GUIA_DESARROLLADORES.md` - Guide for developers with programming experience but new to Flutter/FastAPI/MVVM
- `docs/INICIO_RAPIDO.md` - Quick start guide
- `docs/FEATURES.md` - Implemented features checklist
- `docs/EJEMPLOS_CODIGO.md` - Commented code examples
- `docs/ESTRUCTURA.md` - Project structure overview
- `docs/FAQ.md` - Frequently asked questions
- `docs/EVIDENCIAS.md` - **Evidence document with MVVM diagrams, concurrency measurements, JWT flow, CRUD demonstration**

## Dependencies

**Backend:** fastapi, uvicorn, sqlalchemy, psycopg2-binary, pydantic, python-jose, passlib

**Frontend:** http, provider, shared_preferences, cached_network_image

See `backend/requirements.txt` and `frontend/pubspec.yaml` for versions.

## API Endpoints

```
POST   /auth/login          - Login (returns JWT)
POST   /auth/register       - User registration
GET    /empleados           - List all employees (paginated)
GET    /empleados/{id}      - Get one employee
POST   /empleados           - Create employee
PUT    /empleados/{id}      - Update employee
DELETE /empleados/{id}      - Delete employee
```

All `/empleados` endpoints require JWT authentication.

## Development Workflow

1. Start backend: `uvicorn main:app --reload`
2. Start frontend: `flutter run`
3. Register user via app or curl
4. Login and test CRUD operations
5. Check backend logs in terminal
6. Use Flutter DevTools for frontend debugging

## Troubleshooting

**401 Unauthorized**: Token expired or invalid - re-login
**Connection refused**: Check API URL in `api_service.dart`
**Import errors**: Run `pip install -r requirements.txt` or `flutter pub get`
**DB errors**: Verify DATABASE_URL in `database.py`

For more details, see documentation files in `docs/` folder.

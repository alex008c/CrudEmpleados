# Copilot Instructions - CRUD Empleados

## Project Overview

Flutter + FastAPI employee management system with JWT authentication, async operations, and parallel data loading.

## Architecture

**Backend (FastAPI):**
- `backend/main.py` - API endpoints, CORS config
- `backend/models.py` - SQLAlchemy models + Pydantic schemas
- `backend/auth.py` - JWT generation/validation, password hashing
- `backend/database.py` - DB connection with dependency injection

**Frontend (Flutter):**
- `frontend/lib/main.dart` - App entry point
- `frontend/lib/models/empleado.dart` - Data model with JSON serialization
- `frontend/lib/services/api_service.dart` - HTTP client, token management, Future.wait parallelism
- `frontend/lib/screens/` - Login, home (list), and form screens

## Key Patterns

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
See `api_service.dart` → `cargarDatosYFotosEnParalelo()`:
```dart
final futures = ids.map((id) => getEmpleado(id)).toList();
final results = await Future.wait(futures);
```
Executes multiple HTTP requests simultaneously instead of sequentially.

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
- `docs/GUIA_PRINCIPIANTES.md` - Beginner-friendly explanations
- `docs/INICIO_RAPIDO.md` - Quick start guide
- `docs/FEATURES.md` - Implemented features checklist
- `docs/EJEMPLOS_CODIGO.md` - Commented code examples
- `docs/ESTRUCTURA.md` - Project structure overview
- `docs/FAQ.md` - Frequently asked questions

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

# 💻 Ejemplos de Código Comentados

Este archivo contiene fragmentos de código clave del proyecto con explicaciones detalladas.

---

## 🔐 Backend: Autenticación con JWT

### 1. Generar Token JWT (auth.py)

```python
from datetime import datetime, timedelta
from jose import jwt

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    """
    Crea un JWT token firmado con los datos del usuario.
    
    Args:
        data: Diccionario con info del usuario (ej: {"sub": "username"})
        expires_delta: Tiempo de expiración opcional
    
    Returns:
        String del token JWT codificado
    """
    # Copiar datos para no modificar el original
    to_encode = data.copy()
    
    # Calcular tiempo de expiración
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    
    # Agregar tiempo de expiración a los datos
    to_encode.update({"exp": expire})
    
    # Codificar y firmar el token
    # SECRET_KEY = clave secreta que solo el servidor conoce
    # ALGORITHM = HS256 (algoritmo de firma)
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    
    return encoded_jwt

# Ejemplo de uso:
# token = create_access_token({"sub": "juan123"}, timedelta(minutes=30))
# Resultado: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### 2. Verificar Token (auth.py)

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()  # Extractor de tokens del header Authorization

def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """
    Dependency que verifica si el token JWT es válido.
    FastAPI lo ejecuta automáticamente antes del endpoint.
    
    Args:
        credentials: FastAPI extrae automáticamente el token del header
    
    Returns:
        Username si el token es válido
    
    Raises:
        HTTPException 401 si el token es inválido o expirado
    """
    # Extraer el token del header "Authorization: Bearer <token>"
    token = credentials.credentials
    
    try:
        # Decodificar y verificar firma
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        
        # Extraer username del payload
        username: str = payload.get("sub")
        
        # Si no hay username, el token no es válido
        if username is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token inválido"
            )
        
        return username
        
    except JWTError:
        # Token expirado o firma incorrecta
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido o expirado"
        )

# Uso en endpoint:
# @app.get("/empleados")
# async def get_empleados(current_user: str = Depends(verify_token)):
#     # Si llegamos aquí, el token es válido
#     # current_user contiene el username
```

### 3. Endpoint de Login (main.py)

```python
@app.post("/auth/login", response_model=Token)
async def login(login_data: LoginRequest, db: Session = Depends(get_db)):
    """
    Endpoint de autenticación.
    
    1. Valida credenciales contra la BD
    2. Genera un JWT token si son correctas
    3. Retorna el token al cliente
    """
    # 1. Buscar usuario en la base de datos
    user = db.query(UsuarioDB).filter(
        UsuarioDB.username == login_data.username
    ).first()
    
    # 2. Verificar que existe y la contraseña es correcta
    # verify_password compara el hash guardado con la contraseña ingresada
    if not user or not auth.verify_password(login_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciales incorrectas"
        )
    
    # 3. Generar token JWT válido por 30 minutos
    access_token_expires = timedelta(minutes=auth.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": user.username},  # Payload: username
        expires_delta=access_token_expires
    )
    
    # 4. Retornar token
    return {
        "access_token": access_token,
        "token_type": "bearer"  # Tipo estándar OAuth2
    }
```

---

## 📱 Frontend: Async/Await en Flutter

### 1. Login Asíncrono (login_screen.dart)

```dart
Future<void> _handleLogin() async {
    // Validar formulario primero
    if (!_formKey.currentState!.validate()) return;

    // 1. INICIAR LOADING
    // setState le dice a Flutter que redibuje la UI
    setState(() => _isLoading = true);

    try {
        // 2. LLAMADA ASÍNCRONA AL BACKEND
        // 'await' = espera la respuesta PERO no congela la UI
        // Mientras espera, el usuario ve el spinner girando
        final success = await _apiService.login(
            _usernameController.text.trim(),
            _passwordController.text,
        );

        // 3. VERIFICAR SI EL WIDGET SIGUE MONTADO
        // Importante: si el usuario salió de la pantalla mientras esperaba,
        // no podemos usar setState (causaría error)
        if (!mounted) return;

        // 4. PROCESAR RESULTADO
        if (success) {
            // Login exitoso → Navegar a HomeScreen
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
        } else {
            // Login fallido → Mostrar error
            _showErrorDialog('Credenciales incorrectas. Intenta nuevamente.');
        }
        
    } catch (e) {
        // 5. MANEJAR ERRORES DE RED
        if (!mounted) return;
        _showErrorDialog('Error de conexión: ${e.toString()}');
        
    } finally {
        // 6. DETENER LOADING (siempre se ejecuta)
        if (mounted) {
            setState(() => _isLoading = false);
        }
    }
}
```

### 2. Petición HTTP con Token (api_service.dart)

```dart
Future<List<Empleado>> getEmpleados() async {
    // 1. CARGAR TOKEN DESDE ALMACENAMIENTO LOCAL
    await _loadToken();
    
    try {
        // 2. HACER PETICIÓN HTTP GET
        // Uri.parse convierte string a objeto Uri
        // _getHeaders() incluye el token JWT
        final response = await http.get(
            Uri.parse('$baseUrl/empleados'),
            headers: _getHeaders(),  // {"Authorization": "Bearer <token>"}
        );

        // 3. VERIFICAR STATUS CODE
        if (response.statusCode == 200) {
            // 4. DECODIFICAR JSON
            // response.body es un String, jsonDecode lo convierte a Map/List
            final List<dynamic> data = jsonDecode(response.body);
            
            // 5. CONVERTIR JSON A OBJETOS DART
            // .map aplica Empleado.fromJson a cada elemento
            // .toList() convierte el Iterable a List
            return data.map((json) => Empleado.fromJson(json)).toList();
        }
        
        // Si no es 200, lanzar excepción
        throw Exception('Error al cargar empleados');
        
    } catch (e) {
        // Imprimir error para debug
        print('Error en getEmpleados: $e');
        throw e;  // Re-lanzar para que el llamador lo maneje
    }
}
```

---

## 🚀 Future.wait: Carga Paralela

### Ejemplo Completo (api_service.dart)

```dart
Future<Map<String, dynamic>> cargarDatosYFotosEnParalelo(List<int> empleadoIds) async {
    try {
        // 1. CREAR LISTA DE FUTURES (TAREAS PENDIENTES)
        // .map transforma cada ID en un Future<Empleado>
        // .toList() convierte el Iterable a List<Future<Empleado>>
        final futures = empleadoIds.map((id) => getEmpleado(id)).toList();
        
        // Ejemplo de lo que contiene 'futures':
        // [
        //   Future<Empleado> que pide empleado 1,
        //   Future<Empleado> que pide empleado 2,
        //   Future<Empleado> que pide empleado 3,
        // ]
        
        // 2. EJECUTAR TODAS LAS PETICIONES EN PARALELO
        // Future.wait lanza todas las peticiones AL MISMO TIEMPO
        // Espera a que TODAS terminen antes de continuar
        final empleados = await Future.wait(futures);
        
        // Timeline:
        // Sin Future.wait (secuencial):
        //   T0: Pedir empleado 1
        //   T1: Recibir empleado 1
        //   T1: Pedir empleado 2
        //   T2: Recibir empleado 2
        //   T2: Pedir empleado 3
        //   T3: Recibir empleado 3
        //   Total: 3 segundos
        //
        // Con Future.wait (paralelo):
        //   T0: Pedir empleados 1, 2, 3 simultáneamente
        //   T1: Recibir empleados 1, 2, 3
        //   Total: 1 segundo
        
        // 3. RETORNAR RESULTADOS
        return {
            'success': true,
            'empleados': empleados,
            'count': empleados.length,
        };
        
    } catch (e) {
        print('Error en carga paralela: $e');
        return {
            'success': false,
            'error': e.toString(),
        };
    }
}
```

### Caso de Uso Real (home_screen.dart)

```dart
Future<void> _cargarDatosYFotosEnParalelo() async {
    // Verificar que hay empleados
    if (_empleados.isEmpty) return;

    // Mostrar loading
    setState(() => _isLoading = true);

    try {
        // Tomar IDs de los primeros 3 empleados
        final ids = _empleados.take(3).map((e) => e.id!).toList();
        // ids = [1, 2, 3]
        
        // Llamar al método que usa Future.wait
        final resultado = await _apiService.cargarDatosYFotosEnParalelo(ids);
        
        if (mounted) {
            setState(() => _isLoading = false);
            
            // Mostrar mensaje de éxito
            if (resultado['success']) {
                _showSnackBar(
                    'Cargados ${resultado['count']} empleados en paralelo'
                );
            }
        }
    } catch (e) {
        if (mounted) {
            setState(() => _isLoading = false);
            _showSnackBar('Error: $e', isError: true);
        }
    }
}
```

---

## 🔄 CRUD: Actualización Automática

### Patrón de Navegación con Callback (home_screen.dart)

```dart
void _navegarAFormulario({Empleado? empleado}) async {
    // 1. NAVEGAR A LA PANTALLA DE FORMULARIO
    // push retorna un Future que se resuelve cuando hacemos pop()
    // <bool> indica que esperamos un booleano como resultado
    final resultado = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
            builder: (_) => EmpleadoFormScreen(empleado: empleado),
        ),
    );

    // 2. VERIFICAR EL RESULTADO
    // Si el formulario retornó 'true', significa que hubo cambios
    // (se creó o editó un empleado exitosamente)
    if (resultado == true) {
        // 3. REFRESCAR LA LISTA AUTOMÁTICAMENTE
        _cargarEmpleados();
    }
    
    // Flujo completo:
    // HomeScreen → EmpleadoFormScreen → Guardar → pop(true) → HomeScreen
    //                                                             ↓
    //                                                    _cargarEmpleados()
}
```

### Retornar Resultado desde Formulario (empleado_form_screen.dart)

```dart
Future<void> _guardarEmpleado() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
        // Crear objeto Empleado con los datos del formulario
        final empleado = Empleado(
            id: widget.empleado?.id,  // null si es nuevo, ID si es edición
            nombre: _nombreController.text.trim(),
            apellido: _apellidoController.text.trim(),
            puesto: _puestoController.text.trim(),
            salario: double.parse(_salarioController.text.trim()),
            email: _emailController.text.trim(),
            telefono: _telefonoController.text.trim(),
            fotoUrl: _fotoUrlController.text.trim().isEmpty 
                ? null 
                : _fotoUrlController.text.trim(),
        );

        // Decidir si crear o actualizar
        if (_isEditMode) {
            // Modo edición: PUT
            await _apiService.updateEmpleado(widget.empleado!.id!, empleado);
        } else {
            // Modo creación: POST
            await _apiService.createEmpleado(empleado);
        }

        if (mounted) {
            // CLAVE: Retornar 'true' para indicar éxito
            // HomeScreen recibirá este valor
            Navigator.of(context).pop(true);
        }
        
    } catch (e) {
        if (mounted) {
            setState(() => _isLoading = false);
            _showErrorDialog('Error al guardar: ${e.toString()}');
        }
    }
}
```

---

## 📦 Serialización: Objeto ↔ JSON

### Modelo con Serialización (empleado.dart)

```dart
class Empleado {
    final int? id;
    final String nombre;
    final String apellido;
    final String puesto;
    final double salario;
    final String email;
    final String telefono;
    final String? fotoUrl;
    final DateTime? fechaIngreso;

    Empleado({
        this.id,
        required this.nombre,
        required this.apellido,
        required this.puesto,
        required this.salario,
        required this.email,
        required this.telefono,
        this.fotoUrl,
        this.fechaIngreso,
    });

    // DE-SERIALIZACIÓN: JSON → Objeto Dart
    factory Empleado.fromJson(Map<String, dynamic> json) {
        // 'factory' permite retornar una instancia construida custom
        return Empleado(
            // Extraer cada campo del JSON
            id: json['id'],
            nombre: json['nombre'],
            apellido: json['apellido'],
            puesto: json['puesto'],
            
            // Convertir a double (puede venir como int o double)
            salario: (json['salario'] as num).toDouble(),
            
            email: json['email'],
            telefono: json['telefono'],
            fotoUrl: json['foto_url'],  // Puede ser null
            
            // Parsear fecha si existe
            fechaIngreso: json['fecha_ingreso'] != null 
                ? DateTime.parse(json['fecha_ingreso'])
                : null,
        );
    }

    // SERIALIZACIÓN: Objeto Dart → JSON
    Map<String, dynamic> toJson() {
        return {
            // Solo incluir ID si existe (no en creación)
            if (id != null) 'id': id,
            
            'nombre': nombre,
            'apellido': apellido,
            'puesto': puesto,
            'salario': salario,
            'email': email,
            'telefono': telefono,
            
            // Solo incluir foto_url si existe
            if (fotoUrl != null) 'foto_url': fotoUrl,
            
            // fecha_ingreso lo maneja el servidor
        };
    }

    // Método auxiliar para obtener nombre completo
    String get nombreCompleto => '$nombre $apellido';
}

// Ejemplo de uso:

// 1. JSON → Objeto
String jsonString = '{"id": 1, "nombre": "Juan", "apellido": "Pérez", ...}';
Map<String, dynamic> jsonMap = jsonDecode(jsonString);
Empleado empleado = Empleado.fromJson(jsonMap);
print(empleado.nombreCompleto);  // "Juan Pérez"

// 2. Objeto → JSON
Empleado nuevo = Empleado(nombre: "María", apellido: "González", ...);
Map<String, dynamic> json = nuevo.toJson();
String jsonString = jsonEncode(json);
// Resultado: '{"nombre":"María","apellido":"González",...}'
```

---

## 🔧 Dependency Injection en FastAPI

### Ejemplo de Endpoint con Dependencias (main.py)

```python
from fastapi import Depends
from sqlalchemy.orm import Session

@app.get("/empleados", response_model=List[Empleado])
async def get_empleados(
    skip: int = 0,                                    # Query parameter
    limit: int = 100,                                 # Query parameter
    current_user: str = Depends(auth.verify_token),  # Dependency 1: Auth
    db: Session = Depends(get_db)                     # Dependency 2: Database
):
    """
    FastAPI ejecuta AUTOMÁTICAMENTE:
    1. auth.verify_token() → Valida JWT, retorna username
    2. get_db() → Abre sesión de BD
    
    Si verify_token falla → Retorna 401 automáticamente
    Si todo va bien → Este código se ejecuta
    Al terminar → get_db cierra la sesión automáticamente
    """
    # Aquí current_user ya contiene el username validado
    # Y db ya es una sesión abierta de base de datos
    
    # Consultar empleados
    empleados = db.query(EmpleadoDB).offset(skip).limit(limit).all()
    return empleados
    
    # FastAPI automáticamente:
    # - Convierte empleados a JSON
    # - Cierra la sesión de BD (por el finally en get_db)
    # - Retorna respuesta HTTP 200

# Sin Dependency Injection (como sería manualmente):
# @app.get("/empleados")
# async def get_empleados_manual(skip: int = 0, limit: int = 100):
#     # Extraer token manualmente
#     token = request.headers.get("Authorization")
#     if not token:
#         raise HTTPException(401)
#     # Validar token manualmente
#     try:
#         username = verify_token_manually(token)
#     except:
#         raise HTTPException(401)
#     # Abrir BD manualmente
#     db = SessionLocal()
#     try:
#         empleados = db.query(EmpleadoDB).offset(skip).limit(limit).all()
#         return empleados
#     finally:
#         # Cerrar BD manualmente
#         db.close()

# Dependency Injection hace todo esto automáticamente! 🎉
```

---

## 🎨 UI: ListView con Builder

### Lista Eficiente (home_screen.dart)

```dart
ListView.builder(
    // Cantidad de elementos
    itemCount: _empleados.length,
    
    // Función que construye cada elemento
    // 'context' = contexto de Flutter
    // 'index' = posición (0, 1, 2, ...)
    itemBuilder: (context, index) {
        // Obtener empleado en esta posición
        final empleado = _empleados[index];
        
        // Retornar widget para este elemento
        return Card(
            child: ListTile(
                // Avatar con inicial
                leading: CircleAvatar(
                    child: Text(empleado.nombre[0].toUpperCase()),
                ),
                
                // Título: nombre completo
                title: Text(empleado.nombreCompleto),
                
                // Subtítulo: puesto y salario
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(empleado.puesto),
                        Text('\$${empleado.salario.toStringAsFixed(2)}'),
                    ],
                ),
                
                // Acciones: editar y eliminar
                trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _navegarAFormulario(empleado: empleado),
                        ),
                        IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _eliminarEmpleado(empleado.id!),
                        ),
                    ],
                ),
            ),
        );
    },
)

// ListView.builder es EFICIENTE porque:
// - Si tienes 1000 empleados, solo crea ~15 widgets (los visibles)
// - Al hacer scroll, reutiliza los widgets que salen de pantalla
// - No consume memoria innecesaria
```

---

**Estos ejemplos cubren los patrones más importantes del proyecto. Para más detalles, consulta:**
- [DOCUMENTACION.md](./DOCUMENTACION.md) - Arquitectura completa
- [GUIA_PRINCIPIANTES.md](./GUIA_PRINCIPIANTES.md) - Conceptos explicados
- El código fuente con comentarios completos

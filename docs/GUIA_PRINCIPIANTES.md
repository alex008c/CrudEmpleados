# 📚 Guía para Principiantes - CRUD Empleados

Esta guía explica TODO lo que hace el proyecto paso a paso, pensada para alguien que recién empieza a programar.

---

## 🎯 ¿Qué es este proyecto?

Imagina una aplicación de celular (Flutter) que se comunica con un servidor (FastAPI) para guardar información de empleados en una base de datos.

**Analogía:**
- **Flutter** = La app que ves en tu celular
- **FastAPI** = El mesero que toma tus órdenes
- **Base de datos** = La cocina donde se guarda y prepara todo

---

## 🏗️ ¿Cómo funciona todo junto?

### 1. El Backend (FastAPI) - "El Mesero"

Cuando abres un restaurante, necesitas meseros que:
- Tomen órdenes de los clientes
- Las lleven a la cocina
- Traigan la comida de vuelta

FastAPI hace exactamente eso, pero con datos:

```python
@app.get("/empleados")  # ← Esta es una "ruta" (como una dirección)
async def get_empleados():
    # Aquí va el código que obtiene empleados de la BD
    return empleados  # Retorna los datos al cliente
```

**¿Qué significa `@app.get`?**
- Es un "decorador" que le dice a FastAPI: "cuando alguien visite /empleados, ejecuta esta función"
- `get` = pedir datos (como pedir el menú)
- `post` = enviar datos nuevos (como ordenar comida)
- `put` = actualizar datos (como cambiar tu orden)
- `delete` = borrar datos (como cancelar un plato)

### 2. La Base de Datos - "La Cocina"

La base de datos es como una hoja de Excel gigante que guarda información:

```
Tabla: empleados
+----+--------+-----------+----------+---------+
| id | nombre | apellido  | puesto   | salario |
+----+--------+-----------+----------+---------+
| 1  | Juan   | Pérez     | Gerente  | 5000.00 |
| 2  | María  | González  | Cajera   | 3000.00 |
+----+--------+-----------+----------+---------+
```

**PostgreSQL vs SQLite:**
- **PostgreSQL**: Base de datos "grande" (como una cocina de restaurante)
- **SQLite**: Base de datos "pequeña" (como cocinar en casa)
- Para aprender, SQLite es más fácil

### 3. El Frontend (Flutter) - "La App del Cliente"

Flutter es lo que el usuario ve y toca. Es como la aplicación de Uber Eats en tu celular.

**Flutter está dividido en "screens" (pantallas):**
- `login_screen.dart` = Pantalla de inicio de sesión
- `home_screen.dart` = Pantalla principal con lista de empleados
- `empleado_form_screen.dart` = Formulario para crear/editar

---

## 🔐 Autenticación - "Tu Identificación"

### ¿Qué es JWT?

JWT (JSON Web Token) es como tu credencial de ingreso a un edificio:

1. Llegas a la recepción (login)
2. Muestras tu identificación (usuario + contraseña)
3. Te dan una tarjeta de acceso (JWT token)
4. Usas esa tarjeta para entrar a todos los pisos (endpoints protegidos)

**En código:**

```dart
// Flutter: Login
final response = await http.post(
    Uri.parse('http://localhost:8000/auth/login'),
    body: jsonEncode({
        'username': 'juan',
        'password': 'mipassword'
    }),
);

// Si es exitoso, recibes:
{
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer"
}
```

Ese `access_token` es tu "tarjeta de acceso". Lo guardas y lo usas en todas las peticiones siguientes:

```dart
// Incluir token en peticiones
headers: {
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
}
```

### ¿Por qué hashear contraseñas?

**NUNCA guardes contraseñas en texto plano:**

```python
# ❌ MAL - Cualquiera puede leer esto en la BD
password = "mipassword123"

# ✅ BIEN - Se ve así en la BD
password_hash = "$2b$12$KIxSNh8Hu7zVXjyBBH.qUe..."
```

**¿Qué hace bcrypt?**

Convierte tu contraseña en un "código ilegible":
- `"admin123"` → `"$2b$12$KIxS..."`
- Es imposible revertirlo (como romper un huevo, no puedes "desromperlo")
- Pero puedes verificar si una contraseña coincide

```python
# Al registrar:
hashed = get_password_hash("admin123")
# Guardar 'hashed' en la BD

# Al hacer login:
if verify_password("admin123", hashed):
    print("¡Contraseña correcta!")
```

---

## 🔄 CRUD - Las 4 Operaciones Básicas

CRUD significa:
- **C**reate = Crear
- **R**ead = Leer/Obtener
- **U**pdate = Actualizar
- **D**elete = Eliminar

### 1. CREATE (Crear)

**Backend:**
```python
@app.post("/empleados")
async def create_empleado(empleado: EmpleadoCreate, db: Session = Depends(get_db)):
    # Crear objeto de base de datos
    db_empleado = EmpleadoDB(
        nombre=empleado.nombre,
        apellido=empleado.apellido,
        # ...
    )
    
    # Guardar en BD
    db.add(db_empleado)  # Agregar a la "lista de cambios"
    db.commit()  # Confirmar cambios (como hacer Ctrl+S)
    db.refresh(db_empleado)  # Actualizar con ID generado
    
    return db_empleado
```

**Frontend:**
```dart
Future<Empleado> createEmpleado(Empleado empleado) async {
    final response = await http.post(
        Uri.parse('$baseUrl/empleados'),
        headers: _getHeaders(),  // Incluye token JWT
        body: jsonEncode(empleado.toJson()),  // Objeto → JSON
    );
    
    if (response.statusCode == 201) {
        // JSON → Objeto
        return Empleado.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al crear');
}
```

### 2. READ (Leer)

**Backend:**
```python
@app.get("/empleados")
async def get_empleados(db: Session = Depends(get_db)):
    # SQL: SELECT * FROM empleados
    empleados = db.query(EmpleadoDB).all()
    return empleados
```

**Frontend:**
```dart
Future<List<Empleado>> getEmpleados() async {
    final response = await http.get(
        Uri.parse('$baseUrl/empleados'),
        headers: _getHeaders(),
    );
    
    // Convertir JSON a lista de objetos
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Empleado.fromJson(json)).toList();
}
```

### 3. UPDATE (Actualizar)

**Backend:**
```python
@app.put("/empleados/{empleado_id}")
async def update_empleado(empleado_id: int, empleado_update: EmpleadoUpdate, db: Session = Depends(get_db)):
    # Buscar empleado
    db_empleado = db.query(EmpleadoDB).filter(EmpleadoDB.id == empleado_id).first()
    
    # Actualizar campos
    db_empleado.nombre = empleado_update.nombre
    db_empleado.salario = empleado_update.salario
    
    # Guardar cambios
    db.commit()
    db.refresh(db_empleado)
    
    return db_empleado
```

### 4. DELETE (Eliminar)

**Backend:**
```python
@app.delete("/empleados/{empleado_id}")
async def delete_empleado(empleado_id: int, db: Session = Depends(get_db)):
    # Buscar
    db_empleado = db.query(EmpleadoDB).filter(EmpleadoDB.id == empleado_id).first()
    
    # Eliminar
    db.delete(db_empleado)
    db.commit()
    
    return {"message": "Eliminado"}
```

---

## ⚡ Async/Await - "No Bloquear la Puerta"

### ¿Qué significa "bloqueante"?

Imagina que estás en la puerta de un banco:

**Código bloqueante (malo):**
```
Persona 1 entra → Hace su trámite (10 min) → Sale
                                              ↓
Persona 2 entra → Hace su trámite (10 min) → Sale

Tiempo total: 20 minutos (esperan en fila)
```

**Código async (bueno):**
```
Persona 1 entra → Empieza trámite
Persona 2 entra → Empieza trámite (al mismo tiempo)

Ambos terminan en ~10 minutos
```

### En Flutter:

```dart
// ❌ Código bloqueante (hipotético - no funciona así realmente)
void loginBloqueante() {
    // La UI se congela aquí por 2 segundos
    var result = esperarRespuesta();  
    if (result.success) {
        // ...
    }
}

// ✅ Código async/await
Future<void> loginAsync() async {
    // La UI sigue funcionando mientras espera
    var result = await esperarRespuesta();
    if (result.success) {
        // ...
    }
}
```

**En el login:**

```dart
Future<void> _handleLogin() async {
    // Mostrar spinner (usuario sabe que está cargando)
    setState(() => _isLoading = true);

    try {
        // 'await' = "espera aquí, pero no congeles la app"
        final success = await _apiService.login(username, password);
        
        if (success) {
            // Navegar a siguiente pantalla
            Navigator.pushReplacement(...);
        }
    } finally {
        // Ocultar spinner
        setState(() => _isLoading = false);
    }
}
```

**Mientras espera:**
- El usuario puede ver animaciones
- Puede tocar "cancelar"
- La app responde
- El spinner gira

---

## 🚀 Future.wait - "Hacer Varias Cosas a la Vez"

### Analogía: Lavar Ropa

**Sin Future.wait (secuencial):**
```
1. Lavar ropa blanca (1 hora)
2. Lavar ropa de color (1 hora)
3. Lavar toallas (1 hora)
Total: 3 horas
```

**Con Future.wait (paralelo):**
```
1. Poner las 3 cargas AL MISMO TIEMPO en 3 lavadoras
Total: 1 hora (todas terminan juntas)
```

### En código:

**Sin Future.wait:**
```dart
// Peticiones secuenciales (lentas)
var empleado1 = await getEmpleado(1);  // Espera 1 segundo
var empleado2 = await getEmpleado(2);  // Espera 1 segundo
var empleado3 = await getEmpleado(3);  // Espera 1 segundo
// Total: 3 segundos
```

**Con Future.wait:**
```dart
// Peticiones paralelas (rápidas)
final resultados = await Future.wait([
    getEmpleado(1),  // Se ejecuta
    getEmpleado(2),  // Se ejecuta
    getEmpleado(3),  // Se ejecuta
]);                  // ← Espera a que TODAS terminen

// Total: 1 segundo (el tiempo de la más lenta)
```

**¿Cuándo usar Future.wait?**
- Cuando necesitas cargar varias cosas que no dependen entre sí
- Por ejemplo: cargar datos + cargar imágenes + cargar estadísticas

**Ejemplo real del proyecto:**

```dart
Future<Map<String, dynamic>> cargarDatosYFotosEnParalelo(List<int> empleadoIds) async {
    // Crear lista de "tareas pendientes"
    final futures = empleadoIds.map((id) => getEmpleado(id)).toList();
    
    // Ejecutar todas las tareas al mismo tiempo
    final empleados = await Future.wait(futures);
    
    return {
        'empleados': empleados,
        'count': empleados.length,
    };
}
```

---

## 🎨 Flutter UI - "Construir la Interfaz"

### Estructura básica de un Widget

```dart
class MiPantalla extends StatefulWidget {  // ← Widget con estado
    @override
    State<MiPantalla> createState() => _MiPantallaState();
}

class _MiPantallaState extends State<MiPantalla> {
    // Variables que pueden cambiar
    bool _isLoading = false;
    List<Empleado> _empleados = [];

    @override
    Widget build(BuildContext context) {
        // Aquí describes cómo se ve la pantalla
        return Scaffold(
            appBar: AppBar(title: Text('Mi Pantalla')),
            body: _isLoading
                ? CircularProgressIndicator()  // Si está cargando
                : ListView(...),  // Si ya cargó
        );
    }
}
```

### ¿Qué es setState?

`setState` le dice a Flutter: "algo cambió, redibuja la pantalla"

```dart
// Antes
_isLoading = false;  // Cambia la variable pero no redibuja

// Después
setState(() {
    _isLoading = false;  // Cambia Y redibuja
});
```

**Analogía:**
- Variables = Lo que ves en un espejo
- setState = Mover el espejo para ver el cambio

### Navegación entre pantallas

```dart
// Ir a otra pantalla
Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => OtraPantalla()),
);

// Ir y cerrar la actual
Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => OtraPantalla()),
);

// Volver atrás
Navigator.pop(context);

// Volver con un resultado
Navigator.pop(context, true);
```

---

## 📦 Serialización - "Convertir Objetos ↔ JSON"

### ¿Qué es JSON?

JSON es un formato de texto para compartir datos:

```json
{
    "id": 1,
    "nombre": "Juan",
    "apellido": "Pérez",
    "salario": 5000.0
}
```

### Dart Object → JSON (toJson)

```dart
class Empleado {
    final String nombre;
    final double salario;

    Map<String, dynamic> toJson() {
        return {
            'nombre': nombre,      // Variable de Dart → Clave de JSON
            'salario': salario,
        };
    }
}

// Uso:
var empleado = Empleado(nombre: 'Juan', salario: 5000);
var json = empleado.toJson();  // {'nombre': 'Juan', 'salario': 5000}
var texto = jsonEncode(json);  // '{"nombre":"Juan","salario":5000}'
```

### JSON → Dart Object (fromJson)

```dart
class Empleado {
    final String nombre;
    final double salario;

    factory Empleado.fromJson(Map<String, dynamic> json) {
        return Empleado(
            nombre: json['nombre'],      // Clave de JSON → Variable de Dart
            salario: json['salario'],
        );
    }
}

// Uso:
var texto = '{"nombre":"Juan","salario":5000}';
var json = jsonDecode(texto);  // {'nombre': 'Juan', 'salario': 5000}
var empleado = Empleado.fromJson(json);  // Objeto Empleado
```

**¿Por qué es necesario?**
- HTTP solo entiende texto (JSON)
- Dart trabaja mejor con objetos
- Necesitas convertir ida y vuelta

---

## 🔍 Dependency Injection - "Inyección de Dependencias"

### ¿Qué es una dependencia?

Una dependencia es algo que tu código necesita para funcionar:

```python
# Este endpoint necesita una conexión a la BD
def get_empleados(db: Session):
    return db.query(EmpleadoDB).all()
```

### Inyección automática en FastAPI

```python
# FastAPI inyecta automáticamente la sesión de BD
@app.get("/empleados")
async def get_empleados(
    db: Session = Depends(get_db)  # ← FastAPI llama a get_db() automáticamente
):
    return db.query(EmpleadoDB).all()
```

**¿Cómo funciona?**

1. FastAPI ve `Depends(get_db)`
2. Llama a `get_db()` para obtener una sesión
3. Pasa esa sesión al parámetro `db`
4. Al terminar, cierra la sesión automáticamente

**Ventajas:**
- No tienes que recordar abrir/cerrar conexiones
- Código más limpio
- Menos errores

---

## 🛡️ Validación con Pydantic

```python
class EmpleadoCreate(BaseModel):
    nombre: str  # Debe ser texto
    salario: float  # Debe ser número decimal
    email: str  # Debe ser texto

# Si envías esto:
{
    "nombre": "Juan",
    "salario": "cinco mil",  # ❌ Error: esperaba número
    "email": "juan@example.com"
}

# FastAPI automáticamente retorna error 422
```

**Ventajas:**
- Validación automática
- Errores claros para el cliente
- No tienes que validar manualmente

---

## 📱 Widgets Clave de Flutter

### ListView.builder

```dart
ListView.builder(
    itemCount: _empleados.length,  // Cuántos elementos
    itemBuilder: (context, index) {  // Cómo se ve cada uno
        final empleado = _empleados[index];
        return ListTile(
            title: Text(empleado.nombre),
            subtitle: Text(empleado.puesto),
        );
    },
)
```

**Es eficiente porque:**
- Solo crea los widgets visibles en pantalla
- No crea 1000 widgets si tienes 1000 empleados
- Crea/destruye dinámicamente al hacer scroll

### Form + TextFormField

```dart
final _formKey = GlobalKey<FormState>();

Form(
    key: _formKey,
    child: Column(
        children: [
            TextFormField(
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                    if (value == null || value.isEmpty) {
                        return 'Campo requerido';
                    }
                    return null;  // null = válido
                },
            ),
            ElevatedButton(
                onPressed: () {
                    if (_formKey.currentState!.validate()) {
                        // Todos los campos son válidos
                        _guardar();
                    }
                },
                child: Text('GUARDAR'),
            ),
        ],
    ),
)
```

---

## 🔧 Comandos Importantes

### Backend

```powershell
# Instalar dependencias
pip install -r requirements.txt

# Ejecutar servidor
uvicorn main:app --reload

# Ver documentación interactiva
# Abrir: http://localhost:8000/docs
```

### Frontend

```powershell
# Instalar Flutter
# https://flutter.dev/docs/get-started/install

# Verificar instalación
flutter doctor

# Instalar dependencias
flutter pub get

# Ejecutar app
flutter run

# Limpiar caché
flutter clean
```

---

## 🐛 Errores Comunes y Soluciones

### 1. "Target of URI doesn't exist"

**Causa:** No instalaste las dependencias de Flutter

**Solución:**
```powershell
flutter pub get
```

### 2. "Connection refused" en Flutter

**Causa:** URL incorrecta del backend

**Solución:**
- Android emulator: `http://10.0.2.2:8000`
- iOS simulator: `http://localhost:8000`
- Dispositivo físico: Tu IP local (ej: `http://192.168.1.100:8000`)

### 3. "401 Unauthorized"

**Causa:** Token JWT inválido o expirado

**Solución:**
- Vuelve a hacer login
- Verifica que estás incluyendo el token en headers
- Tokens expiran en 30 minutos

### 4. Backend no inicia

**Causa:** Dependencias no instaladas o BD mal configurada

**Solución:**
```powershell
pip install -r requirements.txt
# Verificar DATABASE_URL en database.py
```

---

## ✅ Checklist para Ejecutar el Proyecto

### Backend:
- [ ] Python instalado
- [ ] Dependencias instaladas (`pip install -r requirements.txt`)
- [ ] Base de datos configurada (PostgreSQL o SQLite)
- [ ] `uvicorn main:app --reload` corriendo
- [ ] Puedes ver http://localhost:8000/docs

### Frontend:
- [ ] Flutter instalado
- [ ] `flutter doctor` sin errores mayores
- [ ] Dependencias instaladas (`flutter pub get`)
- [ ] URL del backend configurada en `api_service.dart`
- [ ] Dispositivo/emulador conectado
- [ ] `flutter run` ejecutándose

### Prueba:
- [ ] Puedes registrar un usuario
- [ ] Puedes hacer login
- [ ] Puedes ver la lista de empleados
- [ ] Puedes crear un empleado
- [ ] Puedes editar un empleado
- [ ] Puedes eliminar un empleado

---

## 🎓 Conceptos Clave para Recordar

1. **REST API** = Servidor que responde a peticiones HTTP
2. **JWT** = Token de autenticación (como una credencial)
3. **CRUD** = Create, Read, Update, Delete (4 operaciones básicas)
4. **Async/await** = Esperar sin congelar la aplicación
5. **Future.wait** = Hacer varias cosas en paralelo
6. **JSON** = Formato de texto para compartir datos
7. **Serialización** = Convertir objetos ↔ JSON
8. **Widget** = Bloque de construcción de UI en Flutter
9. **State** = Datos que pueden cambiar y redibujan la UI
10. **Dependency Injection** = Pasar dependencias automáticamente

---

**¡Felicidades! Ahora entiendes cómo funciona todo el proyecto. 🎉**

Si algo no queda claro, revisa la [DOCUMENTACION.md](./DOCUMENTACION.md) para detalles técnicos más profundos.

# 📚 Guía para Principiantes Absolutos - CRUD Empleados

Esta guía está diseñada para alguien que **NUNCA ha programado** o es su primera vez viendo código. Todo se explica desde cero, con ejemplos del mundo real.

> 💡 **Importante**: No necesitas saber programar para entender esta guía. Lee con calma y todo quedará claro.

---

## 🌟 Antes de Empezar: ¿Qué es Programar?

Programar es **darle instrucciones a una computadora** para que haga algo. Es como escribir una receta de cocina, pero para computadoras.

**Ejemplo simple:**
```
Receta de cocina:
1. Toma 2 huevos
2. Rómpelos en un bowl
3. Bátelos por 2 minutos
4. Cocina en el sartén

Programa de computadora:
1. Toma los datos del usuario
2. Guárdalos en la base de datos
3. Muéstralos en pantalla
4. Permite editarlos o borrarlos
```

---

## 🎯 ¿Qué es este proyecto? (Explicación Ultra Simple)

Imagina que trabajas en una oficina y necesitas un **cuaderno digital** para:
- ✍️ Escribir nombres de empleados
- 📖 Ver la lista de todos los empleados
- ✏️ Corregir información si te equivocaste
- 🗑️ Borrar empleados que ya no trabajan ahí

**Este proyecto hace exactamente eso, pero en tu celular.**

### Las 3 Partes del Proyecto

Piensa en esto como un **restaurante**:

```
┌─────────────────────────────────────────┐
│  1. TU CELULAR (Flutter)                │
│     = El Cliente del Restaurante        │
│     Lo que TÚ ves y tocas               │
└─────────────────┬───────────────────────┘
                  │
                  ↓ "Quiero ver empleados"
                  
┌─────────────────────────────────────────┐
│  2. EL SERVIDOR (FastAPI)               │
│     = El Mesero del Restaurante         │
│     Recibe tus pedidos y los procesa    │
└─────────────────┬───────────────────────┘
                  │
                  ↓ "Déjame buscar eso"
                  
┌─────────────────────────────────────────┐
│  3. BASE DE DATOS (PostgreSQL/SQLite)   │
│     = La Cocina del Restaurante         │
│     Donde se guarda toda la información │
└─────────────────────────────────────────┘
```

**Ejemplo de conversación entre las 3 partes:**

1. **Tú (en el celular)**: "Quiero agregar un nuevo empleado llamado Juan Pérez"
2. **Servidor**: "Ok, voy a guardar eso en la base de datos"
3. **Base de Datos**: "Guardado. Juan Pérez es el empleado #5"
4. **Servidor**: "Listo, le digo al celular que se guardó"
5. **Celular**: "¡Éxito! Empleado agregado" ✅

---

## 📱 Parte 1: El Celular (Flutter) - "Lo que Ves"

**¿Qué es Flutter?**
Es un programa que te permite crear aplicaciones para celular. Piensa en apps como WhatsApp, Instagram o calculadoras. Flutter te ayuda a crearlas.

**En este proyecto, Flutter crea 3 pantallas:**

### Pantalla 1: Login (Inicio de Sesión)
```
┌─────────────────────────┐
│   CRUD Empleados        │
│                         │
│  Usuario: [_______]     │
│  Contraseña: [_____]    │
│                         │
│     [ENTRAR]            │
│                         │
│  ¿No tienes cuenta?     │
│     Regístrate          │
└─────────────────────────┘
```
**¿Para qué sirve?** Para que solo TÚ puedas ver la información (seguridad).

### Pantalla 2: Lista de Empleados
```
┌─────────────────────────┐
│ ← Empleados      ⟳  ⚙  │
│─────────────────────────│
│ 👤 Juan Pérez           │
│    Gerente              │
│    $5,000     [✏️] [🗑️] │
│─────────────────────────│
│ 👤 María González       │
│    Cajera               │
│    $3,000     [✏️] [🗑️] │
│─────────────────────────│
│                  [+]    │
└─────────────────────────┘
```
**¿Para qué sirve?** Para ver todos los empleados y poder tocar botones para editar/borrar.

### Pantalla 3: Formulario (Crear/Editar)
```
┌─────────────────────────┐
│ ← Nuevo Empleado        │
│─────────────────────────│
│  Nombre:                │
│  [____________]          │
│                         │
│  Apellido:              │
│  [____________]          │
│                         │
│  Puesto:                │
│  [____________]          │
│                         │
│  Salario:               │
│  [____________]          │
│                         │
│     [GUARDAR]           │
└─────────────────────────┘
```
**¿Para qué sirve?** Para agregar un empleado nuevo o cambiar datos de uno existente.

---

## 🖥️ Parte 2: El Servidor (FastAPI) - "El Cerebro"

**¿Qué es un servidor?**
Es una computadora que está siempre encendida, esperando a que le pidas cosas. Es como un empleado de McDonald's esperando tu orden.

**En este proyecto, el servidor puede hacer 5 cosas:**

### 1. Login (Dejar Entrar)
```
Tú: "Hola, soy Juan con contraseña 123"
Servidor: *verifica* "Ok, aquí está tu pase" 🎫
```

### 2. Ver Lista (GET)
```
Tú: "¿Qué empleados tienes?"
Servidor: "Tengo a Juan, María y Pedro"
```

### 3. Agregar (POST)
```
Tú: "Agrega a Ana López como Contadora"
Servidor: "Listo, Ana es empleado #4"
```

### 4. Cambiar (PUT)
```
Tú: "Juan ya no es Gerente, ahora es Director"
Servidor: "Actualizado, Juan ahora es Director"
```

### 5. Borrar (DELETE)
```
Tú: "María ya no trabaja aquí"
Servidor: "Eliminada de la lista"
```

**¿Cómo se escribe esto en código?**

No te preocupes por entender cada palabra, solo mira la idea general:

```python
# Esto es Python (el lenguaje del servidor)

# Cuando alguien pida "dame la lista":
@app.get("/empleados")
def ver_empleados():
    # Ve a la base de datos
    # Trae todos los empleados
    # Envíalos de vuelta
    return lista_de_empleados
```

Es como escribir: "Cuando toquen el timbre, abre la puerta y saluda"

---

## 💾 Parte 3: La Base de Datos - "El Archivero"

**¿Qué es una base de datos?**
Es como un Excel gigante que guarda información de forma organizada. Cada fila es un empleado.

**Ejemplo visual:**

```
📊 Tabla: empleados
┌────┬──────────┬───────────┬───────────┬─────────┬─────────────────┐
│ ID │  Nombre  │ Apellido  │  Puesto   │ Salario │     Email       │
├────┼──────────┼───────────┼───────────┼─────────┼─────────────────┤
│ 1  │ Juan     │ Pérez     │ Gerente   │ 5000    │ juan@email.com  │
│ 2  │ María    │ González  │ Cajera    │ 3000    │ maria@email.com │
│ 3  │ Pedro    │ Martínez  │ Vendedor  │ 2500    │ pedro@email.com │
└────┴──────────┴───────────┴───────────┴─────────┴─────────────────┘
```

**Dos tipos de bases de datos en este proyecto:**

1. **SQLite** (Fácil para aprender)
   - Es como un archivo Excel en tu computadora
   - No necesitas instalar nada extra
   - Perfecto para practicar

2. **PostgreSQL** (Profesional)
   - Es como una biblioteca gigante
   - Más rápido y robusto
   - Se usa en empresas reales

---

## 🔐 Parte 4: Seguridad - "¿Cómo Sabe que Eres Tú?"

### 🎫 El Sistema de Pases (JWT)

Imagina que vas a un parque de diversiones:

**Paso 1: Comprar el Boleto (Login)**
```
Tú en la taquilla: "Soy Juan, aquí está mi dinero"
Cajero: *verifica* "Ok, aquí está tu pulsera mágica" 🎫
```

**Paso 2: Usar la Pulsera Todo el Día**
```
Tú en cada juego: *muestras pulsera*
Empleado: "Pulsera válida, adelante"
```

**Paso 3: La Pulsera Expira**
```
Al final del día, la pulsera ya no sirve
Tienes que volver a la taquilla si quieres entrar mañana
```

**En nuestra app:**
- **Pulsera = Token JWT** (un código secreto)
- **Taquilla = Pantalla de Login**
- **Juegos = Ver/Crear/Editar empleados**
- **Expira = Después de 30 minutos**

### 🔒 Contraseñas Seguras (Hashing)

**❌ Forma INCORRECTA de guardar contraseñas:**
```
Base de Datos:
Usuario: juan
Contraseña: 123456  ← ¡Cualquiera puede leerla!
```

**✅ Forma CORRECTA (lo que hace este proyecto):**
```
Base de Datos:
Usuario: juan  
Contraseña: $2b$12$KIxSNh8Hu7zVXjyBBH...  ← ¡Imposible de leer!
```

**¿Cómo funciona?**

Piensa en una máquina de picar carne:
1. Metes carne (tu contraseña "123456")
2. Sale carne molida (código raro "$2b$12$...")
3. **No puedes convertir la carne molida de vuelta a carne**

Pero puedes verificar: si picas la misma carne otra vez, sale igual.

**Ejemplo en la vida real:**

```
Registro:
Tú: "Mi contraseña es 123456"
Servidor: *la pica* "Guardo: $2b$12$KIx..."

Login:
Tú: "Mi contraseña es 123456"
Servidor: *la pica de nuevo* "¿Sale $2b$12$KIx...? ¡Sí! Eres tú"
```

---

## 📋 ¿Qué es CRUD? (Las 4 Operaciones Básicas)

**CRUD** son las siglas de las 4 cosas que puedes hacer con datos:

```
C = CREATE  (Crear)    = Agregar algo nuevo
R = READ    (Leer)     = Ver lo que ya existe
U = UPDATE  (Actualizar) = Cambiar algo existente
D = DELETE  (Borrar)   = Eliminar algo
```

### Ejemplo con una Agenda de Contactos:

**CREATE (Crear):**
```
Tú: "Agregar contacto: Juan 555-1234"
Agenda: "✅ Juan agregado"
```

**READ (Leer):**
```
Tú: "¿Qué contactos tengo?"
Agenda: "Tienes a Juan y María"
```

**UPDATE (Actualizar):**
```
Tú: "El teléfono de Juan ahora es 555-9999"
Agenda: "✅ Juan actualizado"
```

**DELETE (Borrar):**
```
Tú: "Borrar a María"
Agenda: "✅ María eliminada"
```

### En Nuestra App de Empleados:

| Operación | Botón en la App | Lo Que Hace |
|-----------|----------------|-------------|
| **CREATE** | ➕ Botón flotante | Agregar empleado nuevo |
| **READ** | 👁️ Al abrir la app | Ver lista de empleados |
| **UPDATE** | ✏️ Botón editar | Cambiar datos de empleado |
| **DELETE** | 🗑️ Botón basura | Eliminar empleado |

---

## ⚡ Conceptos Importantes (Explicados Simple)

### 1. ¿Qué es "Async/Await"? (No Esperar como Tonto)

**Sin Async (Forma Mala):**
```
Imagina que pides pizza:
1. Llamas a la pizzería ☎️
2. Te quedas PARADO en el teléfono 30 minutos
3. No puedes hacer nada más
4. La pizza llega
5. Recién ahora puedes hacer otra cosa
```

**Con Async (Forma Buena):**
```
1. Llamas a la pizzería ☎️
2. Cuelgas y sigues con tu vida
3. Mientras tanto: ves TV, limpias, juegas
4. DING DONG - llega la pizza
5. La recoges y sigues con lo que hacías
```

**En la app:**

Cuando tocas "Login":
- ❌ **Sin async**: La pantalla se congela hasta que el servidor responde
- ✅ **Con async**: Ves un spinner girando, la app sigue funcionando

**Código de ejemplo (no tienes que entenderlo, solo la idea):**

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

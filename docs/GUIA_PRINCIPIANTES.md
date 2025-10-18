# 🎓 Guía Completa para Principiantes - CRUD Empleados# 📚 Guía para Principiantes Absolutos - CRUD Empleados



> **Audiencia**: Personas con conocimientos básicos de programación que quieren entender e instalar este proyecto desde cero, sin experiencia previa en Flutter, FastAPI o bases de datos.Esta guía está diseñada para alguien que **NUNCA ha programado** o es su primera vez viendo código. Todo se explica desde cero, con ejemplos del mundo real.



---> 💡 **Importante**: No necesitas saber programar para entender esta guía. Lee con calma y todo quedará claro.



## 📑 Tabla de Contenidos---



1. [¿Qué es este proyecto?](#qué-es-este-proyecto)## 🌟 Antes de Empezar: ¿Qué es Programar?

2. [Requisitos del sistema](#requisitos-del-sistema)

3. [Instalación paso a paso](#instalación-paso-a-paso)Programar es **darle instrucciones a una computadora** para que haga algo. Es como escribir una receta de cocina, pero para computadoras.

4. [Conceptos clave explicados](#conceptos-clave)

5. [Cómo funciona la base de datos](#base-de-datos)**Ejemplo simple:**

6. [Cómo iniciar la aplicación](#iniciar-aplicación)```

7. [Uso de la aplicación](#uso-aplicación)Receta de cocina:

8. [Resolución de problemas](#problemas-comunes)1. Toma 2 huevos

2. Rómpelos en un bowl

---3. Bátelos por 2 minutos

4. Cocina en el sartén

## 🎯 ¿Qué es este proyecto?

Programa de computadora:

Este proyecto es una **aplicación completa de gestión de empleados** que incluye:1. Toma los datos del usuario

2. Guárdalos en la base de datos

- ✅ **Backend (servidor)**: Un servidor que maneja los datos de empleados3. Muéstralos en pantalla

- ✅ **Frontend (interfaz)**: Una aplicación visual para interactuar con los datos4. Permite editarlos o borrarlos

- ✅ **Base de datos**: Almacena toda la información```

- ✅ **Autenticación**: Sistema de login con usuario y contraseña

---

### Tecnologías utilizadas (explicadas simple)

## 🎯 ¿Qué es este proyecto? (Explicación Ultra Simple)

| Tecnología | ¿Qué es? | ¿Para qué sirve? |

|------------|----------|------------------|Imagina que trabajas en una oficina y necesitas un **cuaderno digital** para:

| **Python** | Lenguaje de programación | Crear el servidor backend |- ✍️ Escribir nombres de empleados

| **FastAPI** | Framework de Python | Facilita crear APIs REST (servicios web) |- 📖 Ver la lista de todos los empleados

| **Flutter** | Framework de Google | Crear aplicaciones multiplataforma |- ✏️ Corregir información si te equivocaste

| **Dart** | Lenguaje de Flutter | Programar la interfaz de usuario |- 🗑️ Borrar empleados que ya no trabajan ahí

| **SQLite** | Base de datos liviana | Guardar información (no requiere instalación) |

| **JWT** | JSON Web Token | Sistema de autenticación seguro |**Este proyecto hace exactamente eso, pero en tu celular.**



---### Las 3 Partes del Proyecto



## 💻 Requisitos del SistemaPiensa en esto como un **restaurante**:



### ¿Qué necesito tener instalado?```

┌─────────────────────────────────────────┐

#### 1. **Python 3.11 o superior**│  1. TU CELULAR (Flutter)                │

│     = El Cliente del Restaurante        │

**¿Qué es?** Lenguaje de programación para el backend.│     Lo que TÚ ves y tocas               │

└─────────────────┬───────────────────────┘

**¿Cómo verifico si lo tengo?**                  │

```powershell                  ↓ "Quiero ver empleados"

python --version                  

```┌─────────────────────────────────────────┐

│  2. EL SERVIDOR (FastAPI)               │

**¿Cómo lo instalo?**│     = El Mesero del Restaurante         │

1. Ve a: https://www.python.org/downloads/│     Recibe tus pedidos y los procesa    │

2. Descarga **Python 3.11** o superior└─────────────────┬───────────────────────┘

3. ⚠️ **IMPORTANTE**: Durante instalación, marca la opción "Add Python to PATH"                  │

4. Instala normalmente                  ↓ "Déjame buscar eso"

                  

#### 2. **Flutter 3.0 o superior**┌─────────────────────────────────────────┐

│  3. BASE DE DATOS (PostgreSQL/SQLite)   │

**¿Qué es?** Framework de Google para crear aplicaciones móviles/desktop.│     = La Cocina del Restaurante         │

│     Donde se guarda toda la información │

**¿Cómo verifico si lo tengo?**└─────────────────────────────────────────┘

```powershell```

flutter --version

```**Ejemplo de conversación entre las 3 partes:**



**¿Cómo lo instalo?**1. **Tú (en el celular)**: "Quiero agregar un nuevo empleado llamado Juan Pérez"

1. Ve a: https://flutter.dev/docs/get-started/install/windows2. **Servidor**: "Ok, voy a guardar eso en la base de datos"

2. Descarga el SDK de Flutter3. **Base de Datos**: "Guardado. Juan Pérez es el empleado #5"

3. Extrae el archivo ZIP en `C:\src\flutter`4. **Servidor**: "Listo, le digo al celular que se guardó"

4. Agrega `C:\src\flutter\bin` a las variables de entorno PATH5. **Celular**: "¡Éxito! Empleado agregado" ✅

5. Abre una terminal nueva y ejecuta:

```powershell---

flutter doctor

```## 📱 Parte 1: El Celular (Flutter) - "Lo que Ves"

6. Sigue las instrucciones para completar la configuración

**¿Qué es Flutter?**

#### 3. **Visual Studio Code (Recomendado)**Es un programa que te permite crear aplicaciones para celular. Piensa en apps como WhatsApp, Instagram o calculadoras. Flutter te ayuda a crearlas.



**¿Qué es?** Editor de código moderno y gratuito.**En este proyecto, Flutter crea 3 pantallas:**



**¿Cómo lo instalo?**### Pantalla 1: Login (Inicio de Sesión)

1. Ve a: https://code.visualstudio.com/```

2. Descarga e instala┌─────────────────────────┐

3. Instala las extensiones:│   CRUD Empleados        │

   - Python│                         │

   - Flutter│  Usuario: [_______]     │

   - Dart│  Contraseña: [_____]    │

│                         │

#### 4. **Git (Opcional pero recomendado)**│     [ENTRAR]            │

│                         │

**¿Qué es?** Sistema de control de versiones.│  ¿No tienes cuenta?     │

│     Regístrate          │

**¿Cómo lo instalo?**└─────────────────────────┘

1. Ve a: https://git-scm.com/download/win```

2. Descarga e instala con opciones por defecto**¿Para qué sirve?** Para que solo TÚ puedas ver la información (seguridad).



---### Pantalla 2: Lista de Empleados

```

## 🚀 Instalación Paso a Paso┌─────────────────────────┐

│ ← Empleados      ⟳  ⚙  │

### Paso 1: Descargar el Proyecto│─────────────────────────│

│ 👤 Juan Pérez           │

Si tienes Git instalado:│    Gerente              │

```powershell│    $5,000     [✏️] [🗑️] │

git clone https://github.com/alex008c/CrudEmpleados.git│─────────────────────────│

cd CrudEmpleados│ 👤 María González       │

```│    Cajera               │

│    $3,000     [✏️] [🗑️] │

Si no tienes Git:│─────────────────────────│

1. Ve al repositorio en GitHub│                  [+]    │

2. Click en "Code" → "Download ZIP"└─────────────────────────┘

3. Extrae el archivo ZIP```

4. Abre la carpeta en VS Code**¿Para qué sirve?** Para ver todos los empleados y poder tocar botones para editar/borrar.



---### Pantalla 3: Formulario (Crear/Editar)

```

### Paso 2: Instalar Dependencias del Backend┌─────────────────────────┐

│ ← Nuevo Empleado        │

**¿Qué son dependencias?** Librerías de código que el proyecto necesita para funcionar.│─────────────────────────│

│  Nombre:                │

#### 2.1. Abrir terminal en VS Code│  [____________]          │

- Presiona: `Ctrl + Ñ` o ve a "Terminal" → "New Terminal"│                         │

│  Apellido:              │

#### 2.2. Instalar dependencias de Python│  [____________]          │

│                         │

```powershell│  Puesto:                │

cd backend│  [____________]          │

pip install -r requirements.txt│                         │

```│  Salario:               │

│  [____________]          │

**¿Qué está instalando?**│                         │

- `fastapi` - Framework para crear la API│     [GUARDAR]           │

- `uvicorn` - Servidor web para FastAPI└─────────────────────────┘

- `sqlalchemy` - ORM (conecta Python con base de datos)```

- `pydantic` - Validación de datos**¿Para qué sirve?** Para agregar un empleado nuevo o cambiar datos de uno existente.

- `python-jose` - Manejo de tokens JWT

- `passlib` - Encriptación de contraseñas---

- `psycopg2-binary` - Conector PostgreSQL (opcional)

## 🖥️ Parte 2: El Servidor (FastAPI) - "El Cerebro"

**Tiempo estimado**: 1-3 minutos

**¿Qué es un servidor?**

**⚠️ Si aparece un error:**Es una computadora que está siempre encendida, esperando a que le pidas cosas. Es como un empleado de McDonald's esperando tu orden.

```

'pip' no se reconoce como un comando**En este proyecto, el servidor puede hacer 5 cosas:**

```

**Solución**: Reinstala Python asegurándote de marcar "Add Python to PATH"### 1. Login (Dejar Entrar)

```

---Tú: "Hola, soy Juan con contraseña 123"

Servidor: *verifica* "Ok, aquí está tu pase" 🎫

### Paso 3: Configurar la Base de Datos```



#### ¿Qué base de datos usamos?### 2. Ver Lista (GET)

```

El proyecto está configurado para usar **SQLite** por defecto.Tú: "¿Qué empleados tienes?"

Servidor: "Tengo a Juan, María y Pedro"

**¿Qué es SQLite?**```

- Es una base de datos que **NO requiere instalación**

- Se guarda como un archivo simple (`empleados.db`)### 3. Agregar (POST)

- Perfecta para desarrollo y proyectos pequeños```

- No necesita servidor, se ejecuta directamente en la aplicaciónTú: "Agrega a Ana López como Contadora"

Servidor: "Listo, Ana es empleado #4"

**¿Dónde se guarda?**```

En: `backend/empleados.db` (se crea automáticamente)

### 4. Cambiar (PUT)

#### ¿Cómo funciona?```

Tú: "Juan ya no es Gerente, ahora es Director"

1. **Cuando inicias el backend por primera vez**, el archivo `main.py` ejecuta:Servidor: "Actualizado, Juan ahora es Director"

```python```

models.Base.metadata.create_all(bind=engine)

```### 5. Borrar (DELETE)

```

2. Esto lee los modelos en `models.py` y **crea las tablas automáticamente**:Tú: "María ya no trabaja aquí"

   - Tabla `empleados`: id, nombre, apellido, puesto, salario, email, etc.Servidor: "Eliminada de la lista"

   - Tabla `usuarios`: id, username, password_hash, email```



3. **SQLAlchemy** (el ORM) se encarga de todo:**¿Cómo se escribe esto en código?**

   - Crear las tablas si no existen

   - Traducir código Python a SQLNo te preocupes por entender cada palabra, solo mira la idea general:

   - Manejar las conexiones

```python

#### Configuración actual (ver `backend/database.py`)# Esto es Python (el lenguaje del servidor)



```python# Cuando alguien pida "dame la lista":

# Base de datos SQLite (por defecto)@app.get("/empleados")

DATABASE_URL = "sqlite:///./empleados.db"def ver_empleados():

    # Ve a la base de datos

# Para usar PostgreSQL en producción:    # Trae todos los empleados

# DATABASE_URL = "postgresql://usuario:password@localhost:5432/empleados_db"    # Envíalos de vuelta

    return lista_de_empleados

engine = create_engine(```

    DATABASE_URL, 

    connect_args={"check_same_thread": False}  # Solo para SQLiteEs como escribir: "Cuando toquen el timbre, abre la puerta y saluda"

)

```---



**¿Por qué `check_same_thread: False`?**## 💾 Parte 3: La Base de Datos - "El Archivero"

SQLite por defecto solo permite conexiones desde un thread. Esto permite múltiples peticiones simultáneas.

**¿Qué es una base de datos?**

#### ¿Quieres usar PostgreSQL en lugar de SQLite?Es como un Excel gigante que guarda información de forma organizada. Cada fila es un empleado.



**PostgreSQL** es mejor para producción (muchos usuarios):**Ejemplo visual:**



1. **Instalar PostgreSQL**:```

   - Ve a: https://www.postgresql.org/download/📊 Tabla: empleados

   - O usa Supabase (PostgreSQL en la nube): https://supabase.com┌────┬──────────┬───────────┬───────────┬─────────┬─────────────────┐

│ ID │  Nombre  │ Apellido  │  Puesto   │ Salario │     Email       │

2. **Crear base de datos**:├────┼──────────┼───────────┼───────────┼─────────┼─────────────────┤

```sql│ 1  │ Juan     │ Pérez     │ Gerente   │ 5000    │ juan@email.com  │

CREATE DATABASE empleados_db;│ 2  │ María    │ González  │ Cajera    │ 3000    │ maria@email.com │

```│ 3  │ Pedro    │ Martínez  │ Vendedor  │ 2500    │ pedro@email.com │

└────┴──────────┴───────────┴───────────┴─────────┴─────────────────┘

3. **Editar `backend/database.py` línea 5**:```

```python

DATABASE_URL = "postgresql://usuario:password@localhost:5432/empleados_db"**Dos tipos de bases de datos en este proyecto:**

# Comenta la línea de SQLite:

# DATABASE_URL = "sqlite:///./empleados.db"1. **SQLite** (Fácil para aprender)

```   - Es como un archivo Excel en tu computadora

   - No necesitas instalar nada extra

4. **Quitar el parámetro de SQLite**:   - Perfecto para practicar

```python

engine = create_engine(DATABASE_URL)  # Sin connect_args2. **PostgreSQL** (Profesional)

```   - Es como una biblioteca gigante

   - Más rápido y robusto

---   - Se usa en empresas reales



### Paso 4: Instalar Dependencias del Frontend---



```powershell## 🔐 Parte 4: Seguridad - "¿Cómo Sabe que Eres Tú?"

cd frontend

flutter pub get### 🎫 El Sistema de Pases (JWT)

```

Imagina que vas a un parque de diversiones:

**¿Qué está instalando?**

- `provider` - Gestión de estado (patrón Observer)**Paso 1: Comprar el Boleto (Login)**

- `http` - Cliente HTTP para llamar a la API```

- `shared_preferences` - Guardar tokens localmenteTú en la taquilla: "Soy Juan, aquí está mi dinero"

- `cached_network_image` - Optimización de imágenesCajero: *verifica* "Ok, aquí está tu pulsera mágica" 🎫

```

**Tiempo estimado**: 30 segundos - 2 minutos

**Paso 2: Usar la Pulsera Todo el Día**

---```

Tú en cada juego: *muestras pulsera*

### Paso 5: Verificar que Flutter esté listoEmpleado: "Pulsera válida, adelante"

```

```powershell

flutter doctor -v**Paso 3: La Pulsera Expira**

``````

Al final del día, la pulsera ya no sirve

**Deberías ver algo como:**Tienes que volver a la taquilla si quieres entrar mañana

``````

[✓] Flutter (Channel stable, 3.29.2)

[✓] Windows Version (Enabled)**En nuestra app:**

[✓] Chrome - develop for the web- **Pulsera = Token JWT** (un código secreto)

[✓] Visual Studio- **Taquilla = Pantalla de Login**

[✓] VS Code- **Juegos = Ver/Crear/Editar empleados**

```- **Expira = Después de 30 minutos**



**⚠️ Si ves errores en Android:**### 🔒 Contraseñas Seguras (Hashing)

No te preocupes, no los necesitamos. Usaremos Windows o Chrome.

**❌ Forma INCORRECTA de guardar contraseñas:**

---```

Base de Datos:

## 🎮 Cómo Iniciar la AplicaciónUsuario: juan

Contraseña: 123456  ← ¡Cualquiera puede leerla!

### Método 1: Script Automático (MÁS FÁCIL) ⭐```



Vuelve a la raíz del proyecto:**✅ Forma CORRECTA (lo que hace este proyecto):**

```powershell```

cd ..Base de Datos:

```Usuario: juan  

Contraseña: $2b$12$KIxSNh8Hu7zVXjyBBH...  ← ¡Imposible de leer!

Ejecuta el script maestro:```

```powershell

.\start_all.ps1**¿Cómo funciona?**

```

Piensa en una máquina de picar carne:

**¿Qué hace este script?**1. Metes carne (tu contraseña "123456")

1. ✅ Verifica que Python y Flutter estén instalados2. Sale carne molida (código raro "$2b$12$...")

2. ✅ Instala dependencias si faltan3. **No puedes convertir la carne molida de vuelta a carne**

3. ✅ Abre 2 terminales nuevas:

   - Terminal 1: Backend en http://localhost:8000Pero puedes verificar: si picas la misma carne otra vez, sale igual.

   - Terminal 2: Frontend (te pregunta si quieres Windows o Chrome)

**Ejemplo en la vida real:**

---

```

### Método 2: Scripts Separados (2 Terminales)Registro:

Tú: "Mi contraseña es 123456"

Abre **2 terminales en VS Code**:Servidor: *la pica* "Guardo: $2b$12$KIx..."



**Terminal 1 - Backend:**Login:

```powershellTú: "Mi contraseña es 123456"

.\start_backend.ps1Servidor: *la pica de nuevo* "¿Sale $2b$12$KIx...? ¡Sí! Eres tú"

``````



Verás algo como:---

```

🚀 Iniciando Backend FastAPI...## 📋 ¿Qué es CRUD? (Las 4 Operaciones Básicas)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Servidor corriendo en: http://localhost:8000**CRUD** son las siglas de las 4 cosas que puedes hacer con datos:

📚 Documentación API:     http://localhost:8000/docs

💾 Base de datos:         SQLite (empleados.db)```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━C = CREATE  (Crear)    = Agregar algo nuevo

```R = READ    (Leer)     = Ver lo que ya existe

U = UPDATE  (Actualizar) = Cambiar algo existente

**Terminal 2 - Frontend:**D = DELETE  (Borrar)   = Eliminar algo

```powershell```

.\start_frontend.ps1

```### Ejemplo con una Agenda de Contactos:



Selecciona:**CREATE (Crear):**

- **1** para Windows (aplicación de escritorio) ⭐ Recomendado```

- **2** para Chrome (navegador web)Tú: "Agregar contacto: Juan 555-1234"

Agenda: "✅ Juan agregado"

---```



### Método 3: Comandos Manuales**READ (Leer):**

```

Si quieres control total:Tú: "¿Qué contactos tengo?"

Agenda: "Tienes a Juan y María"

**Terminal 1 - Backend:**```

```powershell

cd backend**UPDATE (Actualizar):**

python -m uvicorn main:app --reload```

```Tú: "El teléfono de Juan ahora es 555-9999"

Agenda: "✅ Juan actualizado"

**Terminal 2 - Frontend (Windows):**```

```powershell

cd frontend**DELETE (Borrar):**

flutter run -d windows```

```Tú: "Borrar a María"

Agenda: "✅ María eliminada"

**O para Chrome:**```

```powershell

cd frontend### En Nuestra App de Empleados:

flutter run -d chrome

```| Operación | Botón en la App | Lo Que Hace |

|-----------|----------------|-------------|

---| **CREATE** | ➕ Botón flotante | Agregar empleado nuevo |

| **READ** | 👁️ Al abrir la app | Ver lista de empleados |

## 🎯 Uso de la Aplicación| **UPDATE** | ✏️ Botón editar | Cambiar datos de empleado |

| **DELETE** | 🗑️ Botón basura | Eliminar empleado |

### Primera vez - Crear cuenta

---

1. **Espera a que se abra la ventana de la aplicación**

   - Primera compilación puede tomar 2-3 minutos## ⚡ Conceptos Importantes (Explicados Simple)

   - Se abrirá automáticamente

### 1. ¿Qué es "Async/Await"? (No Esperar como Tonto)

2. **Verás la pantalla de Login**

   - Click en "¿No tienes cuenta? Regístrate aquí"**Sin Async (Forma Mala):**

```

3. **Registrar usuario:**Imagina que pides pizza:

   - **Username**: admin1. Llamas a la pizzería ☎️

   - **Email**: admin@test.com2. Te quedas PARADO en el teléfono 30 minutos

   - **Password**: admin1233. No puedes hacer nada más

   - Click en "Registrarse"4. La pizza llega

5. Recién ahora puedes hacer otra cosa

4. **Iniciar sesión** con tus credenciales```



---**Con Async (Forma Buena):**

```

### Funcionalidades de la App1. Llamas a la pizzería ☎️

2. Cuelgas y sigues con tu vida

#### 📝 Crear Empleado3. Mientras tanto: ves TV, limpias, juegas

1. Click en el botón **+** (esquina inferior derecha)4. DING DONG - llega la pizza

2. Llena el formulario:5. La recoges y sigues con lo que hacías

   - Nombre: Juan```

   - Apellido: Pérez

   - Puesto: Desarrollador**En la app:**

   - Salario: 50000

   - Email: juan.perez@empresa.comCuando tocas "Login":

   - Teléfono: +1234567890- ❌ **Sin async**: La pantalla se congela hasta que el servidor responde

   - URL Foto: https://example.com/foto.jpg (opcional)- ✅ **Con async**: Ves un spinner girando, la app sigue funcionando

3. Click en "Guardar"

**Código de ejemplo (no tienes que entenderlo, solo la idea):**

#### ✏️ Editar Empleado

- Click en el ícono de **lápiz** en la tarjeta del empleado```dart

- Modifica los datos// Flutter: Login

- Click en "Guardar"final response = await http.post(

    Uri.parse('http://localhost:8000/auth/login'),

#### 🗑️ Eliminar Empleado    body: jsonEncode({

- Click en el ícono de **basura** en la tarjeta del empleado        'username': 'juan',

- Confirma la eliminación        'password': 'mipassword'

    }),

#### ⚡ Demo de Concurrencia (IMPORTANTE PARA EVALUACIÓN));



**¿Qué es?**// Si es exitoso, recibes:

Una demostración que compara dos formas de cargar datos:{

- **Secuencial**: Carga uno tras otro (lento)    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",

- **Paralelo**: Carga todos al mismo tiempo con `Future.wait` (rápido)    "token_type": "bearer"

}

**Cómo usarlo:**```

1. **Primero crea al menos 3-5 empleados**

2. Click en el botón **⚡ Demo** (flotante, esquina inferior derecha)Ese `access_token` es tu "tarjeta de acceso". Lo guardas y lo usas en todas las peticiones siguientes:

3. Verás un diálogo mostrando:

   ``````dart

   ⏱️ Carga Secuencial: 850 ms// Incluir token en peticiones

   ⚡ Carga Paralela: 180 msheaders: {

   📊 Mejora: 78.82%    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'

   ```}

```

**¿Por qué es importante?**

- Demuestra el uso de **concurrencia** (Future.wait)### ¿Por qué hashear contraseñas?

- Es uno de los criterios de evaluación (2 puntos)

- Muestra **mediciones reales** de tiempo**NUNCA guardes contraseñas en texto plano:**



---```python

# ❌ MAL - Cualquiera puede leer esto en la BD

## 🔍 Entendiendo los Conceptos Clavepassword = "mipassword123"



### 1. ¿Qué es una API REST?# ✅ BIEN - Se ve así en la BD

password_hash = "$2b$12$KIxSNh8Hu7zVXjyBBH.qUe..."

**Definición simple**: Una forma estándar de comunicación entre aplicaciones por internet.```



**Analogía**: Es como un menú de restaurante:**¿Qué hace bcrypt?**

- El **menú** lista los platillos disponibles (endpoints)

- Tú **pides** un platillo (haces una petición HTTP)Convierte tu contraseña en un "código ilegible":

- La **cocina** prepara tu order (backend procesa)- `"admin123"` → `"$2b$12$KIxS..."`

- Te **traen** la comida (respuesta JSON)- Es imposible revertirlo (como romper un huevo, no puedes "desromperlo")

- Pero puedes verificar si una contraseña coincide

**Endpoints de nuestra API:**

``````python

POST   /auth/login              → Iniciar sesión# Al registrar:

POST   /auth/register           → Registrar usuariohashed = get_password_hash("admin123")

GET    /empleados               → Obtener lista de empleados# Guardar 'hashed' en la BD

GET    /empleados/{id}          → Obtener un empleado

POST   /empleados               → Crear empleado# Al hacer login:

PUT    /empleados/{id}          → Actualizar empleadoif verify_password("admin123", hashed):

DELETE /empleados/{id}          → Eliminar empleado    print("¡Contraseña correcta!")

``````



**Ver la documentación interactiva:**---

Abre en tu navegador: http://localhost:8000/docs

## 🔄 CRUD - Las 4 Operaciones Básicas

---

CRUD significa:

### 2. ¿Qué es JWT (JSON Web Token)?- **C**reate = Crear

- **R**ead = Leer/Obtener

**Definición simple**: Un "ticket" digital que prueba que iniciaste sesión.- **U**pdate = Actualizar

- **D**elete = Eliminar

**¿Cómo funciona?**

### 1. CREATE (Crear)

1. **Login exitoso** → Backend genera un token JWT:

```json**Backend:**

{```python

  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",@app.post("/empleados")

  "token_type": "bearer"async def create_empleado(empleado: EmpleadoCreate, db: Session = Depends(get_db)):

}    # Crear objeto de base de datos

```    db_empleado = EmpleadoDB(

        nombre=empleado.nombre,

2. **Frontend guarda el token** en `SharedPreferences` (memoria local)        apellido=empleado.apellido,

        # ...

3. **Cada petición incluye el token** en las cabeceras HTTP:    )

```    

Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...    # Guardar en BD

```    db.add(db_empleado)  # Agregar a la "lista de cambios"

    db.commit()  # Confirmar cambios (como hacer Ctrl+S)

4. **Backend valida el token** antes de responder    db.refresh(db_empleado)  # Actualizar con ID generado

    

**Ventajas:**    return db_empleado

- ✅ Sin sesiones en el servidor (stateless)```

- ✅ Seguro (firmado digitalmente)

- ✅ Expira automáticamente (30 minutos)**Frontend:**

```dart

---Future<Empleado> createEmpleado(Empleado empleado) async {

    final response = await http.post(

### 3. ¿Qué es MVVM?        Uri.parse('$baseUrl/empleados'),

        headers: _getHeaders(),  // Incluye token JWT

**MVVM = Model-View-ViewModel**        body: jsonEncode(empleado.toJson()),  // Objeto → JSON

    );

**Definición simple**: Una forma de organizar el código separando responsabilidades.    

    if (response.statusCode == 201) {

**Analogía con un restaurante:**        // JSON → Objeto

- **View (Mesero)**: Interactúa con el cliente, muestra la comida        return Empleado.fromJson(jsonDecode(response.body));

- **ViewModel (Gerente)**: Coordina pedidos, maneja lógica de negocio    }

- **Repository (Cocina)**: Prepara la comida, accede a ingredientes (datos)    throw Exception('Error al crear');

- **Model (Ingredientes)**: Los datos puros (empleados, usuarios)}

```

---

### 2. READ (Leer)

### 4. ¿Qué es Future.wait y la Concurrencia?

**Backend:**

**Definición simple**: Ejecutar varias tareas al mismo tiempo en lugar de una tras otra.```python

@app.get("/empleados")

**Analogía**: Lavar la ropaasync def get_empleados(db: Session = Depends(get_db)):

- **Secuencial**: Lavas una prenda, esperas que seque, luego la siguiente. ⏱️ Muy lento    # SQL: SELECT * FROM empleados

- **Paralelo**: Pones todas las prendas en la lavadora a la vez. ⚡ Rápido    empleados = db.query(EmpleadoDB).all()

    return empleados

**En código:**```



**❌ Carga Secuencial (lento):****Frontend:**

```dart```dart

List<Empleado> empleados = [];Future<List<Empleado>> getEmpleados() async {

for (int id in [1, 2, 3, 4, 5]) {    final response = await http.get(

  final emp = await getEmpleadoById(id);  // Espera uno por uno        Uri.parse('$baseUrl/empleados'),

  empleados.add(emp);        headers: _getHeaders(),

}    );

// Tiempo total: 5 peticiones × 200ms = 1000ms    

```    // Convertir JSON a lista de objetos

    final List<dynamic> data = jsonDecode(response.body);

**✅ Carga Paralela (rápido):**    return data.map((json) => Empleado.fromJson(json)).toList();

```dart}

final futures = [1, 2, 3, 4, 5]```

    .map((id) => getEmpleadoById(id))

    .toList();### 3. UPDATE (Actualizar)



List<Empleado> empleados = await Future.wait(futures);**Backend:**

// Tiempo total: ~200ms (todas al mismo tiempo)```python

```@app.put("/empleados/{empleado_id}")

async def update_empleado(empleado_id: int, empleado_update: EmpleadoUpdate, db: Session = Depends(get_db)):

---    # Buscar empleado

    db_empleado = db.query(EmpleadoDB).filter(EmpleadoDB.id == empleado_id).first()

## 🗄️ Cómo Funciona la Base de Datos (SQLite)    

    # Actualizar campos

### Instalación de SQLite    db_empleado.nombre = empleado_update.nombre

    db_empleado.salario = empleado_update.salario

**¡BUENA NOTICIA!** SQLite **NO requiere instalación separada**.    

    # Guardar cambios

**¿Por qué?**    db.commit()

- SQLite viene incluido con Python    db.refresh(db_empleado)

- El paquete `sqlite3` es parte de la biblioteca estándar de Python    

- Solo necesitas instalar `sqlalchemy` (ya lo hiciste con `pip install -r requirements.txt`)    return db_empleado

```

### Proceso de creación automática

### 4. DELETE (Eliminar)

**1. Configuración en `database.py`:**

```python**Backend:**

from sqlalchemy import create_engine```python

@app.delete("/empleados/{empleado_id}")

# URL de conexión a SQLiteasync def delete_empleado(empleado_id: int, db: Session = Depends(get_db)):

DATABASE_URL = "sqlite:///./empleados.db"    # Buscar

    db_empleado = db.query(EmpleadoDB).filter(EmpleadoDB.id == empleado_id).first()

# Crear motor de base de datos    

engine = create_engine(    # Eliminar

    DATABASE_URL,    db.delete(db_empleado)

    connect_args={"check_same_thread": False}    db.commit()

)    

```    return {"message": "Eliminado"}

```

**2. Creación automática en `main.py`:**

```python---

# Esta línea crea todas las tablas automáticamente

models.Base.metadata.create_all(bind=engine)## ⚡ Async/Await - "No Bloquear la Puerta"

```

### ¿Qué significa "bloqueante"?

**¿Qué hace `create_all`?**

1. Lee todos los modelos que heredan de `Base`Imagina que estás en la puerta de un banco:

2. Genera el SQL correspondiente

3. Ejecuta el SQL en la base de datos**Código bloqueante (malo):**

4. Si las tablas ya existen, **no hace nada** (es seguro)```

Persona 1 entra → Hace su trámite (10 min) → Sale

### Ver el contenido de la base de datos                                              ↓

Persona 2 entra → Hace su trámite (10 min) → Sale

**Opción 1: DB Browser for SQLite (Visual)**

1. Descarga: https://sqlitebrowser.org/Tiempo total: 20 minutos (esperan en fila)

2. Abre `backend/empleados.db````

3. Verás las tablas y datos visualmente

**Código async (bueno):**

**Opción 2: Desde la API**```

Ve a: http://localhost:8000/docsPersona 1 entra → Empieza trámite

Prueba el endpoint `GET /empleados`Persona 2 entra → Empieza trámite (al mismo tiempo)



---Ambos terminan en ~10 minutos

```

## ❓ Problemas Comunes y Soluciones

### En Flutter:

### 1. Error: "Python no se reconoce"

```dart

**Solución**:// ❌ Código bloqueante (hipotético - no funciona así realmente)

1. Abre "Variables de entorno"void loginBloqueante() {

2. En "Variables del sistema" → "Path" → "Editar"    // La UI se congela aquí por 2 segundos

3. Agrega: `C:\Python311` y `C:\Python311\Scripts`    var result = esperarRespuesta();  

4. Reinicia la terminal    if (result.success) {

        // ...

---    }

}

### 2. Error: "Puerto 8000 ya está en uso"

// ✅ Código async/await

**Solución**:Future<void> loginAsync() async {

```powershell    // La UI sigue funcionando mientras espera

# Usar otro puerto    var result = await esperarRespuesta();

cd backend    if (result.success) {

python -m uvicorn main:app --reload --port 8001        // ...

```    }

}

Luego actualiza en `frontend/lib/repositories/auth_repository.dart`:```

```dart

final String baseUrl = 'http://localhost:8001';**En el login:**

```

```dart

---Future<void> _handleLogin() async {

    // Mostrar spinner (usuario sabe que está cargando)

### 3. Error: "401 Unauthorized"    setState(() => _isLoading = true);



**Solución**:    try {

1. Cierra la app        // 'await' = "espera aquí, pero no congeles la app"

2. Abre de nuevo        final success = await _apiService.login(username, password);

3. Haz login nuevamente        

4. Los tokens duran 30 minutos        if (success) {

            // Navegar a siguiente pantalla

---            Navigator.pushReplacement(...);

        }

## 📸 Capturar Evidencias para PDF    } finally {

        // Ocultar spinner

### Screenshots recomendados:        setState(() => _isLoading = false);

    }

1. **Pantalla de Login**}

2. **Lista de empleados** (con al menos 5 empleados)```

3. **Formulario de crear/editar**

4. **Diálogo de Demo Concurrencia** ⭐ IMPORTANTE**Mientras espera:**

5. **Estructura de carpetas MVVM**- El usuario puede ver animaciones

6. **Documentación Swagger** (http://localhost:8000/docs)- Puede tocar "cancelar"

- La app responde

---- El spinner gira



## ✅ Checklist Final---



Antes de presentar, verifica:## 🚀 Future.wait - "Hacer Varias Cosas a la Vez"



- [ ] ✅ Backend inicia sin errores### Analogía: Lavar Ropa

- [ ] ✅ Frontend se abre correctamente

- [ ] ✅ Puedes registrar un usuario**Sin Future.wait (secuencial):**

- [ ] ✅ Puedes hacer login```

- [ ] ✅ Puedes crear 5 empleados1. Lavar ropa blanca (1 hora)

- [ ] ✅ Puedes editar un empleado2. Lavar ropa de color (1 hora)

- [ ] ✅ Puedes eliminar un empleado3. Lavar toallas (1 hora)

- [ ] ✅ El botón "Demo Concurrencia" muestra tiemposTotal: 3 horas

- [ ] ✅ Tienes screenshots```

- [ ] ✅ Entiendes MVVM y Future.wait

**Con Future.wait (paralelo):**

---```

1. Poner las 3 cargas AL MISMO TIEMPO en 3 lavadoras

## 🎉 ¡Felicidades!Total: 1 hora (todas terminan juntas)

```

Has completado la instalación y configuración del proyecto.

### En código:

**Siguiente paso**: Revisa `docs/EVIDENCIAS.md` para los criterios de evaluación.

**Sin Future.wait:**

---```dart

// Peticiones secuenciales (lentas)

**¿Necesitas más ayuda?**var empleado1 = await getEmpleado(1);  // Espera 1 segundo

- Lee `docs/INDICE.md` para el mapa completovar empleado2 = await getEmpleado(2);  // Espera 1 segundo

- Consulta `docs/FAQ.md` para preguntas frecuentesvar empleado3 = await getEmpleado(3);  // Espera 1 segundo

- Revisa `docs/GUIA_DESARROLLADORES.md` para detalles técnicos// Total: 3 segundos

```

¡Mucho éxito en tu presentación! 🚀

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

---

## 💡 Conceptos Básicos para Principiantes Absolutos

### ¿Qué es una Terminal o PowerShell?

**Definición simple**: Una ventana donde escribes comandos de texto para controlar tu computadora.

**Analogía**: Es como hablar con tu computadora en su idioma nativo, en lugar de usar botones y menús.

**¿Cómo abrir la terminal en VS Code?**
1. Presiona `Ctrl + Ñ` (o `Ctrl + `` backtick)
2. O ve a "Terminal" → "New Terminal" en el menú

**Ejemplo visual**:
```
┌──────────────────────────────────────────────┐
│ PS D:\MiProyecto>                            │  ← Aquí escribes comandos
│                                              │
│ python --version                             │  ← Lo que escribes
│ Python 3.11.9                                │  ← Lo que responde
│                                              │
│ PS D:\MiProyecto> _                          │  ← Listo para otro comando
└──────────────────────────────────────────────┘
```

---

### ¿Qué significan los comandos que usamos?

**Comandos básicos explicados**:

| Comando | ¿Qué hace? | Analogía |
|---------|------------|----------|
| `cd backend` | **C**hange **D**irectory - Cambiar de carpeta | Entrar a una habitación de tu casa |
| `cd ..` | Volver a la carpeta anterior | Salir de la habitación |
| `pip install` | Instalar paquetes de Python | Descargar apps en tu celular |
| `flutter run` | Ejecutar la aplicación Flutter | Abrir una app en tu celular |
| `python -m uvicorn` | Iniciar el servidor backend | Encender un servidor web |
| `--reload` | Reiniciar automáticamente al guardar | Auto-refresh cuando cambias algo |

**Ejemplo de uso**:
```powershell
# Estás aquí: D:\ProyectosCrud\CrudEmpleados
cd backend                    # Entras a: D:\ProyectosCrud\CrudEmpleados\backend
pip install fastapi          # Descargas el paquete fastapi
python -m uvicorn main:app   # Inicias el servidor
```

---

### 📊 Diagrama Visual del Flujo Completo

```
┌─────────────────────────────────────────────────────────────────┐
│                     TÚ (Usuario)                                │
│                         ▼                                       │
│                 Abres la aplicación                             │
│                         ▼                                       │
│              ┌───────────────────────┐                          │
│              │  PANTALLA DE LOGIN    │                          │
│              │  (Flutter - Frontend) │                          │
│              └───────────┬───────────┘                          │
│                          │                                      │
│                  Usuario: admin                                 │
│                  Password: admin123                             │
│                          │                                      │
│                    [ENTRAR] ← Click                             │
│                          ▼                                      │
├─────────────────────────────────────────────────────────────────┤
│                          │                                      │
│         1. Frontend envía datos por HTTP                        │
│            POST http://localhost:8000/auth/login                │
│            Body: { "username": "admin", "password": "..." }     │
│                          │                                      │
│                          ▼                                      │
│              ┌───────────────────────┐                          │
│              │   BACKEND (FastAPI)   │                          │
│              │   Servidor Python     │                          │
│              └───────────┬───────────┘                          │
│                          │                                      │
│         2. Backend verifica contraseña                          │
│            - Busca usuario en BD                                │
│            - Compara password (bcrypt)                          │
│                          │                                      │
│                    ¿Es correcto?                                │
│                          │                                      │
│                    SÍ ─────────┐                                │
│                          │     │                                │
│                          ▼     │                                │
│              ┌───────────────────────┐                          │
│              │ BASE DE DATOS SQLite  │                          │
│              │  empleados.db         │                          │
│              │                       │                          │
│              │ Tabla: usuarios       │                          │
│              │ - id: 1               │                          │
│              │ - username: admin     │                          │
│              │ - password_hash: $2b$ │                          │
│              └───────────┬───────────┘                          │
│                          │                                      │
│         3. Genera token JWT                                     │
│            Token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."   │
│                          │                                      │
│                          ▼                                      │
│         4. Devuelve token al Frontend                           │
│            Response: { "access_token": "...", "token_type": "bearer" }
│                          │                                      │
│                          ▼                                      │
│              ┌───────────────────────┐                          │
│              │  FRONTEND             │                          │
│              │  Guarda token         │                          │
│              │  SharedPreferences    │                          │
│              └───────────┬───────────┘                          │
│                          │                                      │
│         5. Redirige a Home Screen                               │
│                          │                                      │
│                          ▼                                      │
│              ┌───────────────────────┐                          │
│              │ LISTA DE EMPLEADOS    │                          │
│              │                       │                          │
│              │ ┌─────────────────┐   │                          │
│              │ │ Juan Pérez      │   │                          │
│              │ │ Desarrollador   │   │                          │
│              │ └─────────────────┘   │                          │
│              │                       │                          │
│              │ ┌─────────────────┐   │                          │
│              │ │ María García    │   │                          │
│              │ │ Diseñadora      │   │                          │
│              │ └─────────────────┘   │                          │
│              │                       │                          │
│              │  [+] Nuevo empleado   │                          │
│              └───────────────────────┘                          │
│                                                                 │
│         Cada petición incluye:                                  │
│         Header: "Authorization: Bearer <token>"                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

FLUJO COMPLETO: Frontend ←HTTP→ Backend ←SQL→ Base de Datos
```

---

### 📖 Glosario de Términos Técnicos (Diccionario Simple)

| Término | Significado Simple | Ejemplo |
|---------|-------------------|---------|
| **API** | Application Programming Interface - Una forma estándar de que 2 programas se comuniquen | Como un menú de restaurante: lista lo que puedes pedir |
| **Backend** | Servidor que procesa datos y lógica de negocio | La cocina de un restaurante |
| **Frontend** | Interfaz que ves y tocas | El comedor del restaurante |
| **Base de Datos (BD)** | Lugar donde se guardan datos de forma organizada | Un archivero digital |
| **HTTP** | Protocolo para enviar información por internet | El idioma que hablan los navegadores |
| **JSON** | Formato de texto para compartir datos | `{ "nombre": "Juan", "edad": 25 }` |
| **Token** | Credencial digital que prueba tu identidad | Como una pulsera en un festival |
| **Endpoint** | Una dirección específica en el servidor | `/empleados` = ruta para empleados |
| **GET/POST/PUT/DELETE** | Tipos de peticiones HTTP (CRUD) | GET = Leer, POST = Crear, etc. |
| **Async/Await** | Esperar respuesta sin bloquear | Como hacer otras cosas mientras esperas el microondas |
| **Framework** | Conjunto de herramientas para programar más fácil | Como un set de LEGO para construir |
| **ORM** | Object-Relational Mapping - Traduce Python ↔ SQL | Traductor automático de idiomas |
| **Hash** | Convertir texto en código irreversible | Contraseña "123" → "$2b$12$KIX..." |
| **CORS** | Seguridad para controlar quién accede a tu API | Lista de invitados VIP |
| **Widget** | Bloque de construcción en Flutter | Como piezas de LEGO para UI |
| **State** | Datos que pueden cambiar en tu app | Estado de "cargando..." vs "listo" |
| **Provider** | Sistema para compartir datos entre pantallas | Como un buzón compartido en un edificio |

---

### � Flujo de Ejecución Paso a Paso

**¿Qué pasa cuando ejecutas los comandos?**

#### Al ejecutar `pip install -r requirements.txt`:

```
1. PowerShell lee el archivo requirements.txt
2. Ve la lista de paquetes:
   - fastapi==0.104.1
   - uvicorn==0.24.0
   - sqlalchemy==2.0.23
   - etc.
3. Se conecta a PyPI (repositorio de Python)
4. Descarga cada paquete (.whl files)
5. Los instala en: C:\...\Python311\Lib\site-packages\
6. Ahora puedes hacer: import fastapi
```

#### Al ejecutar `python -m uvicorn main:app --reload`:

```
1. Python busca el archivo main.py
2. Lee la línea: app = FastAPI()
3. Crea el servidor web
4. Lee todos los @app.get, @app.post (endpoints)
5. Conecta a la base de datos (database.py)
6. Crea las tablas si no existen (create_all)
7. Abre el puerto 8000
8. Imprime: "Uvicorn running on http://127.0.0.1:8000"
9. Queda esperando peticiones...
10. Si guardas un archivo, reinicia automáticamente (--reload)
```

#### Al ejecutar `flutter run -d windows`:

```
1. Flutter lee pubspec.yaml
2. Descarga dependencias (provider, http, etc.)
3. Lee lib/main.dart
4. Compila Dart → Código nativo de Windows
5. Crea archivo .exe
6. Abre ventana de la aplicación
7. Muestra la primera pantalla (LoginScreen)
8. Queda esperando interacciones...
9. Si guardas código, hace hot-reload (actualización rápida)
```

---

### 🎯 Resumen Ultra Simple del Proyecto

**Si solo pudieras recordar 3 cosas:**

1. **Backend (FastAPI)** = Servidor que guarda y da datos de empleados
   - Puerto 8000
   - Usa SQLite (archivo empleados.db)
   - Protegido con JWT

2. **Frontend (Flutter)** = App visual para ver/editar empleados
   - Se conecta al backend
   - Arquitectura MVVM (3 capas separadas)
   - Demuestra concurrencia con Future.wait

3. **Para iniciar** = 2 comandos en 2 terminales:
   ```powershell
   # Terminal 1
   .\start_backend.ps1
   
   # Terminal 2
   .\start_frontend.ps1
   ```

---

### 📺 Recursos Visuales (para aprender más)

**Videos recomendados (YouTube):**

- "¿Qué es una API REST?" → Busca: "API REST en 10 minutos"
- "Flutter para principiantes" → Busca: "Flutter tutorial español"
- "Qué es JWT" → Busca: "JWT authentication explained"
- "Python FastAPI tutorial" → Busca: "FastAPI crash course"

**Herramientas para practicar:**

1. **DB Browser for SQLite** → Ver datos en empleados.db
   - https://sqlitebrowser.org/

2. **Postman** → Probar el backend sin el frontend
   - https://www.postman.com/
   - Puedes hacer peticiones GET, POST, PUT, DELETE

3. **Flutter DevTools** → Ver widgets y estado en tiempo real
   - Ya viene con Flutter

---

### ✨ Consejos Finales

**Si te pierdes:**
1. Lee `INICIO.md` - Guía rápida de 5 minutos
2. Ejecuta `.\start_all.ps1` - Inicia todo automáticamente
3. Abre http://localhost:8000/docs - Prueba el backend

**Si algo no funciona:**
1. Lee la sección "Problemas Comunes" arriba
2. Verifica que Python y Flutter estén instalados
3. Revisa que el backend esté corriendo (puerto 8000)

**Para la evaluación:**
1. Demuestra el CRUD completo (crear, editar, eliminar)
2. Muestra el botón "Demo Concurrencia" (⚡ tiempos medidos)
3. Explica la arquitectura MVVM con el diagrama de `docs/EVIDENCIAS.md`

---

**¡Felicidades! Ahora entiendes TODO el proyecto desde cero. 🎉**

**Siguiente paso**: 
- Lee `docs/EVIDENCIAS.md` para ver los criterios de evaluación
- Prueba la app siguiendo esta guía
- Toma screenshots para tu presentación

Si algo no queda claro, revisa:
- `docs/GUIA_DESARROLLADORES.md` - Detalles técnicos
- `docs/FAQ.md` - Preguntas frecuentes
- `docs/INDICE.md` - Mapa completo de documentación

¡Mucho éxito! 🚀

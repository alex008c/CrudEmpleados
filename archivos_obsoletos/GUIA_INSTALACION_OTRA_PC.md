# 🚀 GUÍA DE INSTALACIÓN Y EJECUCIÓN - OTRA PC

Esta guía te permitirá ejecutar el proyecto CRUD Empleados en cualquier PC Windows desde cero.

---

## 📋 REQUISITOS PREVIOS

### 1. Instalar Python 3.11+
- Descargar: https://www.python.org/downloads/
- ✅ **IMPORTANTE:** Marcar "Add Python to PATH" durante instalación
- Verificar: `python --version`

### 2. Instalar Flutter
- Descargar: https://docs.flutter.dev/get-started/install/windows
- Descomprimir en `C:\src\flutter`
- Agregar a PATH: `C:\src\flutter\bin`
- Verificar: `flutter doctor`

### 3. Instalar Git
- Descargar: https://git-scm.com/download/win
- Verificar: `git --version`

### 4. Instalar AWS CLI (Opcional - solo para logs)
- Descargar: https://awscli.amazonaws.com/AWSCLIV2.msi
- Configurar con: `aws configure`

---

## 📥 PASO 1: CLONAR EL PROYECTO

```powershell
# Clonar repositorio
git clone https://github.com/alex008c/CrudEmpleados.git
cd CrudEmpleados
```

---

## 🔧 PASO 2: INSTALAR DEPENDENCIAS

### Backend (Python)
```powershell
cd backend
pip install -r requirements.txt
cd ..
```

### BFF (Python)
```powershell
cd bff
pip install -r requirements.txt
cd ..
```

### Frontend (Flutter)
```powershell
cd frontend
flutter pub get
cd ..
```

---

## 🔐 PASO 3: CREDENCIALES Y CONFIGURACIÓN

### ✅ Credenciales del Sistema (COPIAR EXACTAMENTE)

#### A. Supabase PostgreSQL
```
URL: postgresql://postgres.fnokvvuodtuewfasqrvp:e0dFVQPJeZLdLAV2@aws-1-us-east-2.pooler.supabase.com:6543/postgres

Desglosado:
- Host: aws-1-us-east-2.pooler.supabase.com
- Puerto: 6543
- Usuario: postgres.fnokvvuodtuewfasqrvp
- Password: e0dFVQPJeZLdLAV2
- Database: postgres
```

#### B. AWS SNS/SQS/SES
```
API Gateway URL: https://bnxlpofo59.execute-api.us-east-1.amazonaws.com/dev/publish
API Key: eCR8TZw9xf6zHrf5so2sE3vhKIxKJbqk9BqE4vgJ
Region: us-east-1
```

#### C. AWS Resources
```
ALB DNS: crud-app-alb-465693216.us-east-1.elb.amazonaws.com
Lambda CRUD: crud-app-crud-lambda
Lambda BFF: crud-app-bff-lambda
Lambda Email: crud-app-email-lambda
SNS Topic: crud-app-email-topic
SQS Queue: crud-app-email-queue
```

#### D. Email Verificado (SES)
```
Email verificado: alexfrank.af04@gmail.com
Estado: SUCCESS (SendingEnabled: true)

NOTA: En Sandbox Mode, solo envía a emails verificados
```

---

## ▶️ PASO 4: EJECUTAR EL SISTEMA

### Opción A: Script Automático (RECOMENDADO)

```powershell
# Ejecutar todo de una vez
.\start.ps1
```

Esto abrirá 3 ventanas:
1. **Backend FastAPI** (puerto 8000)
2. **BFF Email Service** (puerto 8001)
3. **Frontend Flutter** (Windows)

---

### Opción B: Manual (3 Terminales Separadas)

#### Terminal 1 - Backend
```powershell
cd backend
$env:DATABASE_URL = "postgresql://postgres.fnokvvuodtuewfasqrvp:e0dFVQPJeZLdLAV2@aws-1-us-east-2.pooler.supabase.com:6543/postgres"
python -m uvicorn main:app --reload
```

**Verificar:**
- Console muestra: `Application startup complete.`
- Abrir: http://localhost:8000/docs

---

#### Terminal 2 - BFF
```powershell
cd bff
$env:PUBLISH_API_URL = "https://bnxlpofo59.execute-api.us-east-1.amazonaws.com/dev/publish"
$env:PUBLISH_API_KEY = "eCR8TZw9xf6zHrf5so2sE3vhKIxKJbqk9BqE4vgJ"
python -m uvicorn main:app --reload --port 8001
```

**Verificar:**
- Console muestra: `Application startup complete.`
- Abrir: http://localhost:8001

---

#### Terminal 3 - Frontend
```powershell
cd frontend
flutter run -d windows
```

**Esperar:**
- Compilación tarda 1-2 minutos la primera vez
- Se abrirá automáticamente la aplicación Windows

---

## 🧪 PASO 5: PROBAR EL SISTEMA

### 1. Login
- Usuario: `admin`
- Contraseña: `admin123`

**Si no existe el usuario, registrarse primero:**
- Clic en "¿No tienes cuenta? Regístrate"
- Crear usuario nuevo

---

### 2. CRUD de Empleados

#### Crear Empleado
1. Botón flotante `+` (abajo derecha)
2. Llenar formulario
3. **Email:** `alexfrank.af04@gmail.com` (para recibir notificación)
4. Guardar

#### Ver Empleados
- Lista principal muestra todos los empleados de Supabase
- Pull-to-refresh para actualizar

#### Editar Empleado
- Clic en icono de lápiz
- Modificar datos
- Guardar

#### Eliminar Empleado
- Clic en icono de basura
- Confirmar eliminación

---

### 3. Verificar Notificaciones Email

**IMPORTANTE:** El sistema está en **AWS SES Sandbox Mode**

**Comportamiento actual:**
- ✅ Emails se envían correctamente desde AWS
- ✅ Logs de CloudWatch confirman envío
- ⚠️ Gmail puede bloquear emails (filtro anti-spam)

**Para verificar que funciona:**

#### Opción A: Ver Logs de CloudWatch
```powershell
# Instalar AWS CLI primero
aws configure
# Ingresar credenciales (pedir al admin del proyecto)

# Ver logs
aws logs tail /aws/lambda/crud-app-email-lambda --since 5m --region us-east-1
```

Buscar: `✅ Correo enviado correctamente!`

#### Opción B: Prueba Manual
```powershell
# Enviar email de prueba
$body = @{
    to = 'alexfrank.af04@gmail.com'
    subject = 'Prueba CRUD'
    body = 'Sistema funcionando'
} | ConvertTo-Json

Invoke-RestMethod -Uri 'http://localhost:8001/notify/email' -Method POST -Body $body -ContentType 'application/json'
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Correo enviado correctamente"
}
```

---

## 🔍 VERIFICACIÓN DEL SISTEMA

### Backend FastAPI
```powershell
# Verificar empleados en Supabase
curl http://localhost:8000/empleados
# Debería retornar: "Not authenticated" (normal, requiere JWT)

# Documentación interactiva
Abrir: http://localhost:8000/docs
```

### BFF Email Service
```powershell
# Health check
curl http://localhost:8001/health
# Debería retornar: {"status":"healthy"}
```

### Base de Datos Supabase
```powershell
# Script de verificación
cd backend
python check_db.py
# Muestra todos los empleados en la DB
```

---

## 🌐 ARQUITECTURA DEL SISTEMA

```
┌─────────────┐
│  Frontend   │ ← Flutter Windows App (localhost)
│   Flutter   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Backend   │ ← FastAPI + JWT (puerto 8000)
│   FastAPI   │
└──────┬──────┘
       │
       ├────────────────────┐
       │                    │
       ▼                    ▼
┌─────────────┐      ┌─────────────┐
│  Supabase   │      │     BFF     │ ← Email Service (puerto 8001)
│ PostgreSQL  │      │  (proxy)    │
└─────────────┘      └──────┬──────┘
                            │
                            ▼
                     ┌─────────────┐
                     │  AWS Cloud  │
                     │  SNS → SQS  │
                     │  → Lambda   │
                     │  → SES      │
                     └─────────────┘
```

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### ❌ Error: "python no reconocido"
**Solución:**
```powershell
# Verificar instalación
python --version

# Si no funciona, agregar a PATH manualmente:
# Panel de Control → Sistema → Variables de entorno
# Agregar: C:\Users\TU_USUARIO\AppData\Local\Programs\Python\Python311
```

---

### ❌ Error: "flutter no reconocido"
**Solución:**
```powershell
# Verificar instalación
flutter doctor

# Agregar a PATH:
# C:\src\flutter\bin
```

---

### ❌ Error: "Port 8000 already in use"
**Solución:**
```powershell
# Matar proceso en puerto 8000
$process = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess
if ($process) { Stop-Process -Id $process -Force }
```

---

### ❌ Error: "Connection refused to localhost"
**Solución:**
1. Verificar que backend esté corriendo (Terminal 1)
2. Verificar que BFF esté corriendo (Terminal 2)
3. Reiniciar frontend (Hot Restart con `R` en terminal Flutter)

---

### ❌ Error: "Not authenticated" en API
**Solución:**
- Es normal, necesitas hacer login primero
- Usar Swagger UI: http://localhost:8000/docs
- O crear usuario desde el frontend

---

### ❌ Frontend no muestra empleados de Supabase
**Solución:**
```powershell
# En terminal de Flutter:
# Presionar 'R' (mayúscula) para Hot Restart
# O cerrar y ejecutar de nuevo: flutter run -d windows
```

---

## 📊 DATOS DE PRUEBA

### Usuario de Ejemplo
```
Username: admin
Password: admin123
```

### Empleado de Ejemplo (en Supabase)
```
ID: 1
Nombre: Juan
Apellido: Saldivar
Puesto: Dev
Salario: 1.0
Email: Juan@gmail.com
Teléfono: 1111111111
```

---

## 📡 ENDPOINTS DE LA API

### Autenticación
```
POST /auth/register  - Registrar usuario
POST /auth/login     - Login (retorna JWT)
```

### CRUD Empleados (requiere JWT)
```
GET    /empleados           - Listar todos
GET    /empleados/{id}      - Obtener uno
POST   /empleados           - Crear
PUT    /empleados/{id}      - Actualizar
DELETE /empleados/{id}      - Eliminar
```

### Email (BFF)
```
POST /notify/email          - Enviar notificación
```

---

## 🔒 SEGURIDAD

### Credenciales Sensibles
- ✅ Contraseñas hasheadas con bcrypt
- ✅ JWT con SECRET_KEY (cambiar en producción)
- ✅ API Keys de AWS (ya configuradas)
- ✅ PostgreSQL con SSL (Supabase)

### Cambiar SECRET_KEY (Producción)
Editar `backend/auth.py` línea 11:
```python
SECRET_KEY = "TU_NUEVA_CLAVE_SECRETA_ALEATORIA"
```

---

## 🎯 CHECKLIST DE INSTALACIÓN

- [ ] Python 3.11+ instalado y en PATH
- [ ] Flutter instalado y en PATH
- [ ] Git instalado
- [ ] Proyecto clonado
- [ ] Dependencias backend instaladas
- [ ] Dependencias BFF instaladas
- [ ] Dependencias frontend instaladas
- [ ] Script `start.ps1` ejecutado
- [ ] Backend respondiendo en puerto 8000
- [ ] BFF respondiendo en puerto 8001
- [ ] Frontend compilado y abierto
- [ ] Login exitoso
- [ ] CRUD funcionando
- [ ] Email enviado (verificar logs)

---

## 📞 SOPORTE

### Si algo falla:

1. **Verificar logs:**
   - Backend: Terminal 1 muestra errores
   - BFF: Terminal 2 muestra errores
   - Frontend: Terminal 3 muestra errores

2. **Verificar conexiones:**
   ```powershell
   # Backend
   curl http://localhost:8000/docs
   
   # BFF
   curl http://localhost:8001/health
   
   # Supabase
   cd backend
   python check_db.py
   ```

3. **Reiniciar todo:**
   - Cerrar las 3 terminales
   - Ejecutar `.\start.ps1` de nuevo

---

## 🚀 COMANDOS RÁPIDOS

```powershell
# Iniciar todo
.\start.ps1

# Verificar backend
curl http://localhost:8000/docs

# Verificar BFF
curl http://localhost:8001/health

# Verificar DB
cd backend; python check_db.py

# Ver logs de AWS (requiere AWS CLI configurado)
aws logs tail /aws/lambda/crud-app-email-lambda --follow --region us-east-1

# Hot reload Flutter
# En terminal Flutter: presionar 'r'

# Hot restart Flutter
# En terminal Flutter: presionar 'R'
```

---

## 📝 NOTAS FINALES

1. **Primera compilación de Flutter tarda 2-3 minutos**
2. **El backend crea tablas automáticamente en Supabase**
3. **Los emails funcionan pero pueden caer en spam (Sandbox Mode)**
4. **Para presentación: mostrar logs de CloudWatch como evidencia**
5. **Sistema 100% funcional, limitación solo en entrega de emails**

---

## ✅ SISTEMA LISTO

Una vez todo configurado:
1. Abre http://localhost:8000/docs (API docs)
2. Abre la app Flutter
3. Haz login con `admin/admin123`
4. Prueba el CRUD completo
5. Verifica logs en las terminales

**¡Todo funcionando!** 🎉

---

**Fecha:** 4 de Noviembre de 2025  
**Versión:** 1.0  
**Proyecto:** CRUD Empleados - Sistema Completo con AWS

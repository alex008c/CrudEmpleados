# GUÍA DE INSTALACIÓN EN OTRA PC

## 📋 Requisitos Previos

Antes de copiar el proyecto, asegúrate de tener instalado en la nueva PC:

### 1. Python 3.11
- Descargar de: https://www.python.org/downloads/
- Durante instalación, marcar "Add Python to PATH"

### 2. Flutter
- Descargar de: https://flutter.dev/docs/get-started/install/windows
- Ejecutar `flutter doctor` para verificar instalación
- Instalar Visual Studio Build Tools si es necesario

### 3. Git (opcional)
- Descargar de: https://git-scm.com/downloads

### 4. AWS CLI (para despliegue)
- Descargar de: https://awscli.amazonaws.com/AWSCLIV2.msi
- Configurar con: `aws configure`

### 5. Terraform (para despliegue)
- Descargar de: https://www.terraform.io/downloads
- Copiar `terraform.exe` a la carpeta `terraform/` del proyecto

---

## 📦 Pasos de Instalación

### Paso 1: Copiar el Proyecto
Copia toda la carpeta `CrudEmpleados` a la nueva PC.

### Paso 2: Instalar Dependencias del Backend
```powershell
cd CrudEmpleados\backend
pip install -r requirements.txt
```

### Paso 3: Instalar Dependencias del BFF
```powershell
cd ..\bff
pip install -r requirements.txt
```

### Paso 4: Instalar Dependencias de Flutter
```powershell
cd ..\frontend
flutter pub get
```

---

## 🚀 Ejecutar el Proyecto

### Opción 1: Script Automático (RECOMENDADO)
```powershell
cd CrudEmpleados
.\EJECUTAR_TODO.ps1
```

Este script inicia automáticamente:
- Backend CRUD en puerto 8000
- BFF en puerto 8001
- Frontend Flutter

### Opción 2: Manual

**Terminal 1 - Backend:**
```powershell
cd CrudEmpleados\backend
$env:DATABASE_URL = "postgresql://postgres.fnokvvuodtuewfasqrvp:e0dFVQPJeZLdLAV2@aws-1-us-east-2.pooler.supabase.com:6543/postgres"
python -m uvicorn main:app --reload
```

**Terminal 2 - BFF:**
```powershell
cd CrudEmpleados\bff
$env:PUBLISH_API_URL = "https://bnxlpofo59.execute-api.us-east-1.amazonaws.com/dev/publish"
$env:PUBLISH_API_KEY = "eCR8TZw9xf6zHrf5so2sE3vhKIxKJbqk9BqE4vgJ"
python -m uvicorn main:app --reload --port 8001
```

**Terminal 3 - Frontend:**
```powershell
cd CrudEmpleados\frontend
flutter run -d windows
```

---

## 🔧 Configuración (si es necesario)

### Cambiar Base de Datos
Editar en `EJECUTAR_TODO.ps1` o `run_backend.ps1`:
```powershell
$env:DATABASE_URL = "tu_nueva_conexion_postgresql"
```

### Cambiar Credenciales AWS
Si redespliegas en tu propia cuenta AWS, editar en `EJECUTAR_TODO.ps1`:
```powershell
$env:PUBLISH_API_URL = "tu_api_gateway_url"
$env:PUBLISH_API_KEY = "tu_api_key"
```

---

## 🌐 Redesplegar en AWS (Opcional)

Si quieres redesplegar la infraestructura AWS en tu propia cuenta:

### Paso 1: Configurar AWS CLI
```powershell
aws configure
# Ingresa tu Access Key ID
# Ingresa tu Secret Access Key
# Region: us-east-1
# Output: json
```

### Paso 2: Desplegar con Terraform
```powershell
cd CrudEmpleados\terraform
.\terraform.exe init
.\terraform.exe apply -var="external_db_url=TU_DATABASE_URL"
```

### Paso 3: Obtener URLs
Después del despliegue, Terraform mostrará:
- `email_api_url` - URL del API Gateway para correos
- `email_api_key` - API Key (ejecutar: `terraform output email_api_key`)
- `crud_api_gateway_url` - URL del backend CRUD en AWS

Actualiza estas URLs en `EJECUTAR_TODO.ps1`.

---

## 📝 Archivos Importantes

- `EJECUTAR_TODO.ps1` - Script para iniciar todo el proyecto
- `backend/requirements.txt` - Dependencias Python del backend
- `bff/requirements.txt` - Dependencias Python del BFF
- `frontend/pubspec.yaml` - Dependencias Flutter
- `terraform/*.tf` - Infraestructura AWS

---

## ✅ Verificación

Después de ejecutar, verifica:

1. **Backend CRUD**: http://localhost:8000/docs
2. **BFF**: http://localhost:8001/docs
3. **Frontend**: Ventana de Flutter abierta
4. **AWS**: CloudWatch logs en `/aws/lambda/crud-app-email-lambda`

---

## 🆘 Solución de Problemas

### Error: "python no se reconoce"
- Reinstala Python 3.11 marcando "Add to PATH"
- O usa la ruta completa: `C:\Users\...\Python\python.exe`

### Error: "flutter no se reconoce"
- Agrega Flutter al PATH del sistema
- Reinicia PowerShell

### Error: "ModuleNotFoundError"
- Ejecuta `pip install -r requirements.txt` en backend y bff

### Error en Frontend Flutter
- Ejecuta `flutter clean` y luego `flutter pub get`
- Verifica que backend esté corriendo en puerto 8000

---

## 📧 Contacto

Para más información sobre el proyecto, consulta:
- `README.md` - Documentación general
- `docs/` - Carpeta con documentación detallada

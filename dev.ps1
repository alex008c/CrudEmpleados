# Script equivalente a "npm run dev"
# Ejecuta este script y abrirá 2 ventanas: Backend y Frontend

Write-Host "Iniciando CRUD Empleados..." -ForegroundColor Cyan
Write-Host ""
Write-Host "Se abrirán 2 ventanas:" -ForegroundColor Yellow
Write-Host "  1. Backend (Python/FastAPI)" -ForegroundColor Green
Write-Host "  2. Frontend (Flutter)" -ForegroundColor Blue
Write-Host ""

# Agregar Flutter al PATH
$env:Path = $env:Path + ";C:\dev\flutter\bin"

# Ventana 1: Backend
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd C:\Users\alex008c\Documents\Programacion\CrudEmpleados\backend; python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000"

# Ventana 2: Frontend (esperar 3 segundos)
Start-Sleep -Seconds 3
Start-Process powershell -ArgumentList "-NoExit", "-Command", "`$env:Path = `$env:Path + ';C:\dev\flutter\bin'; cd C:\Users\alex008c\Documents\Programacion\CrudEmpleados\frontend; flutter run -d windows"

Write-Host ""
Write-Host "Listo! Revisa las 2 ventanas que se abrieron" -ForegroundColor Green
Write-Host "Presiona cualquier tecla para cerrar este mensaje..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

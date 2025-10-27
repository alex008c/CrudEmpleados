# Script equivalente a "npm run dev"
# Ejecuta este script y abrirá 2 ventanas: Backend y Frontend

Write-Host "Iniciando CRUD Empleados..." -ForegroundColor Cyan
Write-Host ""
Write-Host "Se abrirán 2 ventanas:" -ForegroundColor Yellow
Write-Host "  1. Backend (Python/FastAPI)" -ForegroundColor Green
Write-Host "  2. Frontend (Flutter)" -ForegroundColor Blue
Write-Host ""

# Agregar Flutter al PATH si existe la carpeta por defecto
if (Test-Path 'C:\src\flutter\bin') {
	$env:Path = $env:Path + ";C:\src\flutter\bin"
}

# Arrancar backend en nueva ventana PowerShell usando WorkingDirectory (maneja espacios correctamente)
Start-Process -FilePath powershell -ArgumentList @('-NoExit','-Command','python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000') -WorkingDirectory (Join-Path $PSScriptRoot 'backend')

# Esperar antes de iniciar frontend
Start-Sleep -Seconds 3

# Arrancar frontend en nueva ventana PowerShell usando WorkingDirectory
Start-Process -FilePath powershell -ArgumentList @('-NoExit','-Command','flutter run -d windows') -WorkingDirectory (Join-Path $PSScriptRoot 'frontend')

Write-Host ""
Write-Host "Listo! Revisa las 2 ventanas que se abrieron" -ForegroundColor Green
Write-Host "Presiona cualquier tecla para cerrar este mensaje..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

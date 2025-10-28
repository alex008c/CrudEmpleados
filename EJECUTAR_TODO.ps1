# ========================================
# SCRIPT PARA EJECUTAR TODO EL PROYECTO
# ========================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INICIANDO PROYECTO CRUD EMPLEADOS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configurar base de datos Supabase
$env:DATABASE_URL = "postgresql://postgres.fnokvvuodtuewfasqrvp:e0dFVQPJeZLdLAV2@aws-1-us-east-2.pooler.supabase.com:6543/postgres"

# Configurar API Gateway AWS para BFF
$env:PUBLISH_API_URL = "https://bnxlpofo59.execute-api.us-east-1.amazonaws.com/dev/publish"
$env:PUBLISH_API_KEY = "eCR8TZw9xf6zHrf5so2sE3vhKIxKJbqk9BqE4vgJ"

Write-Host "[1/3] Iniciando Backend CRUD (puerto 8000)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\backend'; `$env:DATABASE_URL='$env:DATABASE_URL'; python -m uvicorn main:app --reload"

Start-Sleep -Seconds 3

Write-Host "[2/3] Iniciando BFF (puerto 8001)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\bff'; `$env:PUBLISH_API_URL='$env:PUBLISH_API_URL'; `$env:PUBLISH_API_KEY='$env:PUBLISH_API_KEY'; python -m uvicorn main:app --reload --port 8001"

Start-Sleep -Seconds 3

Write-Host "[3/3] Iniciando Frontend Flutter..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\frontend'; flutter run -d windows"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SERVICIOS INICIADOS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backend CRUD:  http://localhost:8000" -ForegroundColor Yellow
Write-Host "BFF:           http://localhost:8001" -ForegroundColor Yellow
Write-Host "Frontend:      Flutter Windows App" -ForegroundColor Yellow
Write-Host ""
Write-Host "AWS Resources:" -ForegroundColor Magenta
Write-Host "  - API Gateway Email: https://bnxlpofo59.execute-api.us-east-1.amazonaws.com/dev/publish" -ForegroundColor Gray
Write-Host "  - API Gateway CRUD:  https://sv2ern4elf.execute-api.us-east-1.amazonaws.com/" -ForegroundColor Gray
Write-Host "  - SNS Topic:         arn:aws:sns:us-east-1:717119779211:crud-app-email-topic" -ForegroundColor Gray
Write-Host "  - SQS Queue:         https://sqs.us-east-1.amazonaws.com/717119779211/crud-app-email-queue" -ForegroundColor Gray
Write-Host ""
Write-Host "Presiona cualquier tecla para cerrar..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# ====================================================================
#  CRUD EMPLEADOS - SCRIPT DE INICIO COMPLETO
#  Inicia Backend + BFF + Frontend automaticamente
# ====================================================================

$Host.UI.RawUI.WindowTitle = "CRUD Empleados - Inicio"

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host " CRUD EMPLEADOS - SISTEMA COMPLETO" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Configuracion
$SUPABASE_URL = "postgresql://postgres.fnokvvuodtuewfasqrvp:e0dFVQPJeZLdLAV2@aws-1-us-east-2.pooler.supabase.com:6543/postgres"
$AWS_API_URL = "https://bnxlpofo59.execute-api.us-east-1.amazonaws.com/dev/publish"
$AWS_API_KEY = "eCR8TZw9xf6zHrf5so2sE3vhKIxKJbqk9BqE4vgJ"

$BACKEND_PATH = Join-Path $PSScriptRoot "backend"
$BFF_PATH = Join-Path $PSScriptRoot "bff"
$FRONTEND_PATH = Join-Path $PSScriptRoot "frontend"

Write-Host "Iniciando servicios..." -ForegroundColor Yellow
Write-Host ""

# 1. Backend FastAPI
Write-Host "1. Backend FastAPI (puerto 8000)..." -ForegroundColor Green
$backendCmd = "cd '$BACKEND_PATH'; `$env:DATABASE_URL='$SUPABASE_URL'; python -m uvicorn main:app --reload"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $backendCmd
Start-Sleep -Seconds 3

# 2. BFF Email Service
Write-Host "2. BFF Email Service (puerto 8001)..." -ForegroundColor Green
$bffCmd = "cd '$BFF_PATH'; `$env:PUBLISH_API_URL='$AWS_API_URL'; `$env:PUBLISH_API_KEY='$AWS_API_KEY'; python -m uvicorn main:app --reload --port 8001"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $bffCmd
Start-Sleep -Seconds 3

# 3. Frontend Flutter
Write-Host "3. Frontend Flutter (Windows)..." -ForegroundColor Green
$frontendCmd = "cd '$FRONTEND_PATH'; flutter run -d windows"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $frontendCmd

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host " SISTEMA INICIADO CORRECTAMENTE" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "SERVICIOS ACTIVOS:" -ForegroundColor Cyan
Write-Host "  - Backend FastAPI: http://localhost:8000" -ForegroundColor White
Write-Host "  - BFF Email: http://localhost:8001" -ForegroundColor White
Write-Host "  - Frontend: Compilando..." -ForegroundColor White
Write-Host ""
Write-Host "Para detener: Cierra las 3 ventanas de PowerShell" -ForegroundColor Yellow
Write-Host ""
Write-Host "Presiona cualquier tecla para cerrar..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

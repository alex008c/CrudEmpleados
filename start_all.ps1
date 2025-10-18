# Script para iniciar Backend y Frontend simultáneamente
# Ejecuta: .\start_all.ps1

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "   🚀 CRUD EMPLEADOS - INICIO AUTOMÁTICO   " -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Verificar requisitos
Write-Host "🔍 Verificando requisitos..." -ForegroundColor Yellow

# Verificar Python
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✅ Python encontrado: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Python no encontrado. Instálalo desde: https://python.org" -ForegroundColor Red
    exit 1
}

# Verificar Flutter
try {
    $flutterVersion = flutter --version | Select-Object -First 1
    Write-Host "✅ Flutter encontrado: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter no encontrado. Instálalo desde: https://flutter.dev" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "   📦 INSTALANDO DEPENDENCIAS              " -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Instalar dependencias del backend
Write-Host "1️⃣ Backend (Python)..." -ForegroundColor Cyan
Set-Location -Path "backend"
try {
    python -c "import fastapi" 2>$null
    if ($LASTEXITCODE -ne 0) {
        pip install -r requirements.txt -q
    }
    Write-Host "   ✅ Backend listo" -ForegroundColor Green
} catch {
    pip install -r requirements.txt
    Write-Host "   ✅ Backend listo" -ForegroundColor Green
}
Set-Location -Path ".."

# Instalar dependencias del frontend
Write-Host "2️⃣ Frontend (Flutter)..." -ForegroundColor Cyan
Set-Location -Path "frontend"
flutter pub get | Out-Null
Write-Host "   ✅ Frontend listo" -ForegroundColor Green
Set-Location -Path ".."

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "   🎯 INICIANDO SERVICIOS                  " -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Host "Este script abrirá 2 terminales nuevas:" -ForegroundColor White
Write-Host "  📡 Terminal 1: Backend API (http://localhost:8000)" -ForegroundColor White
Write-Host "  🖥️  Terminal 2: Frontend Flutter" -ForegroundColor White
Write-Host ""

# Opción de dispositivo
Write-Host "Selecciona el dispositivo para Flutter:" -ForegroundColor Yellow
Write-Host "  1) Windows (Aplicación de escritorio) ⭐ RECOMENDADO" -ForegroundColor White
Write-Host "  2) Chrome (Navegador web)" -ForegroundColor White
$choice = Read-Host "Tu elección (1-2, default: 1)"

if ($choice -eq "") { $choice = "1" }

$device = if ($choice -eq "2") { "chrome" } else { "windows" }

Write-Host ""
Write-Host "⏳ Iniciando en 3 segundos..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Iniciar Backend en nueva terminal
Write-Host "📡 Iniciando Backend..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\backend'; Write-Host '🚀 BACKEND - FastAPI' -ForegroundColor Green; Write-Host 'API: http://localhost:8000' -ForegroundColor Cyan; Write-Host 'Docs: http://localhost:8000/docs' -ForegroundColor Cyan; Write-Host ''; python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000"

# Esperar a que el backend inicie
Write-Host "⏳ Esperando que el backend inicie..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Iniciar Frontend en nueva terminal
Write-Host "🖥️  Iniciando Frontend ($device)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\frontend'; Write-Host '📱 FRONTEND - Flutter' -ForegroundColor Green; Write-Host 'Dispositivo: $device' -ForegroundColor Cyan; Write-Host ''; flutter run -d $device"

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "   ✅ SERVICIOS INICIADOS CORRECTAMENTE   " -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host ""
Write-Host "📍 URLs Importantes:" -ForegroundColor Yellow
Write-Host "   🔧 API Backend:  http://localhost:8000" -ForegroundColor White
Write-Host "   📚 Docs API:     http://localhost:8000/docs" -ForegroundColor White
Write-Host "   🖥️  Frontend:     Se abrirá automáticamente" -ForegroundColor White
Write-Host ""
Write-Host "🛑 Para detener: Cierra las terminales o presiona Ctrl+C en cada una" -ForegroundColor Red
Write-Host ""
Write-Host "💡 Tip: Registra un usuario en la app antes de hacer login" -ForegroundColor Cyan
Write-Host ""
Write-Host "Presiona cualquier tecla para cerrar esta ventana..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

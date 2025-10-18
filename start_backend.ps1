# Script para iniciar el backend de forma rápida
# Ejecuta: .\start_backend.ps1

Write-Host "🚀 Iniciando Backend FastAPI..." -ForegroundColor Green

# Navegar a la carpeta del backend
Set-Location -Path "backend"

# Activar entorno virtual si existe
if (Test-Path "venv\Scripts\Activate.ps1") {
    Write-Host "Activando entorno virtual..." -ForegroundColor Yellow
    .\venv\Scripts\Activate.ps1
}

# Verificar si uvicorn está instalado
if (-not (Get-Command uvicorn -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Uvicorn no está instalado. Instalando dependencias..." -ForegroundColor Red
    pip install -r requirements.txt
}

# Iniciar servidor
Write-Host ""
Write-Host "✅ Servidor iniciando en: http://localhost:8000" -ForegroundColor Green
Write-Host "📚 Documentación API: http://localhost:8000/docs" -ForegroundColor Cyan
Write-Host ""
Write-Host "Presiona Ctrl+C para detener el servidor" -ForegroundColor Yellow
Write-Host ""

uvicorn main:app --reload --host 127.0.0.1 --port 8000

# Script para iniciar el backend de forma rápida
# Ejecuta: .\start_backend.ps1

Write-Host "🚀 Iniciando Backend FastAPI..." -ForegroundColor Green
Write-Host ""

# Navegar a la carpeta del backend
Set-Location -Path "backend"

# Verificar si las dependencias están instaladas
try {
    python -c "import fastapi" 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "📦 Instalando dependencias de Python..." -ForegroundColor Yellow
        pip install -r requirements.txt
        Write-Host ""
    }
} catch {
    Write-Host "📦 Instalando dependencias de Python..." -ForegroundColor Yellow
    pip install -r requirements.txt
    Write-Host ""
}

# Iniciar servidor
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✅ Servidor corriendo en: http://localhost:8000" -ForegroundColor Green
Write-Host "📚 Documentación API:     http://localhost:8000/docs" -ForegroundColor Cyan
Write-Host "💾 Base de datos:         SQLite (empleados.db)" -ForegroundColor Magenta
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚡ Modo hot-reload activado (los cambios se aplican automáticamente)" -ForegroundColor Yellow
Write-Host "🛑 Presiona Ctrl+C para detener el servidor" -ForegroundColor Red
Write-Host ""

python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000

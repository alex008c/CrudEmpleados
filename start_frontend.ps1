# Script para configurar e iniciar el frontend Flutter
# Ejecuta: .\start_frontend.ps1

Write-Host "📱 Iniciando Frontend Flutter..." -ForegroundColor Green

# Navegar a la carpeta del frontend
Set-Location -Path "frontend"

# Verificar si Flutter está instalado
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Flutter no está instalado." -ForegroundColor Red
    Write-Host "Descárgalo desde: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}

# Instalar dependencias
Write-Host "📦 Instalando dependencias..." -ForegroundColor Yellow
flutter pub get

# Verificar dispositivos disponibles
Write-Host ""
Write-Host "🔍 Dispositivos disponibles:" -ForegroundColor Cyan
flutter devices

Write-Host ""
Write-Host "✅ Iniciando aplicación..." -ForegroundColor Green
Write-Host "Presiona 'r' para hot reload, 'R' para hot restart" -ForegroundColor Yellow
Write-Host ""

# Ejecutar la app
flutter run

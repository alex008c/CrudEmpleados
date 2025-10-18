# Script para configurar e iniciar el frontend Flutter
# Ejecuta: .\start_frontend.ps1

Write-Host "📱 Iniciando Frontend Flutter..." -ForegroundColor Green
Write-Host ""

# Navegar a la carpeta del frontend
Set-Location -Path "frontend"

# Verificar si Flutter está instalado
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Flutter no está instalado." -ForegroundColor Red
    Write-Host "Descárgalo desde: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}

# Instalar dependencias si es necesario
Write-Host "📦 Verificando dependencias..." -ForegroundColor Yellow
flutter pub get
Write-Host ""

# Verificar dispositivos disponibles
Write-Host "🔍 Dispositivos disponibles:" -ForegroundColor Cyan
flutter devices
Write-Host ""

# Preguntar qué dispositivo usar
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Selecciona el dispositivo:" -ForegroundColor Yellow
Write-Host "  1) Windows (Aplicación de escritorio) ⭐ RECOMENDADO" -ForegroundColor White
Write-Host "  2) Chrome (Navegador web)" -ForegroundColor White
Write-Host "  3) Dejar que Flutter elija automáticamente" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
$choice = Read-Host "Tu elección (1-3)"

Write-Host ""
Write-Host "✅ Iniciando aplicación..." -ForegroundColor Green
Write-Host "⚡ Atajos útiles:" -ForegroundColor Yellow
Write-Host "   r  - Hot reload (recarga rápida)" -ForegroundColor White
Write-Host "   R  - Hot restart (reinicio completo)" -ForegroundColor White
Write-Host "   q  - Salir" -ForegroundColor White
Write-Host ""

# Ejecutar según la elección
switch ($choice) {
    "1" { 
        Write-Host "🪟 Iniciando en Windows desktop..." -ForegroundColor Cyan
        flutter run -d windows 
    }
    "2" { 
        Write-Host "🌐 Iniciando en Chrome..." -ForegroundColor Cyan
        flutter run -d chrome 
    }
    default { 
        Write-Host "🎯 Iniciando en dispositivo por defecto..." -ForegroundColor Cyan
        flutter run 
    }
}

# Solo Frontend (equivalente a "npm run client")
$env:Path = $env:Path + ";C:\dev\flutter\bin"
cd frontend
Write-Host "💻 Iniciando Frontend Flutter..." -ForegroundColor Blue
flutter run -d windows

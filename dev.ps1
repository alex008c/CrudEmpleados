$env:DATABASE_URL = "postgresql://postgres.fnokvvuodtuewfasqrvp:e0dFVQPJeZLdLAV2@aws-1-us-east-2.pooler.supabase.com:6543/postgres"

Write-Host "Iniciando CRUD Empleados..." -ForegroundColor Cyan
Write-Host "Backend: Python/FastAPI con Supabase PostgreSQL" -ForegroundColor Green
Write-Host "Frontend: Flutter Windows" -ForegroundColor Blue
Write-Host ""

if (Test-Path 'C:\src\flutter\bin') {
	$env:Path = $env:Path + ";C:\src\flutter\bin"
}

Start-Process -FilePath powershell -ArgumentList @('-NoExit','-Command',"`$env:DATABASE_URL='postgresql://postgres.fnokvvuodtuewfasqrvp:e0dFVQPJeZLdLAV2@aws-1-us-east-2.pooler.supabase.com:6543/postgres'; python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000") -WorkingDirectory (Join-Path $PSScriptRoot 'backend')

Start-Sleep -Seconds 3

Start-Process -FilePath powershell -ArgumentList @('-NoExit','-Command','flutter run -d windows') -WorkingDirectory (Join-Path $PSScriptRoot 'frontend')

Write-Host "Listo! Revisa las 2 ventanas" -ForegroundColor Green

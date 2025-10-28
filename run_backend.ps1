$env:DATABASE_URL = "postgresql://postgres.fnokvvuodtuewfasqrvp:e0dFVQPJeZLdLAV2@aws-1-us-east-2.pooler.supabase.com:6543/postgres"

Write-Host "Iniciando Backend FastAPI con Supabase PostgreSQL" -ForegroundColor Green
Write-Host "Servidor: http://localhost:8000" -ForegroundColor Cyan
Write-Host "Documentacion: http://localhost:8000/docs" -ForegroundColor Cyan
Write-Host ""

Set-Location -Path "$PSScriptRoot\backend"

python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000

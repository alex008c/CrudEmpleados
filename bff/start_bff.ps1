$env:PUBLISH_API_URL = "PENDIENTE_DESPUES_DE_TERRAFORM_APPLY"
$env:PUBLISH_API_KEY = "PENDIENTE_DESPUES_DE_TERRAFORM_APPLY"

Write-Host "Iniciando BFF..." -ForegroundColor Cyan
Write-Host "URL: http://localhost:8001" -ForegroundColor Green
Write-Host ""

cd bff
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8001

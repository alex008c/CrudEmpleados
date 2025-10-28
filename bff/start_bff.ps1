$env:PUBLISH_API_URL = "https://bnxlpofo59.execute-api.us-east-1.amazonaws.com/dev/publish"
$env:PUBLISH_API_KEY = "eCR8TZw9xf6zHrf5so2sE3vhKIxKJbqk9BqE4vgJ"

Write-Host "Iniciando BFF..." -ForegroundColor Cyan
Write-Host "URL: http://localhost:8001" -ForegroundColor Green
Write-Host ""

cd bff
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8001

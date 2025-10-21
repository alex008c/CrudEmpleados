# Solo Backend (equivalente a "npm run server")
cd backend
Write-Host "🔧 Iniciando Backend en http://127.0.0.1:8000" -ForegroundColor Green
python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
import requests
import os

app = FastAPI(title="BFF - Email Service", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class EmailRequest(BaseModel):
    to: EmailStr
    subject: str
    body: str

@app.get("/")
def read_root():
    return {"service": "BFF Email Service", "status": "running"}

@app.post("/notify/email")
def notify_email(email_request: EmailRequest):
    api_url = os.environ.get("PUBLISH_API_URL")
    api_key = os.environ.get("PUBLISH_API_KEY")
    
    if not api_url or not api_key:
        raise HTTPException(
            status_code=500,
            detail="Configuración del servicio incompleta. Verificar PUBLISH_API_URL y PUBLISH_API_KEY"
        )
    
    headers = {
        "Content-Type": "application/json",
        "x-api-key": api_key
    }
    
    payload = {
        "to": email_request.to,
        "subject": email_request.subject,
        "body": email_request.body
    }
    
    try:
        response = requests.post(api_url, json=payload, headers=headers, timeout=10)
        
        if response.status_code != 200:
            raise HTTPException(
                status_code=response.status_code,
                detail=f"Error al publicar mensaje: {response.text}"
            )
        
        return {
            "success": True,
            "message": "Correo enviado correctamente",
            "data": response.json()
        }
        
    except requests.exceptions.RequestException as e:
        raise HTTPException(
            status_code=502,
            detail=f"Error al conectar con el servicio de mensajería: {str(e)}"
        )

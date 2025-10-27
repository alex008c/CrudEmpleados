from fastapi import FastAPI, Depends, HTTPException, status, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
from typing import List
from datetime import timedelta
import os
import shutil
from pathlib import Path

import models
import auth
from database import engine, get_db
from models import (
    EmpleadoDB, UsuarioDB, Empleado, EmpleadoCreate,
    EmpleadoUpdate, LoginRequest, Token, UsuarioCreate
)

from mangum import Mangum

# Crear las tablas en la base de datos
models.Base.metadata.create_all(bind=engine)

# Crear directorio para archivos subidos
UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)

app = FastAPI(title="API CRUD Empleados", version="1.0.0")

# Montar directorio estático para servir archivos subidos
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# Configurar CORS para permitir peticiones desde Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especifica los orígenes permitidos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==================== ENDPOINTS DE AUTENTICACIÓN ====================

@app.post("/auth/login", response_model=Token)
async def login(login_data: LoginRequest, db: Session = Depends(get_db)):
    """
    Endpoint de login que valida credenciales y retorna un JWT.
    Usa async/await para no bloquear el servidor.
    """
    # Buscar usuario en la base de datos
    user = db.query(UsuarioDB).filter(UsuarioDB.username == login_data.username).first()
    
    # Verificar que el usuario existe y la contraseña es correcta
    if not user or not auth.verify_password(login_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciales incorrectas"
        )
    
    # Crear token JWT
    access_token_expires = timedelta(minutes=auth.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    
    return {"access_token": access_token, "token_type": "bearer"}

@app.post("/auth/register")
async def register(user_data: UsuarioCreate, db: Session = Depends(get_db)):
    """
    Endpoint para registrar nuevos usuarios (útil para pruebas).
    Requiere username, password y email.
    """
    # Verificar si el usuario ya existe
    existing_user = db.query(UsuarioDB).filter(UsuarioDB.username == user_data.username).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Usuario ya existe")
    
    # Verificar si el email ya está registrado
    existing_email = db.query(UsuarioDB).filter(UsuarioDB.email == user_data.email).first()
    if existing_email:
        raise HTTPException(status_code=400, detail="Email ya registrado")
    
    # Crear nuevo usuario con contraseña hasheada
    hashed_password = auth.get_password_hash(user_data.password)
    new_user = UsuarioDB(
        username=user_data.username,
        password_hash=hashed_password,
        email=user_data.email
    )
    db.add(new_user)
    db.commit()
    
    return {"message": "Usuario creado exitosamente"}

# ==================== ENDPOINTS CRUD DE EMPLEADOS ====================

@app.get("/empleados", response_model=List[Empleado])
async def get_empleados(
    skip: int = 0, 
    limit: int = 100,
    current_user: str = Depends(auth.verify_token),
    db: Session = Depends(get_db)
):
    """
    Obtiene la lista de todos los empleados.
    Requiere autenticación (token JWT).
    """
    empleados = db.query(EmpleadoDB).offset(skip).limit(limit).all()
    return empleados

@app.get("/empleados/{empleado_id}", response_model=Empleado)
async def get_empleado(
    empleado_id: int,
    current_user: str = Depends(auth.verify_token),
    db: Session = Depends(get_db)
):
    """
    Obtiene un empleado específico por ID.
    """
    empleado = db.query(EmpleadoDB).filter(EmpleadoDB.id == empleado_id).first()
    if not empleado:
        raise HTTPException(status_code=404, detail="Empleado no encontrado")
    return empleado

@app.post("/empleados", response_model=Empleado, status_code=status.HTTP_201_CREATED)
async def create_empleado(
    empleado: EmpleadoCreate,
    current_user: str = Depends(auth.verify_token),
    db: Session = Depends(get_db)
):
    """
    Crea un nuevo empleado.
    """
    # Verificar si el email ya existe
    existing = db.query(EmpleadoDB).filter(EmpleadoDB.email == empleado.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email ya registrado")
    
    db_empleado = EmpleadoDB(**empleado.model_dump())
    db.add(db_empleado)
    db.commit()
    db.refresh(db_empleado)
    return db_empleado

@app.put("/empleados/{empleado_id}", response_model=Empleado)
async def update_empleado(
    empleado_id: int,
    empleado_update: EmpleadoUpdate,
    current_user: str = Depends(auth.verify_token),
    db: Session = Depends(get_db)
):
    """
    Actualiza los datos de un empleado existente.
    """
    db_empleado = db.query(EmpleadoDB).filter(EmpleadoDB.id == empleado_id).first()
    if not db_empleado:
        raise HTTPException(status_code=404, detail="Empleado no encontrado")
    
    # Actualizar solo los campos que se enviaron
    update_data = empleado_update.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_empleado, field, value)
    
    db.commit()
    db.refresh(db_empleado)
    return db_empleado

@app.delete("/empleados/{empleado_id}")
async def delete_empleado(
    empleado_id: int,
    current_user: str = Depends(auth.verify_token),
    db: Session = Depends(get_db)
):
    """
    Elimina un empleado de la base de datos.
    """
    db_empleado = db.query(EmpleadoDB).filter(EmpleadoDB.id == empleado_id).first()
    if not db_empleado:
        raise HTTPException(status_code=404, detail="Empleado no encontrado")
    
    db.delete(db_empleado)
    db.commit()
    return {"message": "Empleado eliminado exitosamente"}

# ==================== ENDPOINT DE SUBIDA DE IMÁGENES ====================

@app.post("/upload-image")
async def upload_image(
    file: UploadFile = File(...),
    current_user: str = Depends(auth.verify_token)
):
    """
    Sube una imagen de empleado y devuelve la URL para acceder a ella.
    Acepta: jpg, jpeg, png, gif
    Tamaño máximo: 5MB
    """
    # Log para debugging
    print(f"📸 Recibiendo archivo: {file.filename}")
    print(f"   Content-Type: {file.content_type}")
    
    # Validar tipo de archivo (más permisivo)
    allowed_types = ["image/jpeg", "image/jpg", "image/png", "image/gif"]
    allowed_extensions = [".jpg", ".jpeg", ".png", ".gif"]
    
    file_extension = file.filename.split(".")[-1].lower() if file.filename else ""
    
    # Validar por content-type O por extensión
    if file.content_type not in allowed_types and f".{file_extension}" not in allowed_extensions:
        print(f"Tipo rechazado: {file.content_type}, extensión: {file_extension}")
        raise HTTPException(
            status_code=400,
            detail=f"Tipo de archivo no permitido. Content-Type: {file.content_type}. Use: jpg, jpeg, png, gif"
        )
    
    # Validar tamaño (5MB máximo)
    contents = await file.read()
    file_size = len(contents)
    print(f"   Tamaño: {file_size / 1024:.2f} KB")
    
    if file_size > 5 * 1024 * 1024:  # 5MB en bytes
        raise HTTPException(
            status_code=400,
            detail="El archivo es muy grande. Tamaño máximo: 5MB"
        )
    
    # Generar nombre único con timestamp y extensión original
    import uuid
    from datetime import datetime
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    unique_filename = f"{timestamp}_{uuid.uuid4().hex[:8]}.{file_extension}"
    
    # Guardar archivo
    file_path = UPLOAD_DIR / unique_filename
    with open(file_path, "wb") as buffer:
        buffer.write(contents)
    
    print(f"✅ Archivo guardado: {unique_filename}")
    
    # Devolver URL completa
    file_url = f"http://127.0.0.1:8000/uploads/{unique_filename}"
    return {
        "url": file_url,
        "filename": unique_filename,
        "size": file_size
    }

# ==================== ENDPOINT DE PRUEBA ====================

@app.get("/")
async def root():
    """Endpoint de prueba para verificar que el servidor está funcionando"""
    return {
        "message": "API CRUD Empleados está funcionando correctamente",
        "version": "1.0.0",
        "endpoints": {
            "auth": ["/auth/login", "/auth/register"],
            "empleados": ["/empleados", "/empleados/{id}"]
        }
    }

handler = Mangum(app)
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
from datetime import timedelta

import models
import auth
from database import engine, get_db
from models import (
    EmpleadoDB, UsuarioDB, Empleado, EmpleadoCreate, 
    EmpleadoUpdate, LoginRequest, Token, UsuarioCreate
)

# Crear las tablas en la base de datos
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="API CRUD Empleados", version="1.0.0")

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

from sqlalchemy import Column, Integer, String, Float, DateTime
from datetime import datetime
from database import Base
from pydantic import BaseModel
from typing import Optional

# Modelo de SQLAlchemy para la base de datos
class EmpleadoDB(Base):
    __tablename__ = "empleados"
    
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, index=True)
    apellido = Column(String)
    puesto = Column(String)
    salario = Column(Float)
    email = Column(String, unique=True, index=True)
    telefono = Column(String)
    foto_url = Column(String, nullable=True)
    fecha_ingreso = Column(DateTime, default=datetime.utcnow)

# Modelo Usuario para autenticación
class UsuarioDB(Base):
    __tablename__ = "usuarios"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    password_hash = Column(String)
    email = Column(String, unique=True)

# Schemas Pydantic para validación de datos
class EmpleadoBase(BaseModel):
    nombre: str
    apellido: str
    puesto: str
    salario: float
    email: str
    telefono: str
    foto_url: Optional[str] = None

class EmpleadoCreate(EmpleadoBase):
    pass

class EmpleadoUpdate(BaseModel):
    nombre: Optional[str] = None
    apellido: Optional[str] = None
    puesto: Optional[str] = None
    salario: Optional[float] = None
    email: Optional[str] = None
    telefono: Optional[str] = None
    foto_url: Optional[str] = None

class Empleado(EmpleadoBase):
    id: int
    fecha_ingreso: datetime
    
    class Config:
        from_attributes = True

class LoginRequest(BaseModel):
    username: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str

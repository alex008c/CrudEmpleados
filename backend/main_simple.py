"""
Handler Lambda simplificado para CRUD de empleados
Sin FastAPI - Solo SQLAlchemy y lógica básica
"""

import json
import os
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime

# Configuración de base de datos
DATABASE_URL = os.environ.get('DATABASE_URL', '')
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Modelo de Empleado
class EmpleadoDB(Base):
    __tablename__ = "empleados"
    
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, index=True)
    email = Column(String, unique=True, index=True)
    posicion = Column(String)
    salario = Column(Float)
    fecha_contratacion = Column(DateTime, default=datetime.utcnow)

# Crear tablas
Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        return db
    finally:
        pass  # Se cierra después de usar

def handler(event, context):
    """
    Handler principal para el Lambda CRUD
    Soporta operaciones GET, POST, PUT, DELETE
    """
    print(f"[CRUD] Event received: {json.dumps(event)}")
    
    try:
        http_method = event.get('httpMethod', event.get('requestContext', {}).get('http', {}).get('method', 'GET'))
        path = event.get('path', '/')
        path_parameters = event.get('pathParameters', {})
        body = event.get('body', '')
        
        # Parsear body si existe
        data = {}
        if body:
            try:
                data = json.loads(body) if isinstance(body, str) else body
            except:
                pass
        
        # Obtener sesión de base de datos
        db = get_db()
        
        # Routing basado en path y método
        if path == '/empleados' or path == '/empleados/':
            if http_method == 'GET':
                # Listar todos los empleados
                empleados = db.query(EmpleadoDB).all()
                result = []
                for emp in empleados:
                    result.append({
                        'id': emp.id,
                        'nombre': emp.nombre,
                        'email': emp.email,
                        'posicion': emp.posicion,
                        'salario': emp.salario,
                        'fecha_contratacion': emp.fecha_contratacion.isoformat() if emp.fecha_contratacion else None
                    })
                
                db.close()
                return {
                    'statusCode': 200,
                    'headers': {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    'body': json.dumps(result)
                }
            
            elif http_method == 'POST':
                # Crear nuevo empleado
                nuevo_empleado = EmpleadoDB(
                    nombre=data.get('nombre'),
                    email=data.get('email'),
                    posicion=data.get('posicion'),
                    salario=data.get('salario'),
                    fecha_contratacion=datetime.utcnow()
                )
                db.add(nuevo_empleado)
                db.commit()
                db.refresh(nuevo_empleado)
                
                result = {
                    'id': nuevo_empleado.id,
                    'nombre': nuevo_empleado.nombre,
                    'email': nuevo_empleado.email,
                    'posicion': nuevo_empleado.posicion,
                    'salario': nuevo_empleado.salario,
                    'fecha_contratacion': nuevo_empleado.fecha_contratacion.isoformat()
                }
                
                db.close()
                return {
                    'statusCode': 201,
                    'headers': {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    'body': json.dumps(result)
                }
        
        # Empleado específico por ID
        elif '/empleados/' in path and path_parameters and 'id' in path_parameters:
            empleado_id = int(path_parameters['id'])
            empleado = db.query(EmpleadoDB).filter(EmpleadoDB.id == empleado_id).first()
            
            if not empleado:
                db.close()
                return {
                    'statusCode': 404,
                    'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
                    'body': json.dumps({'error': 'Empleado no encontrado'})
                }
            
            if http_method == 'GET':
                result = {
                    'id': empleado.id,
                    'nombre': empleado.nombre,
                    'email': empleado.email,
                    'posicion': empleado.posicion,
                    'salario': empleado.salario,
                    'fecha_contratacion': empleado.fecha_contratacion.isoformat() if empleado.fecha_contratacion else None
                }
                db.close()
                return {
                    'statusCode': 200,
                    'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
                    'body': json.dumps(result)
                }
            
            elif http_method == 'PUT':
                if 'nombre' in data:
                    empleado.nombre = data['nombre']
                if 'email' in data:
                    empleado.email = data['email']
                if 'posicion' in data:
                    empleado.posicion = data['posicion']
                if 'salario' in data:
                    empleado.salario = data['salario']
                
                db.commit()
                db.refresh(empleado)
                
                result = {
                    'id': empleado.id,
                    'nombre': empleado.nombre,
                    'email': empleado.email,
                    'posicion': empleado.posicion,
                    'salario': empleado.salario,
                    'fecha_contratacion': empleado.fecha_contratacion.isoformat()
                }
                db.close()
                return {
                    'statusCode': 200,
                    'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
                    'body': json.dumps(result)
                }
            
            elif http_method == 'DELETE':
                db.delete(empleado)
                db.commit()
                db.close()
                return {
                    'statusCode': 204,
                    'headers': {'Access-Control-Allow-Origin': '*'},
                    'body': ''
                }
        
        # Ruta no encontrada
        db.close()
        return {
            'statusCode': 404,
            'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'error': 'Ruta no encontrada', 'path': path, 'method': http_method})
        }
    
    except Exception as e:
        print(f"[CRUD] Error: {str(e)}")
        import traceback
        traceback.print_exc()
        
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'error': 'Internal Server Error', 'message': str(e)})
        }

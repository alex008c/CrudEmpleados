"""
Handler Lambda simplificado para CRUD de empleados
Sin FastAPI - Solo SQLAlchemy y lógica básica
Integrado con SNS para notificaciones por email
"""

import json
import os
import boto3
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime

# Configuración de base de datos
DATABASE_URL = os.environ.get('DATABASE_URL', '')
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Cliente SNS para notificaciones
sns_client = boto3.client('sns', region_name='us-east-1')
SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN', '')

# Modelo de Empleado (coincide con esquema real de la BD)
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

# Crear tablas
Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        return db
    finally:
        pass  # Se cierra después de usar

def publish_to_sns(accion, empleado_data):
    """
    Publica evento en SNS para enviar notificación por email
    """
    try:
        message = {
            'accion': accion,
            'empleado': empleado_data,
            'timestamp': datetime.utcnow().isoformat()
        }
        
        response = sns_client.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=json.dumps(message),
            Subject=f'Empleado {accion}'
        )
        
        print(f"[SNS] Publicado: {accion} - {empleado_data.get('nombre')} - MessageId: {response.get('MessageId')}")
        return True
    except Exception as e:
        print(f"[SNS] Error al publicar: {str(e)}")
        return False

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
        
        print(f"[CRUD] HTTP Method: {http_method}")
        print(f"[CRUD] Path: {path}")
        print(f"[CRUD] Body raw: {body}")
        print(f"[CRUD] Body type: {type(body)}")
        
        # Parsear body si existe
        data = {}
        if body:
            try:
                data = json.loads(body) if isinstance(body, str) else body
                print(f"[CRUD] Data parsed: {data}")
            except Exception as e:
                print(f"[CRUD] Error parsing body: {str(e)}")
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
                        'apellido': emp.apellido if hasattr(emp, 'apellido') else '',
                        'puesto': emp.puesto,
                        'salario': emp.salario,
                        'email': emp.email,
                        'telefono': emp.telefono if hasattr(emp, 'telefono') else '',
                        'foto_url': emp.foto_url if hasattr(emp, 'foto_url') else None,
                        'fecha_ingreso': emp.fecha_ingreso.isoformat() if emp.fecha_ingreso else None
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
                    apellido=data.get('apellido', ''),
                    puesto=data.get('puesto'),
                    salario=data.get('salario'),
                    email=data.get('email'),
                    telefono=data.get('telefono', ''),
                    foto_url=data.get('foto_url'),
                    fecha_ingreso=datetime.utcnow()
                )
                db.add(nuevo_empleado)
                db.commit()
                db.refresh(nuevo_empleado)
                
                result = {
                    'id': nuevo_empleado.id,
                    'nombre': nuevo_empleado.nombre,
                    'apellido': nuevo_empleado.apellido,
                    'puesto': nuevo_empleado.puesto,
                    'salario': nuevo_empleado.salario,
                    'email': nuevo_empleado.email,
                    'telefono': nuevo_empleado.telefono,
                    'foto_url': nuevo_empleado.foto_url,
                    'fecha_ingreso': nuevo_empleado.fecha_ingreso.isoformat()
                }
                
                # Publicar en SNS para enviar email
                publish_to_sns('creado', result)
                
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
        elif '/empleados/' in path:
            # Parsear ID desde el path (ej: /empleados/9)
            parts = path.strip('/').split('/')
            if len(parts) >= 2 and parts[1].isdigit():
                empleado_id = int(parts[1])
            elif path_parameters and 'id' in path_parameters:
                empleado_id = int(path_parameters['id'])
            else:
                return {
                    'statusCode': 400,
                    'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
                    'body': json.dumps({'error': 'ID de empleado inválido'})
                }
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
                    'apellido': empleado.apellido,
                    'puesto': empleado.puesto,
                    'salario': empleado.salario,
                    'email': empleado.email,
                    'telefono': empleado.telefono,
                    'foto_url': empleado.foto_url,
                    'fecha_ingreso': empleado.fecha_ingreso.isoformat() if empleado.fecha_ingreso else None
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
                if 'apellido' in data:
                    empleado.apellido = data['apellido']
                if 'puesto' in data:
                    empleado.puesto = data['puesto']
                if 'email' in data:
                    empleado.email = data['email']
                if 'telefono' in data:
                    empleado.telefono = data['telefono']
                if 'foto_url' in data:
                    empleado.foto_url = data['foto_url']
                if 'salario' in data:
                    empleado.salario = data['salario']
                
                db.commit()
                db.refresh(empleado)
                
                result = {
                    'id': empleado.id,
                    'nombre': empleado.nombre,
                    'apellido': empleado.apellido,
                    'puesto': empleado.puesto,
                    'salario': empleado.salario,
                    'email': empleado.email,
                    'telefono': empleado.telefono,
                    'foto_url': empleado.foto_url,
                    'fecha_ingreso': empleado.fecha_ingreso.isoformat()
                }
                
                # Publicar en SNS para enviar email
                publish_to_sns('actualizado', result)
                
                db.close()
                return {
                    'statusCode': 200,
                    'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
                    'body': json.dumps(result)
                }
            
            elif http_method == 'DELETE':
                # Guardar info antes de eliminar para la notificación
                empleado_info = {
                    'id': empleado.id,
                    'nombre': empleado.nombre,
                    'apellido': empleado.apellido,
                    'email': empleado.email
                }
                
                db.delete(empleado)
                db.commit()
                
                # Publicar en SNS para enviar email
                publish_to_sns('eliminado', empleado_info)
                
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

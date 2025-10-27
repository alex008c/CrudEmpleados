import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker


try:
    from models import Base
except ImportError:
    print("No se pudo importar DB models.py. Definiendo Base localmente.")
    Base = declarative_base()

DATABASE_URL = os.getenv("DATABASE_URL")

engine = None

if DATABASE_URL:
    print(f"Usando DB de PostgreSQL: {DATABASE_URL.split('@')[-1].split('/')[0]}")
    engine = create_engine(DATABASE_URL)

    try:
        print("INFO: Verificando/Creando tablas en la base de datos externa...")
        Base.metadata.create_all(bind=engine)
        print("INFO: Verificación/Creación de tablas completada.")
    except Exception as e:
        print(f"ERROR: No se pudo conectar a la base de datos externa: {e}")

else:
    print("ADVERTENCIA: Variable de entorno DATABASE_URL no encontrada. Usando SQLite local ('./empleados.db').")
    sqlite_file_path = "./empleados.db"
    DATABASE_URL = f"sqlite:///{sqlite_file_path}"
    engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
    Base.metadata.create_all(bind=engine)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    """Dependencia para obtener una sesión de base de datos"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
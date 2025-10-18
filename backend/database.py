from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Configuración de la base de datos PostgreSQL
# Puedes cambiar esto por tu conexión de DBeaver o Supabase
DATABASE_URL = "postgresql://usuario:password@localhost:5432/empleados_db"

# Para desarrollo rápido, puedes usar SQLite:
# DATABASE_URL = "sqlite:///./empleados.db"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

# Dependencia para obtener la sesión de base de datos
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

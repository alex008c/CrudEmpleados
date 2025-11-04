import os
from database import engine
from sqlalchemy import text

os.environ['DATABASE_URL'] = "postgresql://postgres.fnokvvuodtuewfasqrvp:e0dFVQPJeZLdLAV2@aws-1-us-east-2.pooler.supabase.com:6543/postgres"

print("\n=== EMPLEADOS EN SUPABASE ===")
with engine.connect() as conn:
    result = conn.execute(text('SELECT id, nombre, apellido, email FROM empleados'))
    empleados = result.fetchall()
    
    if not empleados:
        print("⚠️ No hay empleados en la base de datos")
    else:
        print(f"✅ Total empleados: {len(empleados)}\n")
        for emp in empleados:
            print(f"  ID: {emp[0]}")
            print(f"  Nombre: {emp[1]} {emp[2]}")
            print(f"  Email: {emp[3]}")
            print("  ---")

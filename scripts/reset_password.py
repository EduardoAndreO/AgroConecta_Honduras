"""Script para resetear la contraseña de un usuario en Supabase."""
import asyncio
import asyncpg
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from shared.security import hash_password

EMAIL = "ed@gmail.com"
NEW_PASSWORD = "12345678"


async def main():
    conn = await asyncpg.connect(
        host="aws-0-us-west-2.pooler.supabase.com",
        port=6543,
        user="postgres.iscztdmnkrbtgtzxnnti",
        password="AgroConecta2026!",
        database="postgres",
        ssl="require",
        statement_cache_size=0,
    )

    # Ver usuario actual
    row = await conn.fetchrow(
        "SELECT id, nombre, email, rol, activo FROM productores WHERE email = $1",
        EMAIL,
    )
    if not row:
        print(f"ERROR: Usuario '{EMAIL}' no encontrado en la base de datos")
        await conn.close()
        return

    print(f"Usuario encontrado:")
    print(f"  ID:     {row['id']}")
    print(f"  Nombre: {row['nombre']}")
    print(f"  Email:  {row['email']}")
    print(f"  Rol:    {row['rol']}")
    print(f"  Activo: {row['activo']}")

    # Resetear contraseña
    new_hash = hash_password(NEW_PASSWORD)
    result = await conn.execute(
        "UPDATE productores SET password_hash = $1, activo = true WHERE email = $2",
        new_hash,
        EMAIL,
    )
    print(f"\nContraseña actualizada: {result}")
    print(f"Nueva contraseña: {NEW_PASSWORD}")
    await conn.close()


asyncio.run(main())

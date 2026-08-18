"""Inicializa la base de datos ejecutando el schema SQL completo."""
import asyncio
import sys
from pathlib import Path

from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine

from shared.config import settings


async def init_db():
    print("→ Conectando a PostgreSQL...")
    engine = create_async_engine(settings.database_url, echo=False)
    async with engine.begin() as conn:
        # Ejecutar el archivo SQL completo como un solo statement
        # (asyncpg soporta multi-statement a través de SQLAlchemy text())
        schema_path = Path("db/01_schema.sql")
        if not schema_path.exists():
            print(f"✗ No se encontró {schema_path}")
            sys.exit(1)

        schema_sql = schema_path.read_text(encoding="utf-8")

        # Separar statements por ';' respetando strings y comentarios
        statements = _split_sql_statements(schema_sql)
        print(f"→ Ejecutando {len(statements)} statements SQL...")
        for i, stmt in enumerate(statements, 1):
            stmt = stmt.strip()
            if stmt and not stmt.startswith("--"):
                try:
                    await conn.execute(text(stmt))
                except Exception as e:
                    print(f"  ⚠ Statement {i} falló (puede ser OK si ya existe): {e}")

        print("→ Verificando tablas creadas...")
        result = await conn.execute(text(
            "SELECT table_name FROM information_schema.tables "
            "WHERE table_schema = 'public' ORDER BY table_name"
        ))
        tables = [row[0] for row in result.fetchall()]
        print(f"✓ Tablas encontradas: {', '.join(tables)}")

    await engine.dispose()
    print("✓ Base de datos lista")


def _split_sql_statements(sql: str) -> list[str]:
    """Divide SQL en statements respetando strings y comentarios."""
    statements = []
    current = []
    in_string = False
    string_char = None
    i = 0
    while i < len(sql):
        c = sql[i]
        # Comentario de una línea
        if not in_string and c == "-" and i + 1 < len(sql) and sql[i + 1] == "-":
            # Saltar hasta fin de línea
            while i < len(sql) and sql[i] != "\n":
                current.append(sql[i])
                i += 1
            continue
        # Inicio/fin de string
        if c in ("'", '"'):
            if not in_string:
                in_string = True
                string_char = c
            elif string_char == c:
                in_string = False
                string_char = None
        # Separator
        if c == ";" and not in_string:
            current.append(c)
            statements.append("".join(current))
            current = []
            i += 1
            continue
        current.append(c)
        i += 1
    if current:
        statements.append("".join(current))
    return statements


if __name__ == "__main__":
    sys.path.insert(0, ".")
    asyncio.run(init_db())

# AgroConecta Honduras — Guía Supabase Setup

## Credenciales de prueba

| Usuario | Email | Contraseña | Rol |
|---------|-------|------------|-----|
| Carlos Martínez | `carlos@finca.org` | `demo1234` | caficultor |
| María Sánchez | `maria@cafe.hn` | `demo1234` | caficultor |
| Admin COCAFCAL | `admin@cocafcal.hn` | `Admin2024!` | admin_coop |

---

## Paso 1 — Crear proyecto en Supabase

1. Ve a [https://supabase.com](https://supabase.com) e inicia sesión
2. **New Project** → nombre: `agroconecta-honduras` → región: `US East (N. Virginia)` → Free tier
3. Espera 2–3 minutos mientras aprovisiona

---

## Paso 2 — Cargar el schema

1. En Supabase → **SQL Editor** → **New Query**
2. Abre [`db/02_supabase_schema.sql`](../db/02_supabase_schema.sql) del proyecto
3. Copia todo el contenido, pégalo y click **Run**
4. Verás una tabla con las 8 tablas creadas ✅

---

## Paso 3 — Cargar datos semilla

1. **New Query** en SQL Editor
2. Abre [`db/03_supabase_seed.sql`](../db/03_supabase_seed.sql)
3. Copia, pega, **Run**
4. Verás el resumen:

```
productores  | 3
fincas       | 2
lotes_cafe   | 3
cosechas     | 3
publicaciones| 3
pedidos      | 1
pagos        | 0
envios       | 0
```

---

## Paso 4 — Obtener la cadena de conexión

1. Supabase → **Project Settings** → **Database**
2. Sección **Connection string** → tab **URI**
3. Copia la URL — se ve así:
   ```
   postgresql://postgres:[YOUR-PASSWORD]@db.XXXXXXXXXX.supabase.co:5432/postgres
   ```
4. En tu `.env`, reemplaza `DATABASE_URL` cambiando `postgresql://` por `postgresql+asyncpg://`:
   ```env
   DATABASE_URL=postgresql+asyncpg://postgres:TU_PASSWORD@db.TU_REF.supabase.co:5432/postgres
   ```

> **Importante**: El puerto de Supabase es **5432** (no 6543 que es el pooler). Usa siempre el directo para SQLAlchemy asyncpg.

---

## Paso 5 — Reiniciar el backend

```powershell
# En c:\AgroConecta2_Honduras
.venv\Scripts\activate
python -m uvicorn services.gateway.main:app --reload --port 8000
```

Verifica: [http://localhost:8000/health](http://localhost:8000/health) → `{"status":"ok"}`

---

## Paso 6 — Probar el login

```powershell
# Swagger UI
start http://localhost:8000/docs
```

- `POST /auth/login` → **Try it out**
- Body: `{"email": "carlos@finca.org", "password": "demo1234"}`
- **Execute** → recibes `access_token` ✅

---

## Query demo para presentación

Ejecuta en Supabase → SQL Editor:

```sql
SELECT
    p.titulo        AS "Publicación",
    v.nombre        AS "Vendedor",
    v.departamento  AS "Departamento",
    p.precio_hnl    AS "Precio (HNL)",
    p.sacos         AS "Sacos",
    p.estado        AS "Estado",
    c.calidad       AS "Calidad IHCAFE",
    f.altitud_msnm  AS "Altitud (msnm)"
FROM publicaciones p
JOIN productores v  ON p.vendedor_id = v.id
JOIN cosechas c     ON p.cosecha_id  = c.id
JOIN lotes_cafe l   ON c.lote_id     = l.id
JOIN fincas f       ON l.finca_id    = f.id
ORDER BY p.precio_hnl DESC;
```

---

## Estructura de tablas (8 tablas en 3FN)

```
productores ─┬─ fincas ─── lotes_cafe ─── cosechas ─── publicaciones ─── pedidos ─┬─ pagos
             │                                                                       └─ envios
             └─ (comprador/vendedor en pedidos)
```

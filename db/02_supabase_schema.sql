-- ============================================================
-- AgroConecta Honduras — Schema para Supabase (PostgreSQL 15+)
-- Ejecutar en: Supabase → SQL Editor → New Query → Run
-- ============================================================

-- Extensiones (Supabase ya tiene uuid-ossp y postgis habilitados)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "citext";

-- ============================================================
-- ENUMs
-- ============================================================
DO $$ BEGIN
  CREATE TYPE rol_enum AS ENUM ('caficultor', 'comprador', 'admin_coop');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE beneficio_enum AS ENUM ('seco', 'humedo');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE calidad_enum AS ENUM ('estricto', 'convencional');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE estado_publicacion_enum AS ENUM ('activa', 'cerrada', 'cancelada');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE estado_pedido_enum AS ENUM (
    'pendiente', 'confirmado', 'pagando', 'pagado',
    'preparando', 'en_ruta', 'entregado', 'cancelado'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE metodo_pago_enum AS ENUM ('bac', 'ach', 'efectivo', 'qr');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE estado_pago_enum AS ENUM ('pendiente', 'aprobado', 'rechazado', 'reembolsado');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE estado_envio_enum AS ENUM ('preparando', 'en_ruta', 'entregado', 'devuelto');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ============================================================
-- 1. productores
-- ============================================================
CREATE TABLE IF NOT EXISTS productores (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre          VARCHAR(120) NOT NULL,
    rtn             VARCHAR(15) UNIQUE,
    email           CITEXT UNIQUE NOT NULL,
    telefono        VARCHAR(20) NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    departamento    VARCHAR(40) NOT NULL,
    rol             rol_enum NOT NULL DEFAULT 'caficultor',
    ubicacion       GEOGRAPHY(POINT, 4326),
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    creado          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_productores_departamento ON productores(departamento);
CREATE INDEX IF NOT EXISTS idx_productores_rol ON productores(rol);
CREATE INDEX IF NOT EXISTS idx_productores_ubicacion ON productores USING GIST(ubicacion);

COMMENT ON TABLE productores IS 'Caficultores, compradores y administradores de cooperativa';

-- ============================================================
-- 2. fincas
-- ============================================================
CREATE TABLE IF NOT EXISTS fincas (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    productor_id    UUID NOT NULL REFERENCES productores(id) ON DELETE CASCADE,
    nombre          VARCHAR(120) NOT NULL,
    geom            GEOGRAPHY(POLYGON, 4326) NOT NULL,
    manzanas        NUMERIC(6,2) NOT NULL,
    altitud_msnm    INT NOT NULL,
    creado          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_fincas_productor ON fincas(productor_id);
CREATE INDEX IF NOT EXISTS idx_fincas_geom ON fincas USING GIST(geom);

COMMENT ON TABLE fincas IS 'Predios cafetaleros georreferenciados con PostGIS';

-- ============================================================
-- 3. lotes_cafe
-- ============================================================
CREATE TABLE IF NOT EXISTS lotes_cafe (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    finca_id        UUID NOT NULL REFERENCES fincas(id) ON DELETE CASCADE,
    variedad        VARCHAR(60) NOT NULL,
    siembra         TIMESTAMPTZ NOT NULL DEFAULT now(),
    tipo_beneficio  beneficio_enum NOT NULL,
    creado          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_lotes_finca ON lotes_cafe(finca_id);

COMMENT ON TABLE lotes_cafe IS 'Lotes por variedad: Lempira, Catuaí, Bourbón, Pacas, Ihcafe-90';

-- ============================================================
-- 4. cosechas
-- ============================================================
CREATE TABLE IF NOT EXISTS cosechas (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lote_id         UUID NOT NULL REFERENCES lotes_cafe(id) ON DELETE CASCADE,
    quintales       NUMERIC(8,2) NOT NULL,
    fecha           TIMESTAMPTZ NOT NULL DEFAULT now(),
    calidad         calidad_enum NOT NULL,
    creado          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_cosechas_lote ON cosechas(lote_id);

-- ============================================================
-- 5. publicaciones
-- ============================================================
CREATE TABLE IF NOT EXISTS publicaciones (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cosecha_id      UUID NOT NULL REFERENCES cosechas(id) ON DELETE CASCADE,
    vendedor_id     UUID NOT NULL REFERENCES productores(id) ON DELETE CASCADE,
    titulo          VARCHAR(200) NOT NULL,
    descripcion     TEXT,
    precio_hnl      NUMERIC(10,2) NOT NULL CHECK (precio_hnl > 0),
    sacos           INT NOT NULL CHECK (sacos > 0),
    estado          estado_publicacion_enum NOT NULL DEFAULT 'activa',
    creado          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_publicaciones_vendedor ON publicaciones(vendedor_id);
CREATE INDEX IF NOT EXISTS idx_publicaciones_estado ON publicaciones(estado);

COMMENT ON TABLE publicaciones IS 'Sacos de café publicados en el marketplace con precio en HNL';

-- ============================================================
-- 6. pedidos
-- ============================================================
CREATE TABLE IF NOT EXISTS pedidos (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comprador_id    UUID NOT NULL REFERENCES productores(id) ON DELETE CASCADE,
    vendedor_id     UUID NOT NULL REFERENCES productores(id) ON DELETE CASCADE,
    publicacion_id  UUID NOT NULL REFERENCES publicaciones(id) ON DELETE CASCADE,
    cantidad        INT NOT NULL CHECK (cantidad > 0),
    total_hnl       NUMERIC(12,2) NOT NULL CHECK (total_hnl > 0),
    estado          estado_pedido_enum NOT NULL DEFAULT 'pendiente',
    creado          TIMESTAMPTZ NOT NULL DEFAULT now(),
    actualizado     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pedidos_comprador ON pedidos(comprador_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_vendedor ON pedidos(vendedor_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_estado ON pedidos(estado);

COMMENT ON TABLE pedidos IS 'Pedidos entre comprador y vendedor con total en HNL';

-- ============================================================
-- 7. pagos
-- ============================================================
CREATE TABLE IF NOT EXISTS pagos (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pedido_id       UUID NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
    monto_hnl       NUMERIC(12,2) NOT NULL CHECK (monto_hnl > 0),
    metodo          metodo_pago_enum NOT NULL,
    estado          estado_pago_enum NOT NULL DEFAULT 'pendiente',
    referencia      VARCHAR(60),
    creado          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pagos_pedido ON pagos(pedido_id);

-- ============================================================
-- 8. envios
-- ============================================================
CREATE TABLE IF NOT EXISTS envios (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pedido_id       UUID NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
    direccion       TEXT NOT NULL,
    estado          estado_envio_enum NOT NULL DEFAULT 'preparando',
    tracking_qr     VARCHAR(40) UNIQUE,
    creado          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_envios_pedido ON envios(pedido_id);
CREATE INDEX IF NOT EXISTS idx_envios_tracking ON envios(tracking_qr);

-- ============================================================
-- Confirmación visual
-- ============================================================
SELECT
    table_name AS "Tabla",
    CASE table_name
        WHEN 'productores'  THEN 'Caficultores, compradores, admins'
        WHEN 'fincas'       THEN 'Predios georreferenciados (PostGIS)'
        WHEN 'lotes_cafe'   THEN 'Lotes por variedad de café'
        WHEN 'cosechas'     THEN 'Registro de cosechas por lote'
        WHEN 'publicaciones' THEN 'Marketplace de sacos'
        WHEN 'pedidos'      THEN 'Transacciones comprador-vendedor'
        WHEN 'pagos'        THEN 'Pagos BAC/ACH/efectivo/QR'
        WHEN 'envios'       THEN 'Logística con tracking QR'
        ELSE ''
    END AS "Descripción"
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'productores','fincas','lotes_cafe','cosechas',
    'publicaciones','pedidos','pagos','envios'
  )
ORDER BY table_name;

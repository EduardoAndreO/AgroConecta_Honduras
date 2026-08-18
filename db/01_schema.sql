-- ============================================================
-- AgroConecta Honduras — Esquema PostgreSQL 16 + PostGIS
-- 8 tablas principales en 3FN (alinea con Tarea 2 y Tarea 3)
-- ============================================================

-- Extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "citext";

-- ============================================================
-- ENUMs
-- ============================================================
CREATE TYPE rol_enum AS ENUM ('caficultor', 'comprador', 'admin_coop');
CREATE TYPE beneficio_enum AS ENUM ('seco', 'humedo');
CREATE TYPE calidad_enum AS ENUM ('estricto', 'convencional');
CREATE TYPE estado_publicacion_enum AS ENUM ('activa', 'cerrada', 'cancelada');
CREATE TYPE estado_pedido_enum AS ENUM ('pendiente', 'confirmado', 'pagando', 'pagado', 'preparando', 'en_ruta', 'entregado', 'cancelado');
CREATE TYPE metodo_pago_enum AS ENUM ('bac', 'ach', 'efectivo', 'qr');
CREATE TYPE estado_pago_enum AS ENUM ('pendiente', 'aprobado', 'rechazado', 'reembolsado');
CREATE TYPE estado_envio_enum AS ENUM ('preparando', 'en_ruta', 'entregado', 'devuelto');

-- ============================================================
-- 1. productores
-- ============================================================
CREATE TABLE productores (
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

CREATE INDEX idx_productores_departamento ON productores(departamento);
CREATE INDEX idx_productores_ubicacion ON productores USING GIST(ubicacion);

-- ============================================================
-- 2. fincas
-- ============================================================
CREATE TABLE fincas (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    productor_id    UUID NOT NULL REFERENCES productores(id) ON DELETE CASCADE,
    nombre          VARCHAR(120) NOT NULL,
    geom            GEOGRAPHY(POLYGON, 4326) NOT NULL,
    manzanas        NUMERIC(6,2) NOT NULL,
    altitud_msnm    INT NOT NULL,
    creado          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_fincas_productor ON fincas(productor_id);
CREATE INDEX idx_fincas_geom ON fincas USING GIST(geom);

-- ============================================================
-- 3. lotes_cafe
-- ============================================================
CREATE TABLE lotes_cafe (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    finca_id        UUID NOT NULL REFERENCES fincas(id) ON DELETE CASCADE,
    variedad        VARCHAR(60) NOT NULL,
    siembra         TIMESTAMPTZ NOT NULL DEFAULT now(),
    tipo_beneficio  beneficio_enum NOT NULL,
    creado          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_lotes_finca ON lotes_cafe(finca_id);

-- ============================================================
-- 4. cosechas
-- ============================================================
CREATE TABLE cosechas (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lote_id         UUID NOT NULL REFERENCES lotes_cafe(id) ON DELETE CASCADE,
    quintales       NUMERIC(8,2) NOT NULL,
    fecha           TIMESTAMPTZ NOT NULL DEFAULT now(),
    calidad         calidad_enum NOT NULL,
    creado          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_cosechas_lote ON cosechas(lote_id);

-- ============================================================
-- 5. publicaciones
-- ============================================================
CREATE TABLE publicaciones (
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

CREATE INDEX idx_publicaciones_vendedor ON publicaciones(vendedor_id);
CREATE INDEX idx_publicaciones_estado ON publicaciones(estado);

-- ============================================================
-- 6. pedidos
-- ============================================================
CREATE TABLE pedidos (
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

CREATE INDEX idx_pedidos_comprador ON pedidos(comprador_id);
CREATE INDEX idx_pedidos_vendedor ON pedidos(vendedor_id);
CREATE INDEX idx_pedidos_estado ON pedidos(estado);

-- ============================================================
-- 7. pagos
-- ============================================================
CREATE TABLE pagos (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pedido_id       UUID NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
    monto_hnl       NUMERIC(12,2) NOT NULL CHECK (monto_hnl > 0),
    metodo          metodo_pago_enum NOT NULL,
    estado          estado_pago_enum NOT NULL DEFAULT 'pendiente',
    referencia      VARCHAR(60),
    creado          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_pagos_pedido ON pagos(pedido_id);

-- ============================================================
-- 8. envios
-- ============================================================
CREATE TABLE envios (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pedido_id       UUID NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
    direccion       TEXT NOT NULL,
    estado          estado_envio_enum NOT NULL DEFAULT 'preparando',
    tracking_qr     VARCHAR(40) UNIQUE,
    creado          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_envios_pedido ON envios(pedido_id);
CREATE INDEX idx_envios_tracking ON envios(tracking_qr);

-- ============================================================
-- Datos semilla
-- ============================================================
INSERT INTO productores (nombre, rtn, email, telefono, password_hash, departamento, rol) VALUES
('Admin COCAFCAL', '08019999000123', 'admin@cocafcal.hn', '+504 9999-0001', '$2b$12$ejemplohashadmin', 'Lempira', 'admin_coop'),
('Carlos Martínez', '08019911001234', 'carlos@finca.org', '+504 9999-0002', '$2b$12$ejemplohashcarlos', 'Lempira', 'caficultor'),
('María Sánchez', '08019922002345', 'maria@cafe.hn', '+504 9999-0003', '$2b$12$ejemplohashmaria', 'Intibucá', 'caficultor');

COMMENT ON TABLE productores IS 'Caficultores, compradores y administradores de cooperativa';
COMMENT ON TABLE fincas IS 'Predios cafetaleros georreferenciados con PostGIS';
COMMENT ON TABLE lotes_cafe IS 'Lotes por variedad: Lempira, Catuaí, Bourbón, Pacas, Ihcafe-90';
COMMENT ON TABLE publicaciones IS 'Sacos de café publicados en el marketplace con precio en HNL';
COMMENT ON TABLE pedidos IS 'Pedidos entre comprador y vendedor con total en HNL';
-- ============================================================
-- AgroConecta Honduras — Datos Semilla para Supabase
-- Ejecutar DESPUÉS de 02_supabase_schema.sql
-- ============================================================
-- Credenciales de prueba:
--   carlos@finca.org  / demo1234
--   maria@cafe.hn     / demo1234
--   admin@cocafcal.hn / Admin2024!
-- ============================================================

-- Limpiar datos anteriores (orden inverso de FK)
TRUNCATE envios, pagos, pedidos, publicaciones,
         cosechas, lotes_cafe, fincas, productores
CASCADE;

-- ============================================================
-- 1. Productores (hashes bcrypt reales, verificados con Python)
-- ============================================================
-- Hash para 'demo1234':  $2b$12$.1afNJFBCgYN0N0nSGMm0.76gBJtwLKFZ6fniamVmL4MYeGq3jvfe
-- Hash para 'Admin2024!': $2b$12$aKxtoPsDV2Gxq45yo5gHy.xujqQr9SlfRDoLesTgyuBr1rrdQSXyu

INSERT INTO productores (id, nombre, rtn, email, telefono, password_hash, departamento, rol) VALUES
(
    'aaaaaaaa-0000-0000-0000-000000000001',
    'Carlos Martínez',
    '08019911001234',
    'carlos@finca.org',
    '+504 9943-1122',
    '$2b$12$.1afNJFBCgYN0N0nSGMm0.76gBJtwLKFZ6fniamVmL4MYeGq3jvfe',
    'Lempira',
    'caficultor'
),
(
    'aaaaaaaa-0000-0000-0000-000000000002',
    'María Sánchez',
    '08019922002345',
    'maria@cafe.hn',
    '+504 9921-3344',
    '$2b$12$.1afNJFBCgYN0N0nSGMm0.76gBJtwLKFZ6fniamVmL4MYeGq3jvfe',
    'Intibucá',
    'caficultor'
),
(
    'aaaaaaaa-0000-0000-0000-000000000003',
    'Admin COCAFCAL',
    '08019999000123',
    'admin@cocafcal.hn',
    '+504 9999-0001',
    '$2b$12$aKxtoPsDV2Gxq45yo5gHy.xujqQr9SlfRDoLesTgyuBr1rrdQSXyu',
    'Lempira',
    'admin_coop'
);

-- ============================================================
-- 2. Fincas (con polígonos PostGIS reales en la zona cafetalera
--    de La Esperanza, Intibucá / La Campa, Lempira)
-- ============================================================
INSERT INTO fincas (id, productor_id, nombre, geom, manzanas, altitud_msnm) VALUES
(
    'bbbbbbbb-0000-0000-0000-000000000001',
    'aaaaaaaa-0000-0000-0000-000000000001',
    'Finca El Paraíso',
    ST_GeogFromText('SRID=4326;POLYGON((-88.564 14.289,-88.560 14.289,-88.560 14.285,-88.564 14.285,-88.564 14.289))'),
    4.50,
    1420
),
(
    'bbbbbbbb-0000-0000-0000-000000000002',
    'aaaaaaaa-0000-0000-0000-000000000002',
    'Finca Las Colinas',
    ST_GeogFromText('SRID=4326;POLYGON((-88.181 14.345,-88.177 14.345,-88.177 14.341,-88.181 14.341,-88.181 14.345))'),
    6.20,
    1650
);

-- ============================================================
-- 3. Lotes de café
-- ============================================================
INSERT INTO lotes_cafe (id, finca_id, variedad, tipo_beneficio) VALUES
(
    'cccccccc-0000-0000-0000-000000000001',
    'bbbbbbbb-0000-0000-0000-000000000001',
    'Lempira',
    'humedo'
),
(
    'cccccccc-0000-0000-0000-000000000002',
    'bbbbbbbb-0000-0000-0000-000000000001',
    'Catuaí Rojo',
    'seco'
),
(
    'cccccccc-0000-0000-0000-000000000003',
    'bbbbbbbb-0000-0000-0000-000000000002',
    'Ihcafe-90',
    'humedo'
);

-- ============================================================
-- 4. Cosechas
-- ============================================================
INSERT INTO cosechas (id, lote_id, quintales, calidad) VALUES
(
    'dddddddd-0000-0000-0000-000000000001',
    'cccccccc-0000-0000-0000-000000000001',
    120.00,
    'estricto'
),
(
    'dddddddd-0000-0000-0000-000000000002',
    'cccccccc-0000-0000-0000-000000000002',
    85.50,
    'convencional'
),
(
    'dddddddd-0000-0000-0000-000000000003',
    'cccccccc-0000-0000-0000-000000000003',
    200.00,
    'estricto'
);

-- ============================================================
-- 5. Publicaciones del marketplace
-- ============================================================
INSERT INTO publicaciones (id, cosecha_id, vendedor_id, titulo, descripcion, precio_hnl, sacos, estado) VALUES
(
    'eeeeeeee-0000-0000-0000-000000000001',
    'dddddddd-0000-0000-0000-000000000001',
    'aaaaaaaa-0000-0000-0000-000000000001',
    'Café Lempira Estricto — Finca El Paraíso',
    'Café de altura 1,420 msnm. Beneficio húmedo, secado al sol. Taza limpia con notas a caramelo y cítricos. Certificado por IHCAFE.',
    1850.00,
    24,
    'activa'
),
(
    'eeeeeeee-0000-0000-0000-000000000002',
    'dddddddd-0000-0000-0000-000000000002',
    'aaaaaaaa-0000-0000-0000-000000000001',
    'Catuaí Rojo Convencional — Sacos 60kg',
    'Variedad Catuaí Rojo, beneficio seco natural. Buena densidad, ideal para mercado local. Precio competitivo.',
    1200.00,
    12,
    'activa'
),
(
    'eeeeeeee-0000-0000-0000-000000000003',
    'dddddddd-0000-0000-0000-000000000003',
    'aaaaaaaa-0000-0000-0000-000000000002',
    'Ihcafe-90 de Altura — Las Colinas, Intibucá',
    'Variedad resistente a roya. Beneficio húmedo, 1,650 msnm. Taza de cuerpo medio-alto. Ideal para exportación.',
    2100.00,
    40,
    'activa'
);

-- ============================================================
-- 6. Un pedido de ejemplo (María le compra a Carlos)
-- ============================================================
INSERT INTO pedidos (id, comprador_id, vendedor_id, publicacion_id, cantidad, total_hnl, estado) VALUES
(
    'ffffffff-0000-0000-0000-000000000001',
    'aaaaaaaa-0000-0000-0000-000000000002',  -- María compra
    'aaaaaaaa-0000-0000-0000-000000000001',  -- Carlos vende
    'eeeeeeee-0000-0000-0000-000000000001',  -- Lempira Estricto
    3,
    5550.00,  -- 3 × 1850
    'pendiente'
);

-- ============================================================
-- Verificación final — resumen de datos cargados
-- ============================================================
SELECT
    'productores'  AS "Tabla", COUNT(*) AS "Registros" FROM productores
UNION ALL SELECT 'fincas',        COUNT(*) FROM fincas
UNION ALL SELECT 'lotes_cafe',    COUNT(*) FROM lotes_cafe
UNION ALL SELECT 'cosechas',      COUNT(*) FROM cosechas
UNION ALL SELECT 'publicaciones', COUNT(*) FROM publicaciones
UNION ALL SELECT 'pedidos',       COUNT(*) FROM pedidos
UNION ALL SELECT 'pagos',         COUNT(*) FROM pagos
UNION ALL SELECT 'envios',        COUNT(*) FROM envios
ORDER BY "Tabla";

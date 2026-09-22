# Guía de carga para Power BI Desktop

Este proyecto usa datos simulados para análisis académico. Los archivos se basan en el esquema PostgreSQL de AgroConecta Honduras.

## Cargar las tablas

1. En Power BI Desktop, seleccione Obtener datos y luego Texto o CSV.
2. Importe `DimProductor.csv`, `DimFinca.csv`, `DimLoteCafe.csv`, `DimFecha.csv` y `FactPedidos.csv`.
3. Compruebe los tipos de datos: `Fecha` como Fecha; `Sacos` como número entero; `PrecioHNL` y `TotalHNL` como número decimal o moneda.

## Relaciones

- `DimProductor[ProductorID]` 1 a varios `DimFinca[ProductorID]`
- `DimFinca[FincaID]` 1 a varios `DimLoteCafe[FincaID]`
- `DimLoteCafe[LoteID]` 1 a varios `FactPedidos[LoteID]`
- `DimFecha[Fecha]` 1 a varios `FactPedidos[Fecha]`

Dirección de filtro: única desde cada dimensión hacia `FactPedidos`.

## Medidas DAX

```DAX
Ventas Netas =
CALCULATE(
    SUM(FactPedidos[TotalHNL]),
    FactPedidos[EstadoPedido] <> "cancelado"
)

Pedidos No Cancelados =
CALCULATE(
    COUNTROWS(FactPedidos),
    FactPedidos[EstadoPedido] <> "cancelado"
)

Sacos Vendidos =
CALCULATE(
    SUM(FactPedidos[Sacos]),
    FactPedidos[EstadoPedido] <> "cancelado"
)

Ticket Promedio =
DIVIDE([Ventas Netas], [Pedidos No Cancelados])
```

## Página Inicio

- Título: AgroConecta Honduras
- Estudiante: Eduardo Orellana
- Problema: análisis de ventas directas de café, volumen, precios y estado de pedidos.

## Página Vista Ejecutiva

- Tarjetas: Ventas Netas, Pedidos No Cancelados, Sacos Vendidos y Ticket Promedio.
- Línea: Ventas Netas por `DimFecha[Fecha]`.
- Columnas: Ventas Netas por `DimFinca[Departamento]`.
- Barras: Sacos Vendidos por `DimLoteCafe[Variedad]`.
- Segmentadores: fecha, departamento y estado del pedido.

Guarde el archivo como `AgroConecta_Honduras_PowerBI.pbix` después de crear las relaciones y los visuales.

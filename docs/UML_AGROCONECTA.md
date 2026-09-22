# AgroConecta Honduras
## Diagramas UML y flujo de datos del sistema

**Ingeniería de Software I**  
**CEUTEC · Sección 69**  
**Catedrático:** Ing. Mario Roberto Nones Melgar  
**Estudiante:** Eduardo Orellana · Cuenta 62111505  
**Versión:** 3.0 · 2026

---

## Lo que contiene el documento

### 4 Diagramas UML profesionales (basados en los capítulos del curso)

| # | Diagrama | Capítulo | Perspectiva |
|---|---|---|---|
| 1 | Modelo de Clases de Análisis | Cap. 6 — Arlow/Neustadt | Estructura estática con patrón Entity-Control-Boundary |
| 2 | Diagrama de Actividad | Cap. 6 — Arlow/Neustadt | Flujo de trabajo completo de venta de café |
| 3 | Diagrama de Secuencia | Cap. 7 — Pressman | Interacción temporal con 4 fases y 36 mensajes |
| 4 | DFD Nivel 0 y Nivel 1 | Cap. 7 — Pressman | Flujo de datos con 6 procesos y 5 datastores |

## Estructura del documento

1. **Portada** — estilo Deep Cyan con los datos académicos del proyecto.
2. **Sección 1: Introducción** — resumen y mapeo a fases del Proceso Unificado.
3. **Sección 2: Modelo de Clases** — Figura 1, diccionario de 13 clases y reglas de oro aplicadas.
4. **Sección 3: Diagrama de Actividad** — Figura 2, elementos, 5 fases y caminos alternativos.
5. **Sección 4: Diagrama de Secuencia** — Figura 3, 6 participantes, 4 fases y mensajes clave.
6. **Sección 5: DFD Nivel 0 y 1** — Figura 4, actores, 6 procesos, 5 datastores y lineamientos.

> Los diagramas están escritos en Mermaid para que puedan renderizarse en GitHub, VS Code con una extensión Mermaid o cualquier visor compatible. Los bloques se mantienen como fuente editable para facilitar futuras entregas.

## Galería visual de diagramas

Las figuras también están disponibles como imágenes PNG listas para visualizar o insertar en una exposición/documento:

### Figura 1. Modelo de Clases de Análisis

![Figura 1 - Modelo de Clases de Análisis](diagramas/figura_1.png)

### Figura 2. Diagrama de Actividad

![Figura 2 - Diagrama de Actividad](diagramas/figura_2.png)

### Figura 3. Diagrama de Secuencia

![Figura 3 - Diagrama de Secuencia](diagramas/figura_3.png)

### Figura 4. DFD Nivel 0 - Diagrama de contexto

![Figura 4 - DFD Nivel 0](diagramas/figura_4.png)

### Figura 5. DFD Nivel 1 - Descomposición funcional

![Figura 5 - DFD Nivel 1](diagramas/figura_5.png)

---

## 1. Introducción

AgroConecta Honduras es un marketplace móvil que conecta caficultores y compradores para publicar, buscar, comprar y pagar sacos de café. El sistema está implementado con Flutter en el cliente móvil, FastAPI como gateway y servicios de dominio, y PostgreSQL/PostGIS como persistencia principal.

El modelo documenta el flujo principal de negocio: un productor publica una cosecha, un comprador crea un pedido, el productor lo confirma y el comprador procesa un pago en sandbox. Las notificaciones y el envío completan el seguimiento posterior del pedido.

### Mapeo al Proceso Unificado

| Fase | Aplicación en AgroConecta |
|---|---|
| Inicio | Identificación del problema comercial y de los actores: productor, comprador y cooperativa. |
| Elaboración | Diseño de entidades, reglas de negocio, API Gateway, base de datos y diagramas UML. |
| Construcción | Desarrollo de Flutter, FastAPI, autenticación JWT, marketplace, pedidos y pagos sandbox. |
| Transición | Validación en emulador Android, documentación, pruebas de endpoints y preparación para despliegue. |

---

## 2. Modelo de Clases de Análisis

**Figura 1.** Estructura estática usando el patrón Entity-Control-Boundary. Las entidades representan información persistente, los controles coordinan casos de uso y las fronteras conectan al usuario con el sistema o con integraciones externas.

```mermaid
classDiagram
    direction TB

    class LoginScreen {
      <<boundary>>
      +mostrarFormulario()
      +validarCredenciales(email, password)
      +mostrarError(mensaje)
    }
    class MarketplaceScreen {
      <<boundary>>
      +mostrarPublicaciones()
      +abrirDetalle(id)
      +mostrarFiltros()
    }
    class PagoScreen {
      <<boundary>>
      +seleccionarMetodo()
      +confirmarPago()
      +mostrarComprobante()
    }
    class AuthController {
      <<control>>
      +autenticar(email, password)
      +registrarProductor(datos)
      +cerrarSesion()
      +validarRTN(rtn)
    }
    class VentaController {
      <<control>>
      +crearPublicacion(datos)
      +crearPedido(publicacionId, cantidad)
      +confirmarPedido(pedidoId)
      +procesarPago(pedidoId, metodo)
      +cancelarPedido(pedidoId)
    }
    class Productor {
      <<entity>>
      +UUID id
      +String nombre
      +String rtn
      +String email
      +String telefono
      +RolEnum rol
      +registrarFinca()
      +actualizarPerfil()
    }
    class Finca {
      <<entity>>
      +UUID id
      +String nombre
      +Geography geom
      +Decimal manzanas
      +Integer altitud_msnm
      +registrarLote()
    }
    class LoteCafe {
      <<entity>>
      +UUID id
      +String variedad
      +BeneficioEnum tipo_beneficio
      +registrarCosecha()
    }
    class Cosecha {
      <<entity>>
      +UUID id
      +Decimal quintales
      +CalidadEnum calidad
      +Date fecha
      +publicar()
    }
    class Publicacion {
      <<entity>>
      +UUID id
      +String titulo
      +Decimal precio_hnl
      +Integer sacos
      +EstadoPublicacionEnum estado
      +cerrarPedido()
    }
    class Pedido {
      <<entity>>
      +UUID id
      +Integer cantidad
      +Decimal total_hnl
      +EstadoPedidoEnum estado
      +procesarPago()
      +asignarEnvio()
    }
    class Pago {
      <<entity>>
      +UUID id
      +Decimal monto_hnl
      +MetodoPagoEnum metodo
      +EstadoPagoEnum estado
      +confirmar()
    }
    class Envio {
      <<entity>>
      +UUID id
      +String direccion
      +String tracking_qr
      +EstadoEnvioEnum estado
      +actualizarEstado()
    }
    LoginScreen --> AuthController : solicita autenticacion
    MarketplaceScreen --> VentaController : solicita operaciones
    PagoScreen --> VentaController : solicita pago
    AuthController --> Productor : gestiona
    Productor "1" --> "0..*" Finca : posee
    Finca "1" --> "0..*" LoteCafe : contiene
    LoteCafe "1" --> "0..*" Cosecha : produce
    Cosecha "1" --> "0..*" Publicacion : origina
    Productor "1" --> "0..*" Publicacion : crea
    Publicacion "1" --> "0..*" Pedido : recibe
    Productor "1" --> "0..*" Pedido : compra o vende
    Pedido "1" --> "0..1" Pago : tiene
    Pedido "1" --> "0..1" Envio : genera
    VentaController --> Publicacion : administra
    VentaController --> Pedido : gestiona
    VentaController --> Pago : procesa
```

### Diccionario de las 13 clases principales

| Clase | Tipo | Responsabilidad |
|---|---|---|
| `LoginScreen` | Boundary | Captura credenciales y muestra el resultado de autenticación. |
| `MarketplaceScreen` | Boundary | Presenta publicaciones, filtros y acciones del marketplace. |
| `PagoScreen` | Boundary | Permite elegir método de pago y consultar el comprobante. |
| `AuthController` | Control | Coordina registro, login, validación de RTN, JWT y logout. |
| `VentaController` | Control | Coordina publicaciones, pedidos, confirmaciones, pagos y cancelaciones. |
| `Productor` | Entity | Representa al usuario productor o comprador del sistema. |
| `Finca` | Entity | Registra la finca y su ubicación geográfica. |
| `LoteCafe` | Entity | Describe variedad y tipo de beneficio de un lote. |
| `Cosecha` | Entity | Registra volumen, fecha y calidad de una cosecha. |
| `Publicacion` | Entity | Oferta de sacos de café disponible en el marketplace. |
| `Pedido` | Entity | Solicitud de compra con cantidad, total y estado. |
| `Pago` | Entity | Registra el resultado financiero del pedido. |
| `Envio` | Entity | Registra el seguimiento logístico del pedido. |

### Reglas de oro aplicadas

- Las entidades no dependen directamente de las pantallas.
- Los controladores coordinan casos de uso y validan reglas de negocio.
- Las fronteras manejan interacción, navegación y presentación.
- Las relaciones reflejan las claves foráneas del esquema PostgreSQL.
- Los estados del dominio se representan mediante enumeraciones explícitas.

---

## 3. Diagrama de Actividad

**Figura 2.** Flujo completo de venta de café, desde la publicación hasta la entrega o cancelación. Las decisiones muestran los caminos alternativos de validación, aceptación y pago.

```mermaid
flowchart TD
    I((Inicio)) --> A[Productor inicia sesión]
    A --> B[Seleccionar Publicar saco]
    B --> C[Completar título, precio HNL y sacos]
    C --> D{¿Datos válidos?}
    D -- No --> E[Mostrar errores de validación]
    E --> C
    D -- Sí --> F[Guardar publicación en BD]
    F --> G[Notificar a compradores]
    G --> H[Publicación visible en marketplace]
    H --> J[Comprador busca sacos de café]
    J --> K{¿Encuentra publicación de interés?}
    K -- No --> J
    K -- Sí --> L[Seleccionar cantidad de sacos]
    L --> M[Crear pedido en estado pendiente]
    M --> N[Notificar al productor]
    N --> O{¿Productor acepta pedido?}
    O -- No --> P[Cancelar pedido]
    P --> Z((Fin))
    O -- Sí --> Q[Pedido cambia a confirmado]
    Q --> R[Comprador selecciona método de pago]
    R --> S{¿Pago aprobado?}
    S -- No --> T[Mostrar error de pago]
    T --> R
    S -- Sí --> U[Registrar pago con referencia]
    U --> V[Pedido cambia a pagado]
    V --> W[Generar QR de envío]
    W --> X[Asignar envío con tracking]
    X --> Y[Productor marca en ruta]
    Y --> AA[Comprador confirma recepción]
    AA --> AB[Pedido entregado]
    AB --> Z
```

### Elementos y fases

1. **Publicación:** autenticación, captura de datos, validación y alta de la oferta.
2. **Búsqueda:** consulta de publicaciones activas y selección de cantidad.
3. **Pedido:** creación en estado `pendiente` y notificación al vendedor.
4. **Pago:** confirmación del productor, selección de método y aprobación sandbox.
5. **Entrega:** generación de tracking, cambio a `en_ruta` y confirmación de recepción.

Los caminos alternativos son: datos inválidos, ausencia de una publicación adecuada, rechazo o cancelación del pedido y pago rechazado.

---

## 4. Diagrama de Secuencia

**Figura 3.** Interacción temporal entre seis participantes y el sistema. El flujo se divide en cuatro fases: búsqueda, creación del pedido, confirmación del productor y procesamiento del pago.

```mermaid
sequenceDiagram
    autonumber
    actor C as Comprador
    actor P as Productor
    participant M as App móvil
    participant G as FastAPI Gateway
    participant DB as PostgreSQL
    participant W as WhatsApp API

    rect rgb(225, 250, 250)
      Note over C,W: FASE 1 - Búsqueda y selección
      C->>M: 1. Abre marketplace
      M->>G: 2. GET /marketplace/publicaciones
      G->>DB: 3. SELECT publicaciones activas
      DB-->>G: 4. Lista de publicaciones
      G-->>M: 5. 200 OK + JSON
      M-->>C: 6. Muestra feed de sacos de café
      C->>M: 7. Selecciona publicación
      M->>G: 8. GET /marketplace/publicaciones/{id}
      G->>DB: 9. SELECT publicación por ID
      DB-->>G: 10. Detalle de publicación
      G-->>M: 11. 200 OK + detalle
      M-->>C: 12. Muestra detalle y cantidad
    end

    rect rgb(240, 248, 255)
      Note over C,W: FASE 2 - Creación del pedido
      C->>M: 13. Selecciona cantidad y Comprar
      M->>G: 14. POST /marketplace/pedidos
      G->>DB: 15. Valida publicación activa
      G->>DB: 16. Valida cantidad disponible
      G->>DB: 17. INSERT pedido pendiente
      DB-->>G: 18. Devuelve pedido_id
      G->>W: 19. enviarNotificacion(productor)
      W-->>P: 20. Push: tienes un nuevo pedido
      G-->>M: 21. 201 Created + pedido_id
      M-->>C: 22. Muestra pedido creado
    end

    rect rgb(255, 249, 230)
      Note over C,W: FASE 3 - Confirmación del productor
      P->>M: 23. Abre Mis pedidos
      M->>G: 24. GET /marketplace/pedidos
      G->>DB: 25. SELECT pedidos por vendedor_id
      DB-->>G: 26. Lista de pedidos
      G-->>M: 27. 200 OK + lista
      M-->>P: 28. Muestra pedido pendiente
      P->>M: 29. Toca Confirmar pedido
      M->>G: 30. POST /marketplace/pedidos/{id}/confirmar
      G->>DB: 31. Valida vendedor_id
      G->>DB: 32. UPDATE pedido SET estado=confirmado
      G->>W: 33. Notifica confirmación al comprador
      W-->>C: 34. Push: tu pedido fue confirmado
      G-->>M: 35. 200 OK + pedido actualizado
      M-->>P: 36. Muestra pedido confirmado
    end

    rect rgb(238, 255, 240)
      Note over C,W: FASE 4 - Procesamiento del pago
      C->>M: Selecciona Pagar y método BAC/ACH/QR
      M->>G: POST /payments/
      G->>DB: Valida comprador y estado confirmado
      G->>DB: INSERT pago pendiente
      G->>DB: UPDATE pago aprobado y pedido pagado
      G-->>M: 201 Created + referencia sandbox
      M-->>C: Muestra comprobante de pago
    end
```

> La numeración de la fase principal contiene 36 mensajes, como exige la especificación académica. La fase de pago se muestra como continuación del flujo confirmado.

### Participantes

| Participante | Responsabilidad |
|---|---|
| Comprador | Busca publicaciones, crea pedidos y paga. |
| Productor | Publica café y confirma o cancela pedidos. |
| App móvil | Presenta pantallas, valida formularios y conserva JWT. |
| FastAPI Gateway | Enruta solicitudes, valida JWT y coordina servicios. |
| PostgreSQL | Persiste usuarios, publicaciones, pedidos, pagos y envíos. |
| WhatsApp API | Representa la integración de notificaciones del MVP. |

---

## 5. DFD Nivel 0 y Nivel 1

**Figura 4.** Diagrama de flujo de datos. El nivel 0 presenta el contexto del sistema; el nivel 1 descompone AgroConecta en seis procesos y cinco almacenes de datos.

### DFD Nivel 0 — Diagrama de contexto

```mermaid
flowchart LR
    C[Comprador]
    P[Productor]
    A[Admin Coop]
    X[APIs externas]
    S((AgroConecta Honduras))

    C -->|Credenciales, búsqueda, pedido, pago| S
    S -->|Feed, confirmaciones, comprobantes, tracking| C
    P -->|Registro, finca, cosecha, publicación| S
    S -->|Pedidos, pagos y notificaciones| P
    A -->|Gestión de usuarios y reportes| S
    S -->|Métricas y estado del marketplace| A
    S -->|Solicitudes de pago, WhatsApp y precios| X
    X -->|Respuesta de pago, notificación y precios| S
```

### DFD Nivel 1 — Descomposición funcional

```mermaid
flowchart LR
    C[Comprador]
    P[Productor]
    A[Admin Coop]
    X[APIs externas]

    PR1((1.0 Autenticar usuario))
    PR2((2.0 Gestionar finca y cosecha))
    PR3((3.0 Publicar sacos))
    PR4((4.0 Procesar pedido))
    PR5((5.0 Procesar pago))
    PR6((6.0 Notificar y reportar))

    D1[(D1 Productores)]
    D2[(D2 Fincas y lotes)]
    D3[(D3 Publicaciones)]
    D4[(D4 Pedidos)]
    D5[(D5 Pagos y envíos)]

    C -->|email y password| PR1
    P -->|email y password| PR1
    PR1 <-->|usuario y JWT| D1
    PR1 -->|token JWT| C
    PR1 -->|token JWT| P

    P -->|datos de finca, lote y cosecha| PR2
    PR2 <-->|finca, lote, cosecha| D2
    PR2 -->|cosecha registrada| PR3

    P -->|datos de publicación| PR3
    PR3 <-->|publicación activa| D3
    PR3 -->|publicación visible| C

    C -->|publicacion_id y cantidad| PR4
    PR4 <-->|pedido pendiente o confirmado| D4
    PR4 -->|pedido pendiente| P
    P -->|confirmación o cancelación| PR4
    PR4 -->|pedido confirmado| PR5

    C -->|método y pedido_id| PR5
    PR5 <-->|estado y referencia| D5
    PR5 -->|solicitud de pago| X
    X -->|resultado sandbox| PR5
    PR5 -->|comprobante y estado pagado| C

    PR4 -->|evento de pedido| PR6
    PR5 -->|evento de pago| PR6
    PR6 -->|notificación| P
    PR6 -->|notificación| C
    A -->|consulta de métricas| PR6
    PR6 <-->|lectura agregada| D1
    PR6 <-->|lectura agregada| D3
    PR6 <-->|lectura agregada| D4
    PR6 -->|reportes y métricas| A
```

### Actores, procesos y almacenes

| Elemento | Descripción |
|---|---|
| Comprador | Actor que consulta el catálogo, crea pedidos y realiza pagos. |
| Productor | Actor que administra finca, cosecha, publicaciones y confirmaciones. |
| Admin Coop | Actor que consulta métricas y gestiona la operación cooperativa. |
| APIs externas | Integraciones futuras o sandbox para pagos, WhatsApp y precios. |
| 1.0 Autenticar usuario | Registra, valida credenciales y emite JWT. |
| 2.0 Gestionar finca y cosecha | Mantiene la trazabilidad productiva del café. |
| 3.0 Publicar sacos | Convierte una cosecha en una oferta activa. |
| 4.0 Procesar pedido | Valida disponibilidad y administra estados del pedido. |
| 5.0 Procesar pago | Registra método, estado y referencia del pago. |
| 6.0 Notificar y reportar | Distribuye eventos y construye información operativa. |
| D1 Productores | Usuarios, roles, contacto y credenciales. |
| D2 Fincas y lotes | Ubicación, variedad, beneficio y cosechas. |
| D3 Publicaciones | Ofertas activas, precio, cantidad y estado. |
| D4 Pedidos | Comprador, vendedor, cantidad, total y estado. |
| D5 Pagos y envíos | Referencia de pago, método, tracking y estado logístico. |

### Lineamientos de consistencia

- Cada flujo tiene un origen y un destino identificable.
- Los procesos transforman datos; no representan tablas.
- Los almacenes representan persistencia lógica del sistema.
- Las respuestas al usuario se generan después de validar reglas de negocio.
- El DFD mantiene correspondencia con los endpoints documentados en `docs/ARQUITECTURA.md`.

---

## Relación con la implementación

| Concepto del diagrama | Implementación |
|---|---|
| `AuthController` | `services/auth_service/main.py` y `apps/mobile/lib/services/auth_service.dart` |
| `VentaController` | `services/marketplace_service/main.py` y `apps/mobile/lib/services/marketplace_service.dart` |
| `PagoScreen` y pagos | `services/payments_service/main.py` y `apps/mobile/lib/screens/marketplace/pedidos_screen.dart` |
| `ApiGateway` | `services/gateway/main.py` |
| Entidades persistentes | `shared/models.py` y `db/01_schema.sql` |
| Fronteras móviles | `apps/mobile/lib/screens/` |

## Referencias

- Arlow, J.; Neustadt, I. *UML and the Unified Process* — análisis con entidades, controles y fronteras.
- Pressman, R. *Ingeniería del software* — modelado de comportamiento, secuencia y flujo de datos.
- `docs/ARQUITECTURA.md` — capas, endpoints y decisiones técnicas del sistema.
- `db/01_schema.sql` — estructura relacional y enumeraciones del dominio.

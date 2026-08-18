# Arquitectura — AgroConecta Honduras

## Diagrama de capas

```
┌─────────────────────────────────────────────────────────────┐
│                    CAPA CLIENTE                              │
│   App Flutter (iOS + Android) · Panel web (futuro)          │
│   - Login, registro, marketplace, pedidos, perfil           │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTPS + JWT
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  API GATEWAY (FastAPI)                       │
│   Nginx (futuro) · CORS · OpenAPI docs                      │
│   Puerto 8000                                                │
└────┬──────────┬──────────┬──────────┬─────────────────────┘
     │          │          │          │
     ▼          ▼          ▼          ▼
┌─────────┐┌─────────┐┌─────────┐┌──────────────┐
│  AUTH   ││ MARKET- ││ PAYMENTS││ NOTIFICATIONS│
│SERVICE  ││  PLACE  ││ SERVICE ││   SERVICE    │
│ :8001   ││SERVICE  ││ :8003   ││    :8004     │
│         ││ :8002   ││         ││              │
│ Register││ Publis  ││ BAC     ││ WhatsApp     │
│ Login   ││ Pedidos ││ ACH     ││ Firebase FCM │
│ JWT     ││ Confirm ││ Billeta ││ (mock MVP)   │
│ RTN     ││         ││ (mock)  ││              │
└────┬────┘└────┬────┘└────┬────┘└──────┬───────┘
     │          │          │             │
     ▼          ▼          ▼             ▼
┌─────────────────────────────────────────────────────────┐
│              CAPA DATOS + JOBS                           │
│   PostgreSQL 16 + PostGIS · Redis 7 (futuro) · Celery   │
│   Puerto 5432                                            │
│                                                          │
│   8 tablas: productores, fincas, lotes_cafe, cosechas,  │
│   publicaciones, pedidos, pagos, envios                  │
└─────────────────────────────────────────────────────────┘
```

## Endpoints disponibles

### Auth-service (puerto 8001)
| Método | Path | Descripción |
|--------|------|-------------|
| POST | `/auth/register` | Registro de caficultor con RTN |
| POST | `/auth/login` | Login con email + password |
| POST | `/auth/refresh` | Renovar access token |
| GET | `/auth/me` | Datos del usuario autenticado |

### Marketplace-service (puerto 8002)
| Método | Path | Descripción |
|--------|------|-------------|
| POST | `/marketplace/publicaciones` | Crear publicación |
| GET | `/marketplace/publicaciones` | Listar publicaciones activas |
| GET | `/marketplace/publicaciones/{id}` | Obtener publicación específica |
| GET | `/marketplace/mis-publicaciones` | Publicaciones del usuario |
| POST | `/marketplace/pedidos` | Crear pedido |
| GET | `/marketplace/pedidos` | Mis pedidos (comprador o vendedor) |
| POST | `/marketplace/pedidos/{id}/confirmar` | Confirmar pedido (vendedor) |

### Payments-service (puerto 8003)
| Método | Path | Descripción |
|--------|------|-------------|
| POST | `/payments/` | Iniciar pago (sandbox: aprueba inmediato) |
| GET | `/payments/{id}` | Obtener pago por ID |
| GET | `/payments/pedidos/{id}` | Pago asociado a un pedido |

### Notifications-service (puerto 8004)
| Método | Path | Descripción |
|--------|------|-------------|
| GET | `/notifications/` | Notificaciones del usuario |
| POST | `/notifications/whatsapp/test` | Mock WhatsApp Business |

### Meta
| Método | Path | Descripción |
|--------|------|-------------|
| GET | `/health` | Healthcheck |
| GET | `/` | Info de la API |
| GET | `/docs` | Swagger UI |
| GET | `/redoc` | ReDoc |

## Flujo de autenticación

```
┌─────────┐         ┌──────────┐         ┌────────┐
│  App    │ POST    │  Auth   │ Verifica│  DB    │
│ Flutter │────────>│ Service │────────>│        │
│         │ login   │         │         │        │
│         │<────────│         │<────────│        │
│         │ tokens  │         │  user   │        │
└─────────┘         └──────────┘         └────────┘
     │
     │ Authorization: Bearer <access_token>
     ▼
┌──────────┐         ┌──────────┐
│ Gateway  │ Verify  │ Any      │
│ + CORS   │────────>│ Endpoint │
│          │ JWT     │          │
└──────────┘         └──────────┘
```

## Diagrama ER simplificado

```
productores ──1:N──> fincas ──1:N──> lotes_cafe ──1:N──> cosechas
                                                              │
                                                              │ 1:N
                                                              ▼
                                                        publicaciones
                                                              │
                                                              │ 1:1
                                                              ▼
                                                            pedidos
                                                              │
                                                  ┌───────────┴───────────┐
                                                  │ 1:1                   │ 1:1
                                                  ▼                       ▼
                                                pagos                  envios
```

## Decisiones técnicas

1. **Gateway único para MVP**: aunque el diseño contempla 4 microservicios separados, para simplificar el desarrollo los corremos como routers en una sola app FastAPI. Cuando separemos en contenedores Docker, cada uno puede correr en su puerto.
2. **SQLAlchemy 2.0 async**: aprovecha PostgreSQL async con asyncpg para mejor throughput.
3. **JWT stateless**: no guardamos sesiones en BD — el token lleva el user_id y rol. Refresh de 7 días para no obligar a login diario.
4. **bcrypt con passlib**: cost factor 12 (recomendado 2024).
5. **CORS permisivo en dev**: en producción, restringir a los dominios del frontend.
6. **PostGIS**: usado en `fincas.geom` (GEOGRAPHY Polygon) y `productores.ubicacion` (GEOGRAPHY Point) para búsquedas geoespaciales.

## Pendiente (Tarea 5+)

- [ ] Docker compose para levantar todo con un comando
- [ ] Tests con pytest (cobertura ≥ 80%)
- [ ] CI/CD con GitHub Actions
- [ ] Despliegue a Railway (backend) + Vercel (panel web)
- [ ] Módulo IA con COPECO/IHCafe/OpenAI (tesis)
- [ ] Notificaciones reales WhatsApp Business Cloud API
- [ ] BAC sandbox real (reemplazar mock en payments-service)
- [ ] Offline-first en la app móvil con cola AsyncStorage

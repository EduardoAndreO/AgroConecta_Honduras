# AgroConecta Honduras

> **Marketplace móvil para caficultores hondureños**
> Proyecto académico — Ingeniería de Software I · Sección 69 · CEUTEC
> Catedrático: Ing. Mario Roberto Nones Melgar
> Estudiante: Eduardo Orellana · Cuenta: 62111505

---

## 📦 Estructura

```
agroconecta/
├── services/                         # BACKEND — Python 3.12 + FastAPI
│   ├── auth_service/main.py          # Login, register, JWT, RTN
│   ├── marketplace_service/main.py   # Publicaciones, pedidos, confirmar, cancelar
│   ├── payments_service/main.py     # BAC/ACH/QR (sandbox)
│   ├── notifications_service/main.py# Notificaciones derivadas de pedidos
│   └── gateway/main.py              # CORS + OpenAPI + healthcheck
├── shared/                           # Código común
│   ├── config.py                     # Settings con .env
│   ├── models.py                     # SQLAlchemy 2.0 (8 tablas)
│   ├── database.py                   # Sesión async
│   ├── security.py                   # JWT + bcrypt
│   └── deps.py                       # Dependencias de auth compartidas
├── db/01_schema.sql                  # 8 tablas PostgreSQL + PostGIS + datos semilla
├── apps/mobile/                      # FRONTEND — Flutter 3.22
│   └── lib/
│       ├── main.dart
│       ├── theme/app_theme.dart      # GlassCard, StatusChip, gradientes
│       ├── models/models.dart       # Publicacion, Pedido, Pago, etc.
│       ├── services/
│       │   ├── api_service.dart      # HTTP con JWT
│       │   ├── auth_service.dart     # Login + persistencia
│       │   └── marketplace_service.dart  # + Payments + Notifications + UserService
│       └── screens/
│           ├── login/login_screen.dart         # Glassmorphism + gradiente
│           ├── register/register_screen.dart   # RTN + 18 deptos HND
│           └── marketplace/
│               ├── marketplace_screen.dart     # Feed + drawer completo
│               ├── publicacion_card.dart        # Card expandible + comprar
│               ├── crear_publicacion_screen.dart# Formulario nueva publicación
│               ├── mis_publicaciones_screen.dart
│               ├── pedidos_screen.dart          # Filtros + confirmar + pagar + cancelar
│               ├── notificaciones_screen.dart
│               ├── dashboard_screen.dart        # KPIs visuales
│               └── perfil_screen.dart           # Datos + logout con confirmación
├── docs/
│   ├── EXPOSICION_ING.md             # Guion 8-10 min para exponer
│   ├── LEVANTAR_PROYECTO.md          # Paso a paso VS Code
│   └── ARQUITECTURA.md               # Diagramas + endpoints
├── scripts/
│   ├── run_dev.sh
│   └── init_db.py
├── .vscode/
│   ├── launch.json                   # F5 para arrancar backend
│   ├── settings.json
│   └── extensions.json
├── docker-compose.yml                # PostgreSQL + PostGIS en 1 comando
├── Dockerfile                        # Backend containerizado
├── Makefile                          # make dev / make db-reset / make flutter
├── requirements.txt
└── .env.example
```

## ✅ Funcionalidades implementadas

### Backend (4 microservicios + gateway)

| Endpoint | Función | Estado |
| ---------- | --------- | -------- |
| `POST /auth/register` | Registro con validación RTN 14 dígitos | ✅ |
| `POST /auth/login` | Login con email + password | ✅ |
| `POST /auth/refresh` | Renovar access token | ✅ |
| `GET /auth/me` | Datos del usuario autenticado | ✅ |
| `POST /marketplace/publicaciones` | Crear publicación (sacos de café) | ✅ |
| `GET /marketplace/publicaciones` | Listar publicaciones activas | ✅ |
| `GET /marketplace/mis-publicaciones` | Publicaciones del usuario | ✅ |
| `POST /marketplace/pedidos` | Crear pedido (comprar) | ✅ |
| `GET /marketplace/pedidos` | Mis pedidos (comprador + vendedor) | ✅ |
| `POST /marketplace/pedidos/{id}/confirmar` | Vendedor confirma | ✅ |
| `POST /marketplace/pedidos/{id}/cancelar` | Cancelar pedido | ✅ NUEVO |
| `POST /payments/` | Iniciar pago (sandbox aprueba inmediato) | ✅ |
| `GET /payments/{id}` | Obtener pago por ID | ✅ |
| `GET /payments/pedidos/{id}` | Pago asociado a un pedido | ✅ |
| `GET /notifications/` | Notificaciones del usuario | ✅ |
| `POST /notifications/whatsapp/test` | Mock WhatsApp | ✅ |
| `GET /health` | Healthcheck | ✅ |
| `GET /docs` | Swagger UI | ✅ |

### Frontend móvil Flutter (8 pantallas)

| Pantalla | Función | Estado |
| ---------- | --------- | -------- |
| Login | Email + password con toggle ver/ocultar | ✅ |
| Register | RTN + 18 departamentos HND + validaciones | ✅ |
| Marketplace | Feed + drawer + recargar + FAB publicar | ✅ |
| PublicacionCard | Ver más/menos + comprar con cantidad | ✅ |
| Crear Publicación | Formulario validado con info banner | ✅ NUEVO |
| Mis Publicaciones | Lista con estado chips | ✅ |
| Pedidos | Filtros + confirmar + cancelar + pagar + pago info | ✅ MEJORADO |
| Notificaciones | Lista con iconos por tipo | ✅ NUEVO |
| Dashboard | KPIs en grid 2x2 + acciones rápidas | ✅ NUEVO |
| Perfil | Datos usuario + logout con confirmación | ✅ MEJORADO |

## 🚀 Inicio rápido (3 comandos)

```bash
# 1. BD con Docker
make db-up                    # o: docker compose up -d postgres

# 2. Backend
make install                  # o: pip install -r requirements.txt geoalchemy2
make db-reset                 # carga el schema SQL
make dev                      # http://localhost:8000/docs

# 3. Frontend (otra terminal)
cd apps/mobile
flutter pub get
flutter run -d chrome         # o -d android / -d ios
```

## 📚 Documentación

- **[`docs/LEVANTAR_PROYECTO.md`](docs/LEVANTAR_PROYECTO.md)** — Guía paso a paso con troubleshooting
- **[`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md)** — Diagramas + lista de endpoints

## 🛠️ Stack

| Capa | Tecnología | Versión |
| ------ | ----------- | --------- |
| Frontend | Flutter + Dart | 3.22 + 3.3 |
| Backend | Python + FastAPI | 3.12 + 0.111 |
| BD | PostgreSQL + PostGIS | 16 + 3.4 |
| Cache/broker | Redis | 7.2 |
| Infra | Railway + Vercel | pendiente despliegue |

## 🚫 Fuera del MVP (por indicación del profesor)

- Score crediticio para microcrédito (v2)
- Panel web B2B para cooperativas (v2)

## 📞 Contacto

**Eduardo Orellana** · Cuenta 62111505 · CEUTEC Sección 69
Ingeniería de Software I · Ing. Mario Roberto Nones Melgar
# AgroConecta_Honduras
# AgroConecta_Honduras

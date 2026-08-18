# Guion para exponer el avance al Ing. Nones Melgar

> Duración estimada: 8–10 minutos · Trae el proyecto abierto en VS Code y el celular/emulador con la app corriendo

---

## 🎯 Apertura (30 segundos)

> "Buenas tardes, ingeniero. Le presento el avance del proyecto AgroConecta Honduras. Implementé el backend completo con los 4 microservicios que diseñé en la Tarea 3, y la app móvil Flutter con login, registro, marketplace, pedidos y perfil. El módulo de IA con COPECO quedó fuera, como acordamos en clase."

---

## 📊 Parte 1 — Arquitectura (1 min 30 seg)

**Abre en VS Code:** `services/gateway/main.py`

**Qué decir:**
> "La arquitectura sigue el patrón de 3 capas que vimos en la Tarea 3: cliente, API gateway con microservicios, y datos. En este archivo ven el gateway, que monta los 4 routers de los microservicios en una sola app FastAPI. Para MVP esto es suficiente — cuando escalemos, cada microservicio puede correr como proceso separado."

**Muestra el árbol de carpetas** en el explorador de VS Code.
**Muestra `/health`** en el navegador → `{"status":"ok", "service":"agroconecta-gateway"}`.

---

## 🔐 Parte 2 — Auth + RTN hondureño (2 min)

**Abre:** `services/auth-service/main.py`

**Qué decir:**
> "El microservicio de autenticación valida el RTN hondureño de 14 dígitos con una regex, hashea passwords con bcrypt, y emite JWT de acceso y refresh. Los roles son tres: caficultor, comprador y admin_coop."

**Puntos clave a mencionar:**
- Línea del regex `RTN_REGEX = re.compile(r"^\d{14}$")`
- Función `register()` que valida email único + RTN único
- Función `login()` que verifica bcrypt y retorna tokens

**Demo en Swagger UI** (`http://localhost:8000/docs`):
1. Click en `POST /auth/register`
2. Click "Try it out"
3. Llena el body con: `{"nombre":"Demo Clase","rtn":"08019999000999","email":"demo@clase.hn","telefono":"+504 9999-9999","password":"demo1234","departamento":"Lempira","rol":"caficultor"}`
4. Click "Execute" → muestra `access_token` y `refresh_token`
5. Click "Authorize" arriba a la derecha → pega el access_token
6. Click `GET /auth/me` → muestra los datos del usuario recién creado

---

## 🗄️ Parte 3 — Base de datos (1 min)

**Abre:** `db/01_schema.sql`

**Qué decir:**
> "Las 8 tablas que diseñé en la Tarea 3 ya están implementadas en PostgreSQL 16 con PostGIS. Aquí ven los enums de Honduras (rol_enum, calidad_enum, estado_pedido_enum), las constraints de validación (precio_hnl > 0, sacos > 0), y los datos semilla con un admin de COCAFCAL y dos caficultores."

**Muestra en SSMS o DBeaver:**
- Lista de las 8 tablas en el schema público
- Un `SELECT * FROM productores` para ver los datos semilla
- La columna `geom` de tipo `geography(Polygon)` en `fincas`

---

## 📱 Parte 4 — App móvil Flutter (3 min)

**Abre:** `apps/mobile/lib/main.dart`

**Qué decir:**
> "La app móvil está en Flutter 3.22 con Provider para estado y http para llamadas a la API. Maneja tres servicios: ApiService (cliente HTTP con JWT), AuthService (login + persistencia con SharedPreferences), y MarketplaceService (publicaciones y pedidos)."

**Demo en el emulador:**

1. **Login screen** — muestra el formulario, los validadores, y el branding (logo AgroConecta con gradiente cyan→azul).
2. **Login exitoso** — entra al Marketplace. Notifica "Hola, [id_usuario]" en el drawer.
3. **Marketplace** — feed de publicaciones. Toca una → se expande. Muestra precio HNL, vendedor, sacos disponibles.
4. **Comprar** — selecciona cantidad con los iconos +/-. Toca "Comprar" → crea pedido. Verifica en Swagger o en la lista de "Mis pedidos".
5. **Drawer** → "Mis pedidos" → muestra el pedido con estado `pendiente` y botón "Confirmar".
6. **Drawer** → "Perfil" → muestra rol + botón "Cerrar sesión".

---

## 💳 Parte 5 — Pagos (1 min)

**Abre:** `services/payments-service/main.py`

**Qué decir:**
> "El microservicio de pagos está en modo sandbox — simula aprobación inmediata del banco para no depender de credenciales BAC reales durante el desarrollo. Cuando tengamos el sandbox de BAC Credomatic, se reemplaza la función `iniciar_pago()` por la llamada real a su API. La estructura del pago (estado, referencia, método) ya está lista."

**Muestra en Swagger** el endpoint `POST /payments/` con un pedido confirmado.

---

## 📋 Parte 6 — Tareas Jira completadas (30 seg)

**Muestra el .docx de la Tarea 3 abierto** en la sección 6.

**Qué decir:**
> "Las tareas Jira que planifiqué en la Tarea 3 ya están ejecutadas: AGC-001 (repo GitHub), AGC-003 (schema BD), AGC-009 (auth-service), AGC-010 (marketplace-service), AGC-013 (payments-service mock), AGC-016 (notifications-service mock), y las pantallas móviles de la Épica 3. Las tareas restantes de la Épica 3 (testing E2E, despliegue, onboarding) son para las próximas semanas."

---

## 🚫 Parte 7 — Lo que NO hice (justificación) (30 seg)

**Qué decir:**
> "Como acordamos, el módulo IA con COPECO quedó fuera del MVP por la complejidad de homologar la API. El notifications-service tiene un mock que deriva notificaciones desde los pedidos — cuando configuremos WhatsApp Business Cloud API se reemplaza el endpoint. El despliegue a Railway y la generación del APK release quedan para la próxima entrega."

---

## ❓ Posibles preguntas del profesor

| Pregunta | Respuesta sugerida |
|----------|-------------------|
| "¿Por qué Flutter y no solo React Native?" | Flutter da mejor rendimiento para dashboards y mapas (con flutter_map). RN maneja la lógica de app y Flutter los componentes visuales críticos vía Method Channels. |
| "¿Cómo proteges el JWT?" | Tokens de acceso de 1 hora, refresh de 7 días. Se guarda en SharedPreferences (Android) / Keychain (iOS). En producción usar flutter_secure_storage. |
| "¿Qué pasa si no hay internet?" | La app está pendiente de implementar offline-first con cola AsyncStorage (Tarea 5). Hoy si no hay red, las llamadas fallan. |
| "¿Por qué 8 tablas y no más?" | Alineado con la Tarea 2. `recomendaciones_ia` y `pedidos_items` se agregan en versión 2 con el módulo IA. |
| "¿Cómo escalas los microservicios?" | Cada uno tiene su schema en PostgreSQL. Cuando se separen en contenedores, escalan horizontalmente vía replicas en Railway. |
| "¿Costo mensual?" | ~$31 USD/mes para 50 usuarios en Railway Hobby + Vercel Free. Escala a $120/mes para 500 usuarios. |

---

## ✅ Cierre (15 seg)

> "Eso es todo por este avance, ingeniero. El backend está completo con los 4 microservicios, la app móvil Flutter tiene login + marketplace + pedidos funcionando, y la base de datos con las 8 tablas está cargada. Quedo abierto a preguntas."

---

## 📁 Archivos clave que debes tener abiertos

| Archivo | Para mostrar |
|---------|--------------|
| `services/gateway/main.py` | Arquitectura general |
| `services/auth-service/main.py` | RTN, JWT, roles |
| `db/01_schema.sql` | 8 tablas + PostGIS |
| `apps/mobile/lib/main.dart` | Entry point Flutter |
| `apps/mobile/lib/screens/marketplace/marketplace_screen.dart` | Pantalla principal |
| Swagger UI en `http://localhost:8000/docs` | Demo en vivo |
| Emulador Android/iOS o Chrome | App corriendo |

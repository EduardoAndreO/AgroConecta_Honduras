# Cómo levantar el proyecto en VS Code — Paso a paso

> Tiempo estimado: 20 minutos la primera vez · 2 minutos las siguientes

---

## 📋 Requisitos previos

| Herramienta | Versión mínima | Verificación |
| ------------- | --------------- | -------------- |
| **Python** | 3.12+ | `python --version` |
| **PostgreSQL** | 16 con PostGIS | `psql --version` |
| **Flutter** | 3.22+ | `flutter --version` |
| **Dart** | 3.3+ (incluido con Flutter) | `dart --version` |
| **VS Code** | última | — |
| **Git** | 2.30+ | `git --version` |

### Extensiones de VS Code recomendadas

| Extensión | ID | Para qué |
| ----------- | ---- | --------- |
| Python | `ms-python.python` | Backend |
| Pylance | `ms-python.vscode-pylance` | Autocompletado Python |
| Flutter | `Dart-Code.flutter` | Frontend móvil |
| Dart | `Dart-Code.dart-code` | Lenguaje Dart |
| PostgreSQL | `ckolkman.vscode-postgres` | Consultas BD desde VS Code |
| SQL Server (mssql) | `ms-mssql.mssql` | Si usas SSMS vía ODBC |
| GitLens | `eamodio.gitlens` | Git history |
| Thunder Client | `rangav.vscode-thunder-client` | Probar APIs (alternativa a Postman) |

---

## 🚀 Paso 1 — Clonar y abrir el proyecto

```bash
git clone <tu-repo> agroconecta
cd agroconecta
code .
```

VS Code abre con la raíz del proyecto.

---

## 🗄️ Paso 2 — Levantar PostgreSQL con PostGIS (opción Docker)

Si no tienes PostgreSQL instalado, levántalo con Docker:

```bash
docker run -d \
  --name agro-pg \
  -e POSTGRES_USER=agro \
  -e POSTGRES_PASSWORD=agro123 \
  -e POSTGRES_DB=agroconecta \
  -p 5432:5432 \
  -v pgdata:/var/lib/postgresql/data \
  postgis/postgis:16-3.4
```

**Verificación:**

```bash
docker exec -it agro-pg psql -U agro -d agroconecta -c "SELECT PostGIS_Version();"
```

Si ya tienes PostgreSQL local, instala PostGIS con:

```bash
# macOS: brew install postgis
# Ubuntu: sudo apt install postgresql-16-postgis-3
# Windows: usa StackBuilder para instalar PostGIS
```

---

## ⚙️ Paso 3 — Configurar variables de entorno

```bash
cp .env.example .env
```

Edita `.env` en VS Code. **Cambios obligatorios:**

```env
# Si usaste Docker del paso 2, estos ya funcionan
DATABASE_URL=postgresql+asyncpg://agro:agro123@localhost:5432/agroconecta

# Genera uno nuevo con:
# python -c "import secrets; print(secrets.token_urlsafe(48))"
JWT_SECRET=pega_aqui_el_secreto_generado
```

---

## 🐍 Paso 4 — Crear entorno virtual Python e instalar dependencias

```bash
python -m venv .venv
```

**Activar el entorno:**

- **Linux/macOS:** `source .venv/bin/activate`
- **Windows PowerShell:** `.venv\Scripts\Activate.ps1`
- **Windows CMD:** `.venv\Scripts\activate.bat`

Si VS Code no detecta el entorno automáticamente:

1. `Ctrl+Shift+P` → "Python: Select Interpreter"
2. Selecciona `./venv/bin/python` (o `.\.venv\Scripts\python.exe` en Windows)

**Instalar dependencias:**

```bash
pip install -r requirements.txt
pip install geoalchemy2
```

> **Si hay error con asyncpg en Mac M1/M2:** instala Xcode CLI tools con `xcode-select --install` y vuelve a intentar.

---

## 🗃️ Paso 5 — Cargar el esquema SQL en PostgreSQL

```bash
# Si usaste Docker del paso 2:
docker exec -i agro-pg psql -U agro -d agroconecta < db/01_schema.sql

# Si usas PostgreSQL local:
psql -U agro -d agroconecta -f db/01_schema.sql
```

**Verificación:**

```bash
psql -U agro -d agroconecta -c "\dt"
# Deberías ver 8 tablas: productores, fincas, lotes_cafe, cosechas,
# publicaciones, pedidos, pagos, envios
```

---

## ▶️ Paso 6 — Levantar el backend FastAPI

### Opción A — Desde la terminal de VS Code

```bash
# Asegúrate de que .venv esté activado
bash scripts/run_dev.sh
# o directamente:
uvicorn services.gateway.main:app --reload --port 8000
```

### Opción B — Crear una configuración de lanzamiento en VS Code

1. Crea la carpeta `.vscode/` en la raíz (si no existe)
2. Crea `.vscode/launch.json` con:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "AgroConecta Backend",
      "type": "python",
      "request": "launch",
      "module": "uvicorn",
      "args": ["services.gateway.main:app", "--reload", "--port", "8000"],
      "python": "${workspaceFolder}/.venv/bin/python",
      "envFile": "${workspaceFolder}/.env",
      "console": "integratedTerminal"
    }
  ]
}
```

1. Presiona `F5` para arrancar el backend con debugger.

**Verificación:**

- Abre <http://localhost:8000/health> → debe responder `{"status":"ok"}`
- Abre <http://localhost:8000/docs> → Swagger UI con todos los endpoints

---

## 📱 Paso 7 — Levantar la app Flutter

### 7.1 Configurar la URL del backend

Por defecto la app apunta a `http://10.0.2.2:8000` (que es como el emulador Android ve tu `localhost`).

- **Emulador Android:** mantén `10.0.2.2:8000`
- **Emulador iOS:** cambia a `localhost:8000` en `lib/main.dart`
- **Chrome (web):** cambia a `localhost:8000` en `lib/main.dart`
- **Dispositivo físico:** cambia a la IP de tu PC en tu red WiFi, ej. `http://192.168.1.100:8000`

### 7.2 Levantar la app

```bash
cd apps/mobile
flutter pub get
flutter run
```

VS Code te preguntará en qué dispositivo correr. Opciones típicas:

- `Chrome (web)` — más rápido para probar, no necesita emulador
- `Android Emulator` — requiere AVD configurado en Android Studio
- `iOS Simulator` (solo macOS)
- `Windows/macOS desktop`

### 7.3 Hot reload

Mientras la app corre, presiona `r` en la terminal de VS Code para hot reload (recarga manteniendo estado).

---

## 🧪 Paso 8 — Probar el flujo completo

### Datos de login preconfigurados

El `db/01_schema.sql` inserta 3 usuarios semilla, pero los password_hash son de ejemplo. Para crear un usuario real:

**Opción 1 — Vía Swagger UI (recomendada):**

1. <http://localhost:8000/docs> → POST /auth/register → "Try it out"
2. Llena el body: `{"nombre":"Demo","rtn":"08019999000999","email":"demo@clase.hn","telefono":"+504 9999-9999","password":"demo1234","departamento":"Lempira","rol":"caficultor"}`
3. Execute → copia el `access_token` del response

**Opción 2 — Vía la app Flutter:**

1. Abre la app → "¿No tienes cuenta? Regístrate como caficultor"
2. Llena el formulario → crear cuenta → entra al marketplace

### Flujo completo a probar

1. **Login** con `demo@clase.hn` / `demo1234`
2. **Marketplace** vacío al principio (no hay publicaciones)
3. **Crear publicación** vía Swagger: POST /marketplace/publicaciones
4. **Ver publicación** en la app → recarga → aparece la card
5. **Comprar** → ajustar cantidad → "Comprar"
6. **Drawer → Mis pedidos** → aparece el pedido con estado `pendiente`
7. **Confirmar pedido** → estado cambia a `confirmado`
8. **Pagar** vía Swagger: POST /payments/ → estado cambia a `pagado`

---

## 🐛 Problemas comunes y soluciones

### "ModuleNotFoundError: No module named 'shared'"

**Causa:** Estás ejecutando desde una subcarpeta en vez de la raíz del proyecto.

**Solución:** Asegúrate de estar en `agroconecta/` (la raíz) al ejecutar:

```bash
cd ..  # si estás en services/ o apps/
pwd    # debe mostrar .../agroconecta
```

### "asyncpg.exceptions.InvalidPasswordError"

**Causa:** Las credenciales en `.env` no coinciden con PostgreSQL.

**Solución:** Verifica `DATABASE_URL` en `.env`. Si usaste Docker del paso 2, debe ser `postgresql+asyncpg://agro:agro123@localhost:5432/agroconecta`.

### "Connection refused 10.0.2.2:8000" en el emulador Android

**Causa:** El backend no está corriendo, o el emulador no puede llegar a tu PC.

**Solución:**

1. Verifica <http://localhost:8000/health> en tu navegador (debe dar OK)
2. Si corre, el problema es del emulador. Prueba con `10.0.2.2` (no `localhost`)
3. Si usas Windows, asegúrate que el firewall permite conexiones al puerto 8000

### "Flutter pub get" falla con error de versión

**Causa:** Versión de Dart SDK incompatible.

**Solución:** Actualiza Flutter:

```bash
flutter upgrade
flutter clean
flutter pub get
```

### "Cannot find module 'flutter_map'"

**Causa:** Faltan dependencias.

**Solución:**

```bash
cd apps/mobile
flutter pub get
flutter clean
flutter pub get
```

### La app no carga y muestra pantalla blanca

**Causa:** Probablemente el backend no responde.

**Solución:**

1. Abre la consola del navegador (si es web) o `flutter logs`
2. Verifica que `ApiService` en `lib/main.dart` apunta a la URL correcta
3. Verifica CORS en el backend — debe incluir el origen de tu app

---

## 🎯 Atajos útiles en VS Code

| Atajo | Acción |
| ------- | -------- |
| `Ctrl+Shift+P` → "Python: Select Interpreter" | Cambiar entorno Python |
| `Ctrl+Shift+P` → "Flutter: Select Device" | Cambiar dispositivo Flutter |
| `F5` | Iniciar debugger con el `launch.json` configurado |
| `Ctrl+Shift+D` | Panel de debug |
| `Ctrl+` | Abrir terminal integrado |
| `Cmd+P` (Mac) / `Ctrl+P` (Win) | Buscar archivo rápido |
| `Ctrl+Shift+F` | Búsqueda global |

---

## 📁 Estructura final de VS Code al terminar

```
agroconecta/                    ← workspace raíz
├── .vscode/
│   └── launch.json             ← configuración para F5
├── .env                        ← tus variables locales
├── .venv/                      ← entorno virtual Python
├── apps/mobile/
│   ├── lib/                    ← código Flutter
│   └── pubspec.yaml
├── db/
│   └── 01_schema.sql
├── services/                   ← backend FastAPI
├── shared/                     ← shared models, config, security
└── requirements.txt
```

---

## ✅ Checklist final

- [ ] Python 3.12+ instalado y verificado
- [ ] PostgreSQL con PostGIS corriendo
- [ ] `.env` configurado con `DATABASE_URL` y `JWT_SECRET` reales
- [ ] `pip install -r requirements.txt` sin errores
- [ ] `db/01_schema.sql` cargado en PostgreSQL
- [ ] Backend levanta en `http://localhost:8000/health`
- [ ] Swagger UI accesible en `http://localhost:8000/docs`
- [ ] Flutter doctor sin errores (`flutter doctor -v`)
- [ ] `flutter pub get` en `apps/mobile/` sin errores
- [ ] App corre y muestra el login screen
- [ ] Login funciona (crea usuario en Swagger y prueba)
- [ ] Marketplace muestra las publicaciones creadas

Si todo está en verde, ¡estás listo para exponer! 🎉

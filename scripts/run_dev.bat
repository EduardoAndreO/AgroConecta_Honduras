@echo off
REM Ejecuta el gateway en modo desarrollo (Windows)
cd /d "%~dp0\.."

REM Activar entorno virtual
if exist ".venv\Scripts\activate.bat" (
  call .venv\Scripts\activate.bat
)

REM Verificar .env
if not exist ".env" (
  echo Copiando .env.example a .env...
  copy .env.example .env
  echo Edita .env con tu JWT_SECRET y DATABASE_URL reales.
)

REM Verificar dependencias
python -c "import fastapi" 2>nul
if errorlevel 1 (
  echo Instalando dependencias...
  pip install -r requirements.txt geoalchemy2 email-validator
)

echo Iniciando AgroConecta Honduras en http://localhost:8000
echo Swagger UI: http://localhost:8000/docs
echo Deten con Ctrl+C
echo.

python -m uvicorn services.gateway.main:app --host 0.0.0.0 --port 8000 --reload

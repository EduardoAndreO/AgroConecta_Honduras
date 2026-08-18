#!/usr/bin/env bash
# Ejecuta el gateway en modo desarrollo (puerto 8000)
# Uso: bash scripts/run_dev.sh
set -e
cd "$(dirname "$0")/.."

# Activar entorno virtual si existe
if [ -d ".venv" ]; then
  # Linux/macOS
  if [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
  # Windows Git Bash
  elif [ -f ".venv/Scripts/activate" ]; then
    source .venv/Scripts/activate
  fi
fi

# Verificar .env
if [ ! -f ".env" ]; then
  echo "⚠ Archivo .env no encontrado. Copiando de .env.example..."
  cp .env.example .env
  echo "✓ .env creado. Edítalo con tu JWT_SECRET y DATABASE_URL reales."
fi

# Verificar dependencias críticas
if ! python -c "import fastapi" 2>/dev/null; then
  echo "⚠ Dependencias no instaladas. Ejecutando: pip install -r requirements.txt"
  pip install -r requirements.txt geoalchemy2 email-validator
fi

echo "→ Iniciando AgroConecta Honduras — http://localhost:8000"
echo "→ Swagger UI: http://localhost:8000/docs"
echo "→ Detén con Ctrl+C"
echo ""

exec python -m uvicorn services.gateway.main:app --host 0.0.0.0 --port 8000 --reload

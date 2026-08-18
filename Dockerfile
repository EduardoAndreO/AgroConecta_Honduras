# ============================================================
# Dockerfile para AgroConecta Honduras — Backend FastAPI
# Multi-stage: build ligero en producción
# ============================================================
FROM python:3.12-slim AS base

# Sistema: dependencias para psycopg2 y postgis
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev postgresql-client gdal-bin \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instalar dependencias primero (cache layer)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt geoalchemy2 email-validator

# Copiar código
COPY . .

# Variables por defecto (sobreescribir con -e o .env)
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    ENVIRONMENT=production \
    GATEWAY_PORT=8000

EXPOSE 8000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health').read()" || exit 1

# Comando por defecto
CMD ["uvicorn", "services.gateway.main:app", "--host", "0.0.0.0", "--port", "8000"]

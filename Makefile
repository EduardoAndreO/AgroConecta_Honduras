# ============================================================
# Makefile — comandos para levantar el proyecto
# ============================================================
.PHONY: install dev db-up db-reset db-test flutter clean help docker-up docker-down logs

help:
	@echo "AgroConecta Honduras — comandos disponibles:"
	@echo ""
	@echo "Setup inicial:"
	@echo "  make install    — Instala dependencias Python + Flutter"
	@echo "  make db-up      — Levanta PostgreSQL + PostGIS + Redis en Docker"
	@echo "  make db-reset   — Reinicia la BD y carga el schema completo"
	@echo ""
	@echo "Desarrollo:"
	@echo "  make dev        — Levanta el backend en http://localhost:8000"
	@echo "  make flutter    — Instala deps Flutter y corre la app"
	@echo "  make logs       — Ver logs de Docker en vivo"
	@echo ""
	@echo "Docker (todo en uno):"
	@echo "  make docker-up    — Levanta BD + Redis + Backend con docker compose"
	@echo "  make docker-down  — Detiene todos los contenedores"
	@echo ""
	@echo "Limpieza:"
	@echo "  make clean      — Limpia caches de Python y Flutter"

# === Setup ===
install:
	python -m venv .venv
	. .venv/bin/activate && pip install -r requirements.txt geoalchemy2 email-validator || \
	(.venv\\Scripts\\activate && pip install -r requirements.txt geoalchemy2 email-validator)
	cd apps/mobile && flutter pub get

db-up:
	docker compose up -d postgres redis
	@echo "Esperando a que PostgreSQL esté listo..."
	@sleep 3
	@echo "✓ PostgreSQL en localhost:5432 (user: agro, pass: agro123, db: agroconecta)"
	@echo "✓ Redis en localhost:6379"

db-reset:
	docker compose down -v
	docker compose up -d postgres redis
	@echo "Esperando 5 segundos a que PostgreSQL esté listo..."
	@sleep 5
	docker exec -i agro-postgres psql -U agro -d agroconecta < db/01_schema.sql
	@echo "✓ Base de datos lista con 8 tablas cargadas"

db-test:
	@echo "→ Verificando tablas en PostgreSQL..."
	@docker exec -it agro-postgres psql -U agro -d agroconecta -c "\\dt" || \
		echo "✗ PostgreSQL no responde. Ejecuta: make db-up"

# === Desarrollo ===
dev:
	bash scripts/run_dev.sh

flutter:
	cd apps/mobile && flutter pub get
	cd apps/mobile && flutter run

logs:
	docker compose logs -f

# === Docker completo ===
docker-up:
	docker compose up -d --build
	@echo "✓ Backend en http://localhost:8000"
	@echo "✓ Swagger UI en http://localhost:8000/docs"
	@echo "✓ PostgreSQL en localhost:5432"

docker-down:
	docker compose down

# === Limpieza ===
clean:
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	cd apps/mobile && flutter clean 2>/dev/null || true

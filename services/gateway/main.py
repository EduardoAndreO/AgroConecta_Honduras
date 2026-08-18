"""API Gateway — punto único de entrada con CORS y OpenAPI."""
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from shared.config import settings
from services.auth_service.main import router as auth_router
from services.marketplace_service.main import router as marketplace_router
from services.payments_service.main import router as payments_router
from services.notifications_service.main import router as notifications_router

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")
logger = logging.getLogger("gateway")


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("AgroConecta Honduras — Gateway iniciando en entorno: %s", settings.environment)
    yield
    logger.info("AgroConecta Honduras — Gateway cerrando")


app = FastAPI(
    title="AgroConecta Honduras — API Gateway",
    description="Marketplace móvil + IA para caficultores hondureños",
    version="0.2.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)

# CORS — orígenes del frontend
origins = [o.strip() for o in settings.cors_origins.split(",") if o.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers de los 4 microservicios
app.include_router(auth_router)
app.include_router(marketplace_router)
app.include_router(payments_router)
app.include_router(notifications_router)


@app.get("/health", tags=["meta"])
async def health() -> dict:
    """Healthcheck para Railway/Vercel."""
    return {
        "status": "ok",
        "service": "agroconecta-gateway",
        "version": "0.2.0",
        "environment": settings.environment,
    }


@app.get("/", tags=["meta"])
async def root() -> dict:
    return {
        "name": "AgroConecta Honduras API",
        "docs": "/docs",
        "health": "/health",
        "endpoints": ["/auth", "/marketplace", "/payments", "/notifications"],
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "services.gateway.main:app",
        host="0.0.0.0",
        port=settings.gateway_port,
        reload=settings.environment == "development",
    )

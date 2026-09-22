"""Configuración central — lee variables de entorno con Pydantic Settings."""
from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # PostgreSQL
    database_url: str = "postgresql+asyncpg://postgres.iscztdmnkrbtgtzxnnti:AgroConecta2026%21@aws-0-us-west-2.pooler.supabase.com:6543/postgres?ssl=require"

    # Redis
    redis_url: str = "redis://localhost:6379/0"

    # JWT
    jwt_secret: str = "agroconecta_desarrollo_secreto_no_usar_en_produccion_64_chars_minimo"
    jwt_algorithm: str = "HS256"
    jwt_access_ttl_minutes: int = 60
    jwt_refresh_ttl_days: int = 7

    # CORS
    cors_origins: str = "http://localhost:3000,http://localhost:8081,http://localhost:19006,http://localhost:5173,http://10.0.2.2:8000"

    # Puertos
    auth_service_port: int = 8001
    marketplace_service_port: int = 8002
    payments_service_port: int = 8003
    notifications_service_port: int = 8004
    gateway_port: int = 8000

    # Entorno
    environment: str = "development"
    log_level: str = "INFO"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore", case_sensitive=False)


@lru_cache()
def get_settings() -> Settings:
    return Settings()


settings = get_settings()

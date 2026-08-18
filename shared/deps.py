"""Dependencias compartidas de autenticación — usadas por todos los microservicios."""
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from shared.security import decode_token

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login", auto_error=False)


async def get_current_user_id(token: str | None = Depends(oauth2_scheme)) -> str:
    """Extrae el user_id del JWT. Lanza 401 si el token es inválido."""
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token de autenticación requerido",
            headers={"WWW-Authenticate": "Bearer"},
        )
    decoded = decode_token(token)
    if not decoded or decoded.get("type") != "access":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido o expirado",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return str(decoded["sub"])


async def get_current_user_id_optional(token: str | None = Depends(oauth2_scheme)) -> str | None:
    """Versión opcional — no lanza 401, devuelve None si no hay token."""
    if not token:
        return None
    decoded = decode_token(token)
    if not decoded or decoded.get("type") != "access":
        return None
    return str(decoded.get("sub"))

"""Auth Microservice — registro, login, refresh JWT, validación RTN hondureño."""
import re
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from shared.database import get_db
from shared.models import Productor, RolEnum
from shared.security import (
    create_access_token, create_refresh_token, decode_token,
    hash_password, verify_password,
)
from shared.deps import get_current_user_id

router = APIRouter(prefix="/auth", tags=["auth"])

# RTN hondureño: 14 dígitos
RTN_REGEX = re.compile(r"^\d{14}$")


class RegisterIn(BaseModel):
    nombre: str = Field(min_length=3, max_length=120)
    rtn: str = Field(min_length=14, max_length=14)
    email: EmailStr
    telefono: str = Field(min_length=8, max_length=20)
    password: str = Field(min_length=8, max_length=64)
    departamento: str = Field(min_length=2, max_length=40)
    rol: RolEnum = RolEnum.caficultor


class LoginIn(BaseModel):
    email: EmailStr
    password: str


class TokenOut(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user_id: str
    rol: RolEnum


class RefreshIn(BaseModel):
    refresh_token: str


class UserOut(BaseModel):
    id: str
    nombre: str
    rtn: str | None
    email: str
    telefono: str
    departamento: str
    rol: RolEnum
    creado: datetime

    class Config:
        from_attributes = True


@router.post("/register", response_model=TokenOut, status_code=status.HTTP_201_CREATED)
async def register(payload: RegisterIn, db: AsyncSession = Depends(get_db)) -> TokenOut:
    if not RTN_REGEX.match(payload.rtn):
        raise HTTPException(400, "RTN inválido: debe ser 14 dígitos")

    existing = await db.execute(select(Productor).where(Productor.email == payload.email))
    if existing.scalar_one_or_none():
        raise HTTPException(409, "Email ya registrado")

    existing_rtn = await db.execute(select(Productor).where(Productor.rtn == payload.rtn))
    if existing_rtn.scalar_one_or_none():
        raise HTTPException(409, "RTN ya registrado")

    p = Productor(
        nombre=payload.nombre,
        rtn=payload.rtn,
        email=payload.email,
        telefono=payload.telefono,
        password_hash=hash_password(payload.password),
        departamento=payload.departamento,
        rol=payload.rol,
    )
    db.add(p)
    await db.flush()

    token_data = {"sub": str(p.id), "rol": p.rol.value}
    return TokenOut(
        access_token=create_access_token(token_data),
        refresh_token=create_refresh_token(token_data),
        user_id=str(p.id),
        rol=p.rol,
    )


@router.post("/login", response_model=TokenOut)
async def login(payload: LoginIn, db: AsyncSession = Depends(get_db)) -> TokenOut:
    result = await db.execute(select(Productor).where(Productor.email == payload.email))
    p = result.scalar_one_or_none()
    if not p or not verify_password(payload.password, p.password_hash):
        raise HTTPException(401, "Email o contraseña incorrectos")
    if not p.activo:
        raise HTTPException(403, "Cuenta desactivada")

    token_data = {"sub": str(p.id), "rol": p.rol.value}
    return TokenOut(
        access_token=create_access_token(token_data),
        refresh_token=create_refresh_token(token_data),
        user_id=str(p.id),
        rol=p.rol,
    )


@router.post("/refresh", response_model=TokenOut)
async def refresh(payload: RefreshIn, db: AsyncSession = Depends(get_db)) -> TokenOut:
    decoded = decode_token(payload.refresh_token)
    if not decoded or decoded.get("type") != "refresh":
        raise HTTPException(401, "Refresh token inválido o expirado")

    user_id = decoded.get("sub")
    rol = decoded.get("rol")
    if not user_id or not rol:
        raise HTTPException(401, "Token malformado")

    token_data = {"sub": user_id, "rol": rol}
    return TokenOut(
        access_token=create_access_token(token_data),
        refresh_token=create_refresh_token(token_data),
        user_id=user_id,
        rol=RolEnum(rol),
    )


@router.get("/me", response_model=UserOut)
async def me(user_id: str = Depends(get_current_user_id), db: AsyncSession = Depends(get_db)) -> UserOut:
    result = await db.execute(select(Productor).where(Productor.id == user_id))
    p = result.scalar_one_or_none()
    if not p:
        raise HTTPException(404, "Usuario no encontrado")
    return UserOut(
        id=str(p.id), nombre=p.nombre, rtn=p.rtn, email=p.email,
        telefono=p.telefono, departamento=p.departamento, rol=p.rol, creado=p.creado,
    )

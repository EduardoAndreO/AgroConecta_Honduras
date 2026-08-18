"""Marketplace Microservice — publicaciones, ofertas (pedidos), búsqueda."""
from datetime import datetime
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from shared.database import get_db
from shared.models import (
    Publicacion, Pedido, Cosecha, LoteCafe, Finca, Productor,
    EstadoPublicacionEnum, EstadoPedidoEnum, CalidadEnum,
)
from shared.deps import get_current_user_id

router = APIRouter(prefix="/marketplace", tags=["marketplace"])


class PublicacionIn(BaseModel):
    cosecha_id: UUID
    titulo: str = Field(min_length=5, max_length=200)
    descripcion: str | None = None
    precio_hnl: float = Field(gt=0)
    sacos: int = Field(gt=0, le=1000)


class PublicacionOut(BaseModel):
    id: UUID
    cosecha_id: UUID
    vendedor_id: UUID
    vendedor_nombre: str
    titulo: str
    descripcion: str | None
    precio_hnl: float
    sacos: int
    estado: EstadoPublicacionEnum
    creado: datetime


class PedidoIn(BaseModel):
    publicacion_id: UUID
    cantidad: int = Field(gt=0)


class PedidoOut(BaseModel):
    id: UUID
    comprador_id: UUID
    vendedor_id: UUID
    publicacion_id: UUID
    cantidad: int
    total_hnl: float
    estado: EstadoPedidoEnum
    creado: datetime


@router.post("/publicaciones", response_model=PublicacionOut, status_code=status.HTTP_201_CREATED)
async def crear_publicacion(
    payload: PublicacionIn,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
) -> PublicacionOut:
    cosecha_result = await db.execute(
        select(Cosecha)
        .join(LoteCafe, Cosecha.lote_id == LoteCafe.id)
        .join(Finca, LoteCafe.finca_id == Finca.id)
        .where(Cosecha.id == payload.cosecha_id, Finca.productor_id == user_id)
    )
    cosecha = cosecha_result.scalar_one_or_none()
    if not cosecha:
        raise HTTPException(404, "Cosecha no encontrada o no pertenece al productor")

    pub = Publicacion(
        cosecha_id=payload.cosecha_id,
        vendedor_id=user_id,
        titulo=payload.titulo,
        descripcion=payload.descripcion,
        precio_hnl=payload.precio_hnl,
        sacos=payload.sacos,
    )
    db.add(pub)
    await db.flush()

    vendedor = (await db.execute(select(Productor).where(Productor.id == user_id))).scalar_one()
    return PublicacionOut(
        id=pub.id, cosecha_id=pub.cosecha_id, vendedor_id=pub.vendedor_id,
        vendedor_nombre=vendedor.nombre, titulo=pub.titulo, descripcion=pub.descripcion,
        precio_hnl=float(pub.precio_hnl), sacos=pub.sacos, estado=pub.estado, creado=pub.creado,
    )


@router.get("/publicaciones", response_model=list[PublicacionOut])
async def listar_publicaciones(
    calidad: CalidadEnum | None = None,
    limite: int = Query(default=50, le=200),
    db: AsyncSession = Depends(get_db),
) -> list[PublicacionOut]:
    stmt = (
        select(Publicacion, Productor)
        .join(Productor, Publicacion.vendedor_id == Productor.id)
        .where(Publicacion.estado == EstadoPublicacionEnum.activa)
        .order_by(Publicacion.creado.desc())
        .limit(limite)
    )
    result = await db.execute(stmt)
    rows = result.all()
    return [
        PublicacionOut(
            id=pub.id, cosecha_id=pub.cosecha_id, vendedor_id=pub.vendedor_id,
            vendedor_nombre=vendedor.nombre, titulo=pub.titulo, descripcion=pub.descripcion,
            precio_hnl=float(pub.precio_hnl), sacos=pub.sacos, estado=pub.estado, creado=pub.creado,
        )
        for pub, vendedor in rows
    ]


@router.get("/publicaciones/{pub_id}", response_model=PublicacionOut)
async def obtener_publicacion(pub_id: UUID, db: AsyncSession = Depends(get_db)) -> PublicacionOut:
    stmt = (
        select(Publicacion, Productor)
        .join(Productor, Publicacion.vendedor_id == Productor.id)
        .where(Publicacion.id == pub_id)
    )
    result = await db.execute(stmt)
    row = result.first()
    if not row:
        raise HTTPException(404, "Publicación no encontrada")
    pub, vendedor = row
    return PublicacionOut(
        id=pub.id, cosecha_id=pub.cosecha_id, vendedor_id=pub.vendedor_id,
        vendedor_nombre=vendedor.nombre, titulo=pub.titulo, descripcion=pub.descripcion,
        precio_hnl=float(pub.precio_hnl), sacos=pub.sacos, estado=pub.estado, creado=pub.creado,
    )


@router.get("/mis-publicaciones", response_model=list[PublicacionOut])
async def mis_publicaciones(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
) -> list[PublicacionOut]:
    stmt = (
        select(Publicacion, Productor)
        .join(Productor, Publicacion.vendedor_id == Productor.id)
        .where(Publicacion.vendedor_id == user_id)
        .order_by(Publicacion.creado.desc())
    )
    result = await db.execute(stmt)
    return [
        PublicacionOut(
            id=pub.id, cosecha_id=pub.cosecha_id, vendedor_id=pub.vendedor_id,
            vendedor_nombre=vendedor.nombre, titulo=pub.titulo, descripcion=pub.descripcion,
            precio_hnl=float(pub.precio_hnl), sacos=pub.sacos, estado=pub.estado, creado=pub.creado,
        )
        for pub, vendedor in result.all()
    ]


@router.post("/pedidos", response_model=PedidoOut, status_code=status.HTTP_201_CREATED)
async def crear_pedido(
    payload: PedidoIn,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
) -> PedidoOut:
    pub_result = await db.execute(select(Publicacion).where(Publicacion.id == payload.publicacion_id))
    pub = pub_result.scalar_one_or_none()
    if not pub or pub.estado != EstadoPublicacionEnum.activa:
        raise HTTPException(404, "Publicación no disponible")

    if pub.vendedor_id == user_id:
        raise HTTPException(400, "No puedes comprar tu propia publicación")

    if payload.cantidad > pub.sacos:
        raise HTTPException(400, f"Solo hay {pub.sacos} sacos disponibles")

    total = float(pub.precio_hnl) * payload.cantidad
    pedido = Pedido(
        comprador_id=user_id,
        vendedor_id=pub.vendedor_id,
        publicacion_id=pub.id,
        cantidad=payload.cantidad,
        total_hnl=total,
        estado=EstadoPedidoEnum.pendiente,
    )
    db.add(pedido)
    await db.flush()
    return PedidoOut(
        id=pedido.id, comprador_id=pedido.comprador_id, vendedor_id=pedido.vendedor_id,
        publicacion_id=pedido.publicacion_id, cantidad=pedido.cantidad,
        total_hnl=float(pedido.total_hnl), estado=pedido.estado, creado=pedido.creado,
    )


@router.get("/pedidos", response_model=list[PedidoOut])
async def mis_pedidos(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
) -> list[PedidoOut]:
    stmt = (
        select(Pedido)
        .where((Pedido.comprador_id == user_id) | (Pedido.vendedor_id == user_id))
        .order_by(Pedido.creado.desc())
    )
    result = await db.execute(stmt)
    return [
        PedidoOut(
            id=p.id, comprador_id=p.comprador_id, vendedor_id=p.vendedor_id,
            publicacion_id=p.publicacion_id, cantidad=p.cantidad,
            total_hnl=float(p.total_hnl), estado=p.estado, creado=p.creado,
        )
        for p in result.scalars().all()
    ]


@router.post("/pedidos/{pedido_id}/confirmar", response_model=PedidoOut)
async def confirmar_pedido(
    pedido_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
) -> PedidoOut:
    p_result = await db.execute(select(Pedido).where(Pedido.id == pedido_id))
    p = p_result.scalar_one_or_none()
    if not p:
        raise HTTPException(404, "Pedido no encontrado")
    if p.vendedor_id != user_id:
        raise HTTPException(403, "Solo el vendedor puede confirmar")
    if p.estado != EstadoPedidoEnum.pendiente:
        raise HTTPException(400, f"El pedido está en estado {p.estado.value}, no se puede confirmar")
    p.estado = EstadoPedidoEnum.confirmado
    await db.flush()
    return PedidoOut(
        id=p.id, comprador_id=p.comprador_id, vendedor_id=p.vendedor_id,
        publicacion_id=p.publicacion_id, cantidad=p.cantidad,
        total_hnl=float(p.total_hnl), estado=p.estado, creado=p.creado,
    )


@router.post("/pedidos/{pedido_id}/cancelar", response_model=PedidoOut)
async def cancelar_pedido(
    pedido_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
) -> PedidoOut:
    p_result = await db.execute(select(Pedido).where(Pedido.id == pedido_id))
    p = p_result.scalar_one_or_none()
    if not p:
        raise HTTPException(404, "Pedido no encontrado")
    if p.comprador_id != user_id and p.vendedor_id != user_id:
        raise HTTPException(403, "No autorizado")
    if p.estado in (EstadoPedidoEnum.entregado, EstadoPedidoEnum.cancelado):
        raise HTTPException(400, "Pedido ya cerrado")
    p.estado = EstadoPedidoEnum.cancelado
    await db.flush()
    return PedidoOut(
        id=p.id, comprador_id=p.comprador_id, vendedor_id=p.vendedor_id,
        publicacion_id=p.publicacion_id, cantidad=p.cantidad,
        total_hnl=float(p.total_hnl), estado=p.estado, creado=p.creado,
    )

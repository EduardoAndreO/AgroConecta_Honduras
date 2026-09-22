"""Payments Microservice — BAC, ACH, billetera QR (modo sandbox/mock)."""
import uuid as _uuid
from datetime import datetime
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from shared.database import get_db
from shared.models import Pago, Pedido, MetodoPagoEnum, EstadoPagoEnum, EstadoPedidoEnum
from shared.deps import get_current_user_id

router = APIRouter(prefix="/payments", tags=["payments"])


class PagoIn(BaseModel):
    pedido_id: UUID
    metodo: MetodoPagoEnum


class PagoOut(BaseModel):
    id: UUID
    pedido_id: UUID
    monto_hnl: float
    metodo: MetodoPagoEnum
    estado: EstadoPagoEnum
    referencia: str | None
    creado: datetime

    class Config:
        from_attributes = True


@router.post("/", response_model=PagoOut, status_code=status.HTTP_201_CREATED)
async def iniciar_pago(
    payload: PagoIn,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
) -> PagoOut:
    """Inicia el pago de un pedido. Modo sandbox: simula aprobación inmediata."""
    user_uuid = UUID(str(user_id)) if isinstance(user_id, str) else user_id
    p_result = await db.execute(select(Pedido).where(Pedido.id == payload.pedido_id))
    pedido = p_result.scalar_one_or_none()
    if not pedido:
        raise HTTPException(404, "Pedido no encontrado")
    if pedido.comprador_id != user_uuid:
        raise HTTPException(403, "Solo el comprador puede pagar este pedido")
    if pedido.estado not in (EstadoPedidoEnum.confirmado, EstadoPedidoEnum.pagando):
        raise HTTPException(400, f"El pedido debe estar confirmado, no {pedido.estado.value}")

    pedido.estado = EstadoPedidoEnum.pagando
    pago = Pago(
        pedido_id=pedido.id,
        monto_hnl=pedido.total_hnl,
        metodo=payload.metodo,
        estado=EstadoPagoEnum.pendiente,
    )
    db.add(pago)
    await db.flush()

    # Sandbox: simular aprobación inmediata del banco
    pago.estado = EstadoPagoEnum.aprobado
    pago.referencia = f"SANDBOX-{str(_uuid.uuid4())[:8].upper()}"
    pedido.estado = EstadoPedidoEnum.pagado

    await db.flush()
    return PagoOut(
        id=pago.id, pedido_id=pago.pedido_id, monto_hnl=float(pago.monto_hnl),
        metodo=pago.metodo, estado=pago.estado, referencia=pago.referencia, creado=pago.creado,
    )


@router.get("/{pago_id}", response_model=PagoOut)
async def obtener_pago(
    pago_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
) -> PagoOut:
    user_uuid = UUID(str(user_id)) if isinstance(user_id, str) else user_id
    stmt = (
        select(Pago)
        .join(Pedido, Pago.pedido_id == Pedido.id)
        .where(Pago.id == pago_id, (Pedido.comprador_id == user_uuid) | (Pedido.vendedor_id == user_uuid))
    )
    result = await db.execute(stmt)
    pago = result.scalar_one_or_none()
    if not pago:
        raise HTTPException(404, "Pago no encontrado")
    return PagoOut(
        id=pago.id, pedido_id=pago.pedido_id, monto_hnl=float(pago.monto_hnl),
        metodo=pago.metodo, estado=pago.estado, referencia=pago.referencia, creado=pago.creado,
    )


@router.get("/pedidos/{pedido_id}", response_model=PagoOut)
async def pago_por_pedido(
    pedido_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
) -> PagoOut:
    user_uuid = UUID(str(user_id)) if isinstance(user_id, str) else user_id
    stmt = (
        select(Pago)
        .join(Pedido, Pago.pedido_id == Pedido.id)
        .where(Pago.pedido_id == pedido_id, (Pedido.comprador_id == user_uuid) | (Pedido.vendedor_id == user_uuid))
    )
    result = await db.execute(stmt)
    pago = result.scalar_one_or_none()
    if not pago:
        raise HTTPException(404, "Este pedido no tiene pago asociado")
    return PagoOut(
        id=pago.id, pedido_id=pago.pedido_id, monto_hnl=float(pago.monto_hnl),
        metodo=pago.metodo, estado=pago.estado, referencia=pago.referencia, creado=pago.creado,
    )

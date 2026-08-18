"""Notifications Microservice — WhatsApp Business + Firebase FCM (modo mock MVP)."""
from datetime import datetime
from fastapi import APIRouter, Depends, status
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from shared.database import get_db
from shared.models import Pedido
from shared.deps import get_current_user_id

router = APIRouter(prefix="/notifications", tags=["notifications"])


class NotificacionOut(BaseModel):
    id: str
    tipo: str
    titulo: str
    cuerpo: str
    destinatario_id: str
    creado: datetime


@router.get("/", response_model=list[NotificacionOut])
async def listar_notificaciones(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
) -> list[NotificacionOut]:
    """Lista notificaciones derivadas de los pedidos del usuario."""
    stmt = (
        select(Pedido)
        .where((Pedido.comprador_id == user_id) | (Pedido.vendedor_id == user_id))
        .order_by(Pedido.creado.desc())
        .limit(20)
    )
    result = await db.execute(stmt)
    pedidos = result.scalars().all()

    notifs: list[NotificacionOut] = []
    for p in pedidos:
        if p.comprador_id == user_id:
            notifs.append(NotificacionOut(
                id=f"ped-{p.id}",
                tipo="pedido_comprador",
                titulo=f"Pedido {str(p.id)[:8]} — {p.estado.value}",
                cuerpo=f"Total: HNL {float(p.total_hnl):.2f} · {p.cantidad} saco(s)",
                destinatario_id=user_id,
                creado=p.creado,
            ))
        else:
            notifs.append(NotificacionOut(
                id=f"ped-{p.id}",
                tipo="pedido_vendedor",
                titulo=f"Nuevo pedido de {p.cantidad} saco(s) — {p.estado.value}",
                cuerpo=f"Total: HNL {float(p.total_hnl):.2f}",
                destinatario_id=user_id,
                creado=p.creado,
            ))
    return notifs


@router.post("/whatsapp/test", status_code=status.HTTP_200_OK)
async def test_whatsapp(numero: str, mensaje: str) -> dict:
    """Endpoint de prueba para WhatsApp Business API (mock)."""
    print(f"[MOCK WHATSAPP] → {numero}: {mensaje}")
    return {
        "status": "ok",
        "numero": numero,
        "mensaje_enviado": mensaje,
        "modo": "sandbox",
    }

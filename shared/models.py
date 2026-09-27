"""Modelos SQLAlchemy 2.0 — compartidos entre microservicios."""
from __future__ import annotations

import enum
import uuid
from datetime import datetime
from sqlalchemy import (
    String, Integer, Numeric, Boolean, DateTime, Text, ForeignKey, Enum, func
)
from sqlalchemy.dialects.postgresql import UUID, CITEXT, ENUM as PGEnum
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


# Intentar importar Geography de geoalchemy2 si está disponible, sino usar String como fallback
try:
    from geoalchemy2 import Geography  # type: ignore
    HAS_POSTGIS = True
except ImportError:
    Geography = None
    HAS_POSTGIS = False


class RolEnum(str, enum.Enum):
    caficultor = "caficultor"
    comprador = "comprador"
    admin_coop = "admin_coop"


class BeneficioEnum(str, enum.Enum):
    seco = "seco"
    humedo = "humedo"


class CalidadEnum(str, enum.Enum):
    estricto = "estricto"
    convencional = "convencional"


class EstadoPublicacionEnum(str, enum.Enum):
    activa = "activa"
    cerrada = "cerrada"
    cancelada = "cancelada"


class EstadoPedidoEnum(str, enum.Enum):
    pendiente = "pendiente"
    confirmado = "confirmado"
    pagando = "pagando"
    pagado = "pagado"
    preparando = "preparando"
    en_ruta = "en_ruta"
    entregado = "entregado"
    cancelado = "cancelado"


class MetodoPagoEnum(str, enum.Enum):
    bac = "bac"
    ach = "ach"
    efectivo = "efectivo"
    qr = "qr"


class EstadoPagoEnum(str, enum.Enum):
    pendiente = "pendiente"
    aprobado = "aprobado"
    rechazado = "rechazado"
    reembolsado = "reembolsado"


class EstadoEnvioEnum(str, enum.Enum):
    preparando = "preparando"
    en_ruta = "en_ruta"
    entregado = "entregado"
    devuelto = "devuelto"


class Base(DeclarativeBase):
    pass


def _geo_point():
    """Geography POINT si PostGIS está disponible, sino String fallback."""
    if HAS_POSTGIS:
        return Geography("POINT", srid=4326)
    return String(100)


def _geo_polygon():
    """Geography POLYGON si PostGIS está disponible, sino String fallback."""
    if HAS_POSTGIS:
        return Geography("POLYGON", srid=4326)
    return String(500)


class Productor(Base):
    __tablename__ = "productores"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nombre: Mapped[str] = mapped_column(String(120), nullable=False)
    rtn: Mapped[str | None] = mapped_column(String(15), unique=True)
    email: Mapped[str] = mapped_column(CITEXT, unique=True, nullable=False)
    telefono: Mapped[str] = mapped_column(String(20), nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    departamento: Mapped[str] = mapped_column(String(40), nullable=False)
    rol: Mapped[RolEnum] = mapped_column(Enum(RolEnum, name="rol_enum"), nullable=False, default=RolEnum.caficultor)
    # ubicacion: Mapped[object | None] = mapped_column(_geo_point())
    activo: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    creado: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    fincas: Mapped[list[Finca]] = relationship(back_populates="productor", cascade="all, delete-orphan")


class Finca(Base):
    __tablename__ = "fincas"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    productor_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("productores.id", ondelete="CASCADE"), nullable=False)
    nombre: Mapped[str] = mapped_column(String(120), nullable=False)
    geom: Mapped[object] = mapped_column(_geo_polygon(), nullable=False)
    manzanas: Mapped[float] = mapped_column(Numeric(6, 2), nullable=False)
    altitud_msnm: Mapped[int] = mapped_column(Integer, nullable=False)
    creado: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    productor: Mapped[Productor] = relationship(back_populates="fincas")
    lotes: Mapped[list[LoteCafe]] = relationship(back_populates="finca", cascade="all, delete-orphan")


class LoteCafe(Base):
    __tablename__ = "lotes_cafe"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    finca_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("fincas.id", ondelete="CASCADE"), nullable=False)
    variedad: Mapped[str] = mapped_column(String(60), nullable=False)
    siembra: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    tipo_beneficio: Mapped[BeneficioEnum] = mapped_column(
        PGEnum(BeneficioEnum, name="beneficio_enum", create_type=False), nullable=False
    )
    creado: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    finca: Mapped[Finca] = relationship(back_populates="lotes")
    cosechas: Mapped[list[Cosecha]] = relationship(back_populates="lote", cascade="all, delete-orphan")


class Cosecha(Base):
    __tablename__ = "cosechas"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    lote_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("lotes_cafe.id", ondelete="CASCADE"), nullable=False)
    quintales: Mapped[float] = mapped_column(Numeric(8, 2), nullable=False)
    fecha: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    calidad: Mapped[CalidadEnum] = mapped_column(
        PGEnum(CalidadEnum, name="calidad_enum", create_type=False), nullable=False
    )
    creado: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    lote: Mapped[LoteCafe] = relationship(back_populates="cosechas")
    publicaciones: Mapped[list[Publicacion]] = relationship(back_populates="cosecha", cascade="all, delete-orphan")


class Publicacion(Base):
    __tablename__ = "publicaciones"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    cosecha_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("cosechas.id", ondelete="CASCADE"), nullable=False)
    vendedor_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("productores.id", ondelete="CASCADE"), nullable=False)
    titulo: Mapped[str] = mapped_column(String(200), nullable=False)
    descripcion: Mapped[str | None] = mapped_column(Text)
    precio_hnl: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    sacos: Mapped[int] = mapped_column(Integer, nullable=False)
    estado: Mapped[EstadoPublicacionEnum] = mapped_column(
        PGEnum(EstadoPublicacionEnum, name="estado_publicacion_enum", create_type=False),
        default=EstadoPublicacionEnum.activa,
        nullable=False
    )
    creado: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    cosecha: Mapped[Cosecha] = relationship(back_populates="publicaciones")
    vendedor: Mapped[Productor] = relationship()
    pedidos: Mapped[list[Pedido]] = relationship(back_populates="publicacion", cascade="all, delete-orphan")


class Pedido(Base):
    __tablename__ = "pedidos"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    comprador_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("productores.id", ondelete="CASCADE"), nullable=False)
    vendedor_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("productores.id", ondelete="CASCADE"), nullable=False)
    publicacion_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("publicaciones.id", ondelete="CASCADE"), nullable=False)
    cantidad: Mapped[int] = mapped_column(Integer, nullable=False)
    total_hnl: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False)
    estado: Mapped[EstadoPedidoEnum] = mapped_column(
        PGEnum(EstadoPedidoEnum, name="estado_pedido_enum", create_type=False),
        default=EstadoPedidoEnum.pendiente,
        nullable=False,
    )
    creado: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    actualizado: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    publicacion: Mapped[Publicacion] = relationship(back_populates="pedidos")
    comprador: Mapped[Productor] = relationship(foreign_keys=[comprador_id])
    vendedor: Mapped[Productor] = relationship(foreign_keys=[vendedor_id])
    pago: Mapped[Pago | None] = relationship(back_populates="pedido", uselist=False, cascade="all, delete-orphan")
    envio: Mapped[Envio | None] = relationship(back_populates="pedido", uselist=False, cascade="all, delete-orphan")


class Pago(Base):
    __tablename__ = "pagos"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pedido_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("pedidos.id", ondelete="CASCADE"), nullable=False)
    monto_hnl: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False)
    metodo: Mapped[MetodoPagoEnum] = mapped_column(
        PGEnum(MetodoPagoEnum, name="metodo_pago_enum", create_type=False), nullable=False
    )
    estado: Mapped[EstadoPagoEnum] = mapped_column(
        PGEnum(EstadoPagoEnum, name="estado_pago_enum", create_type=False),
        default=EstadoPagoEnum.pendiente,
        nullable=False,
    )
    referencia: Mapped[str | None] = mapped_column(String(60))
    creado: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    pedido: Mapped[Pedido] = relationship(back_populates="pago")


class Envio(Base):
    __tablename__ = "envios"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pedido_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("pedidos.id", ondelete="CASCADE"), nullable=False)
    direccion: Mapped[str] = mapped_column(Text, nullable=False)
    estado: Mapped[EstadoEnvioEnum] = mapped_column(
        PGEnum(EstadoEnvioEnum, name="estado_envio_enum", create_type=False),
        default=EstadoEnvioEnum.preparando,
        nullable=False,
    )
    tracking_qr: Mapped[str | None] = mapped_column(String(40), unique=True)
    creado: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    pedido: Mapped[Pedido] = relationship(back_populates="envio")

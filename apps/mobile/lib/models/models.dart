// Modelos Dart — espejo de los schemas del backend
class Publicacion {
  final String id;
  final String cosechaId;
  final String vendedorId;
  final String vendedorNombre;
  final String titulo;
  final String? descripcion;
  final double precioHnl;
  final int sacos;
  final String estado;
  final DateTime creado;
  final String? imageUrl;

  Publicacion({
    required this.id,
    required this.cosechaId,
    required this.vendedorId,
    required this.vendedorNombre,
    required this.titulo,
    required this.descripcion,
    required this.precioHnl,
    required this.sacos,
    required this.estado,
    required this.creado,
    this.imageUrl,
  });

  factory Publicacion.fromJson(Map<String, dynamic> j) => Publicacion(
        id: j['id'] as String,
        cosechaId: j['cosecha_id'] as String,
        vendedorId: j['vendedor_id'] as String,
        vendedorNombre: j['vendedor_nombre'] as String,
        titulo: j['titulo'] as String,
        descripcion: j['descripcion'] as String?,
        precioHnl: (j['precio_hnl'] as num).toDouble(),
        sacos: j['sacos'] as int,
        estado: j['estado'] as String,
        creado: DateTime.parse(j['creado'] as String),
        imageUrl: j['image_url'] as String?,
      );
}

class Pedido {
  final String id;
  final String compradorId;
  final String vendedorId;
  final String publicacionId;
  final int cantidad;
  final double totalHnl;
  final String estado;
  final DateTime creado;

  Pedido({
    required this.id,
    required this.compradorId,
    required this.vendedorId,
    required this.publicacionId,
    required this.cantidad,
    required this.totalHnl,
    required this.estado,
    required this.creado,
  });

  factory Pedido.fromJson(Map<String, dynamic> j) => Pedido(
        id: j['id'] as String,
        compradorId: j['comprador_id'] as String,
        vendedorId: j['vendedor_id'] as String,
        publicacionId: j['publicacion_id'] as String,
        cantidad: j['cantidad'] as int,
        totalHnl: (j['total_hnl'] as num).toDouble(),
        estado: j['estado'] as String,
        creado: DateTime.parse(j['creado'] as String),
      );
}

class Pago {
  final String id;
  final String pedidoId;
  final double montoHnl;
  final String metodo;
  final String estado;
  final String? referencia;
  final DateTime creado;

  Pago({
    required this.id,
    required this.pedidoId,
    required this.montoHnl,
    required this.metodo,
    required this.estado,
    required this.referencia,
    required this.creado,
  });

  factory Pago.fromJson(Map<String, dynamic> j) => Pago(
        id: j['id'] as String,
        pedidoId: j['pedido_id'] as String,
        montoHnl: (j['monto_hnl'] as num).toDouble(),
        metodo: j['metodo'] as String,
        estado: j['estado'] as String,
        referencia: j['referencia'] as String?,
        creado: DateTime.parse(j['creado'] as String),
      );
}

class UserProfile {
  final String id;
  final String nombre;
  final String? rtn;
  final String email;
  final String telefono;
  final String departamento;
  final String rol;
  final DateTime creado;

  UserProfile({
    required this.id,
    required this.nombre,
    required this.rtn,
    required this.email,
    required this.telefono,
    required this.departamento,
    required this.rol,
    required this.creado,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        rtn: j['rtn'] as String?,
        email: j['email'] as String,
        telefono: j['telefono'] as String,
        departamento: j['departamento'] as String,
        rol: j['rol'] as String,
        creado: DateTime.parse(j['creado'] as String),
      );
}

class Notificacion {
  final String id;
  final String tipo;
  final String titulo;
  final String cuerpo;
  final String destinatarioId;
  final DateTime creado;

  Notificacion({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.cuerpo,
    required this.destinatarioId,
    required this.creado,
  });

  factory Notificacion.fromJson(Map<String, dynamic> j) => Notificacion(
        id: j['id'] as String,
        tipo: j['tipo'] as String,
        titulo: j['titulo'] as String,
        cuerpo: j['cuerpo'] as String,
        destinatarioId: j['destinatario_id'] as String,
        creado: DateTime.parse(j['creado'] as String),
      );
}

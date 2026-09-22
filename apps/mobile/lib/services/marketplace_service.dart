// ============================================================
// MarketplaceService — llama a /marketplace/*
// ============================================================
import 'api_service.dart';
import '../models/models.dart';

class MarketplaceService {
  final ApiService api;
  MarketplaceService(this.api);

  Future<List<Publicacion>> listar() async {
    final list = await api.get('/marketplace/publicaciones') as List;
    return list
        .map((j) => Publicacion.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<Publicacion>> misPublicaciones() async {
    final list = await api.get('/marketplace/mis-publicaciones') as List;
    return list
        .map((j) => Publicacion.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<Publicacion> crear({
    required String cosechaId,
    required String titulo,
    String? descripcion,
    required double precioHnl,
    required int sacos,
  }) async {
    final j = await api.post('/marketplace/publicaciones', body: {
      'cosecha_id': cosechaId,
      'titulo': titulo,
      'descripcion': descripcion,
      'precio_hnl': precioHnl,
      'sacos': sacos,
    });
    return Publicacion.fromJson(j as Map<String, dynamic>);
  }

  Future<Pedido> crearPedido(
      {required String publicacionId, required int cantidad}) async {
    final j = await api.post('/marketplace/pedidos', body: {
      'publicacion_id': publicacionId,
      'cantidad': cantidad,
    });
    return Pedido.fromJson(j as Map<String, dynamic>);
  }

  Future<List<Pedido>> misPedidos() async {
    final list = await api.get('/marketplace/pedidos') as List;
    return list.map((j) => Pedido.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Pedido> confirmarPedido(String id) async {
    final j = await api.post('/marketplace/pedidos/$id/confirmar');
    return Pedido.fromJson(j as Map<String, dynamic>);
  }

  Future<Pedido> cancelarPedido(String id) async {
    final j = await api.post('/marketplace/pedidos/$id/cancelar');
    return Pedido.fromJson(j as Map<String, dynamic>);
  }
}

class PaymentsService {
  final ApiService api;
  PaymentsService(this.api);

  Future<Pago> iniciar(
      {required String pedidoId, required String metodo}) async {
    final j = await api.post('/payments/', body: {
      'pedido_id': pedidoId,
      'metodo': metodo,
    });
    return Pago.fromJson(j as Map<String, dynamic>);
  }

  Future<Pago?> pagoDePedido(String pedidoId) async {
    try {
      final j = await api.get('/payments/pedidos/$pedidoId');
      return Pago.fromJson(j as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

class NotificationsService {
  final ApiService api;
  NotificationsService(this.api);

  Future<List<Notificacion>> listar() async {
    final list = await api.get('/notifications/') as List;
    return list
        .map((j) => Notificacion.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}

class UserService {
  final ApiService api;
  UserService(this.api);

  Future<UserProfile> me() async {
    final j = await api.get('/auth/me');
    return UserProfile.fromJson(j as Map<String, dynamic>);
  }

  Future<UserProfile> update({
    required String nombre,
    required String telefono,
    required String departamento,
  }) async {
    final j = await api.put('/auth/me', body: {
      'nombre': nombre,
      'telefono': telefono,
      'departamento': departamento,
    });
    return UserProfile.fromJson(j as Map<String, dynamic>);
  }
}

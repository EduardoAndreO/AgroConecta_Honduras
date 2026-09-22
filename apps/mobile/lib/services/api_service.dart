// ============================================================
// ApiService — cliente HTTP central con JWT + auto-refresh
// ============================================================
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Callback que el AuthService registra para que ApiService pueda
/// intentar renovar el access_token cuando recibe un 401.
typedef TokenRefresher = Future<String?> Function();

/// Callback que el AuthService registra para hacer logout cuando
/// el refresh también falla (token expirado o inválido).
typedef OnUnauthenticated = Future<void> Function();

class ApiService {
  final String baseUrl;
  String? _token;
  String? _refreshToken;

  /// Registrar estos callbacks desde AuthService tras construirlo.
  TokenRefresher? onRefreshToken;
  OnUnauthenticated? onUnauthenticated;

  ApiService({required this.baseUrl});

  String? get token => _token;
  void setToken(String? tok) => _token = tok;
  void setRefreshToken(String? tok) => _refreshToken = tok;
  String? get refreshToken => _refreshToken;

  Map<String, String> _headers({Map<String, String>? extra}) {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) h['Authorization'] = 'Bearer $_token';
    if (extra != null) h.addAll(extra);
    return h;
  }

  Future<dynamic> get(String path) async {
    return _withAutoRefresh(() async {
      final r = await http.get(Uri.parse('$baseUrl$path'), headers: _headers());
      return _parse(r);
    });
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    return _withAutoRefresh(() async {
      final r = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _parse(r);
    });
  }

  /// POST directo sin auto-refresh — usado internamente para el endpoint /auth/refresh
  /// para evitar recursión infinita.
  Future<dynamic> rawPost(String path, {Map<String, dynamic>? body}) async {
    final r = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _parse(r);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    return _withAutoRefresh(() async {
      final r = await http.put(
        Uri.parse('$baseUrl$path'),
        headers: _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _parse(r);
    });
  }

  /// Ejecuta [call]. Si lanza 401 y tenemos refresh token, intenta renovar
  /// el access_token y reintenta la llamada una sola vez.
  Future<dynamic> _withAutoRefresh(Future<dynamic> Function() call) async {
    try {
      return await call();
    } on ApiException catch (e) {
      if (e.statusCode != 401) rethrow;

      // Intentar renovar el token
      final newToken = onRefreshToken != null ? await onRefreshToken!() : null;
      if (newToken == null) {
        // Refresh falló → forzar logout
        if (onUnauthenticated != null) await onUnauthenticated!();
        rethrow;
      }

      // Reintentar con el nuevo token ya seteado (onRefreshToken lo setea)
      try {
        return await call();
      } catch (_) {
        // Si vuelve a fallar, forzar logout
        if (onUnauthenticated != null) await onUnauthenticated!();
        rethrow;
      }
    }
  }

  dynamic _parse(http.Response r) {
    final ct = r.headers['content-type'] ?? '';
    dynamic body;
    try {
      body = ct.contains('json') ? jsonDecode(r.body) : r.body;
    } catch (_) {
      body = r.body;
    }
    if (r.statusCode >= 200 && r.statusCode < 300) return body;
    String msg = 'Error desconocido';
    if (body is Map && body['detail'] != null) {
      msg = body['detail'].toString();
    } else if (body is String && body.isNotEmpty) {
      msg = body;
    }
    throw ApiException(r.statusCode, msg);
  }
}
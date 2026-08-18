// ============================================================
// ApiService — cliente HTTP central con JWT
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

class ApiService {
  final String baseUrl;
  String? _token;

  ApiService({required this.baseUrl});

  String? get token => _token;
  void setToken(String? tok) => _token = tok;

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
    final r = await http.get(Uri.parse('$baseUrl$path'), headers: _headers());
    return _parse(r);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final r = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _parse(r);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final r = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _parse(r);
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

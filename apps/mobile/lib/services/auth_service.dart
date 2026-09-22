// ============================================================
// AuthService — login, registro, refresh automático, persistencia
// ============================================================
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthState {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String rol;
  AuthState({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.rol,
  });

  factory AuthState.fromJson(Map<String, dynamic> j) => AuthState(
        accessToken: j['access_token'] as String,
        refreshToken: j['refresh_token'] as String,
        userId: j['user_id'] as String,
        rol: j['rol'] as String,
      );
}

class AuthService extends ChangeNotifier {
  final SharedPreferences prefs;
  final ApiService api;
  AuthState? _state;
  String? _error;
  bool _loading = false;

  AuthService({required this.prefs, required this.api}) {
    final tok = prefs.getString('access_token');
    final rTok = prefs.getString('refresh_token');
    final uid = prefs.getString('user_id');
    final rol = prefs.getString('rol');
    if (tok != null && rTok != null && uid != null && rol != null) {
      _state = AuthState(accessToken: tok, refreshToken: rTok, userId: uid, rol: rol);
      api.setToken(tok);
      api.setRefreshToken(rTok);
    }

    // Registrar callbacks para auto-refresh en ApiService
    api.onRefreshToken = _doRefresh;
    api.onUnauthenticated = _forceLogout;
  }

  bool get isAuthenticated => _state != null;
  bool get isLoading => _loading;
  String? get rol => _state?.rol;
  String? get userId => _state?.userId;
  String? get error => _error;

  Future<bool> login({required String email, required String password}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final j = await api.post('/auth/login', body: {
        'email': email,
        'password': password,
      });
      _persist(AuthState.fromJson(j as Map<String, dynamic>));
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error de conexión: $e';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String nombre,
    required String rtn,
    required String email,
    required String telefono,
    required String password,
    required String departamento,
    String rol = 'caficultor',
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final j = await api.post('/auth/register', body: {
        'nombre': nombre,
        'rtn': rtn,
        'email': email,
        'telefono': telefono,
        'password': password,
        'departamento': departamento,
        'rol': rol,
      });
      _persist(AuthState.fromJson(j as Map<String, dynamic>));
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error de conexión: $e';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _clearSession();
    notifyListeners();
  }

  // ── Internos ────────────────────────────────────────────────

  /// Intenta renovar el access_token usando el refresh_token.
  /// Retorna el nuevo access_token, o null si falló.
  Future<String?> _doRefresh() async {
    final rTok = _state?.refreshToken ?? api.refreshToken;
    if (rTok == null) return null;
    try {
      // rawPost evita pasar por _withAutoRefresh y previene recursión infinita
      final r = await api.rawPost('/auth/refresh', body: {'refresh_token': rTok});
      final newState = AuthState.fromJson(r as Map<String, dynamic>);
      _persist(newState);
      notifyListeners();
      return newState.accessToken;
    } catch (_) {
      return null;
    }
  }

  /// Llamado por ApiService cuando el refresh también falla.
  Future<void> _forceLogout() async {
    await _clearSession();
    notifyListeners();
  }

  Future<void> _clearSession() async {
    _state = null;
    api.setToken(null);
    api.setRefreshToken(null);
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');
    await prefs.remove('rol');
  }

  void _persist(AuthState s) {
    _state = s;
    api.setToken(s.accessToken);
    api.setRefreshToken(s.refreshToken);
    prefs.setString('access_token', s.accessToken);
    prefs.setString('refresh_token', s.refreshToken);
    prefs.setString('user_id', s.userId);
    prefs.setString('rol', s.rol);
  }
}

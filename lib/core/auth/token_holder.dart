import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Armazena o token JWT de forma segura e persistente.
/// Mantém cache em memória para leituras síncronas durante a sessão.
class TokenHolder {
  TokenHolder._();

  static const _storage = FlutterSecureStorage();
  static const _key = 'jwt_access_token';
  static String? _cachedToken;

  /// Deve ser chamado uma vez no startup (antes de exibir qualquer tela).
  static Future<void> initialize() async {
    try {
      _cachedToken = await _storage.read(key: _key);
    } catch (_) {
      _cachedToken = null;
    }
  }

  /// Persiste o token no SecureStorage e atualiza o cache.
  static Future<void> setToken(String token) async {
    try {
      await _storage.write(key: _key, value: token);
      _cachedToken = token;
    } catch (_) {
      _cachedToken = token;
    }
  }

  /// Leitura síncrona do cache (disponível após [initialize]).
  static String? get accessToken => _cachedToken;

  /// Remove o token do storage e limpa o cache.
  static Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } catch (_) {}
    _cachedToken = null;
  }
}

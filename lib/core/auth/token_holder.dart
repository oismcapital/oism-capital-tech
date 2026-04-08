/// Guarda o token em memória para o [Dio] anexar em `Authorization`.
///
/// Em produção, prefira `flutter_secure_storage` ou solução equivalente.
class TokenHolder {
  TokenHolder._();

  static String? accessToken;

  static void clear() => accessToken = null;
}

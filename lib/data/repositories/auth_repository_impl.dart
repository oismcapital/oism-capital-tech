import '../../core/auth/token_holder.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._authService);

  final AuthService _authService;

  UserSession? _session;

  @override
  Future<UserSession> login({
    required String email,
    required String password,
  }) async {
    final dto = await _authService.login(email: email, password: password);
    final session = UserSession(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      userId: dto.userId,
    );
    _session = session;
    TokenHolder.accessToken = session.accessToken;
    return session;
  }

  @override
  Future<void> logout() async {
    try {
      await _authService.logout(refreshToken: _session?.refreshToken);
    } catch (_) {
      // Limpa sessão local mesmo se o backend falhar.
    }
    _session = null;
    TokenHolder.clear();
  }

  @override
  Future<UserSession?> currentSession() async => _session;
}

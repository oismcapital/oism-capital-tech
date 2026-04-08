import '../entities/user_session.dart';

abstract class AuthRepository {
  Future<UserSession> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserSession?> currentSession();
}

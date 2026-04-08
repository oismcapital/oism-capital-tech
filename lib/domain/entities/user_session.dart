class UserSession {
  const UserSession({
    required this.accessToken,
    this.refreshToken,
    this.userId,
  });

  final String accessToken;
  final String? refreshToken;
  final String? userId;
}

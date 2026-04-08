class LoginResponseDto {
  LoginResponseDto({
    required this.accessToken,
    this.refreshToken,
    this.userId,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      accessToken: json['accessToken'] as String? ??
          json['token'] as String? ??
          json['access_token'] as String? ??
          '',
      refreshToken: json['refreshToken'] as String? ?? json['refresh_token'] as String?,
      userId: json['userId']?.toString() ?? json['id']?.toString(),
    );
  }

  final String accessToken;
  final String? refreshToken;
  final String? userId;
}

import 'package:dio/dio.dart';

import '../models/login_response_dto.dart';

/// Cliente HTTP para autenticação na API Spring Boot.
///
/// Ajuste os paths conforme seus `@RequestMapping` / `@PostMapping`.
class AuthService {
  AuthService(this._dio);

  final Dio _dio;

  /// Ex.: `POST /api/auth/login` com body JSON `{ "email", "password" }`.
  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Resposta vazia do servidor',
      );
    }
    return LoginResponseDto.fromJson(data);
  }

  /// Ex.: `POST /api/auth/logout` (opcional: envia refresh token no body).
  Future<void> logout({String? refreshToken}) async {
    await _dio.post<void>(
      '/api/auth/logout',
      data: refreshToken != null ? {'refreshToken': refreshToken} : null,
    );
  }
}

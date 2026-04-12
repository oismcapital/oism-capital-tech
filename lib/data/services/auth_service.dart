import 'package:dio/dio.dart';

import '../models/login_response_dto.dart';

class AuthService {
  AuthService(this._dio);

  final Dio _dio;

  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'email': email, 'senha': password},
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

  Future<LoginResponseDto> register({
    required String nome,
    required String email,
    required String senha,
  }) async {
    await _dio.post<void>(
      '/api/auth/register',
      data: {'nome': nome, 'email': email, 'senha': senha, 'saldo': 0},
    );
    return login(email: email, password: senha);
  }

  Future<void> logout() async {
    // Logout é local — apenas limpa o token
  }
}

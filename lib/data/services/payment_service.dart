import 'package:dio/dio.dart';

import '../models/generate_pix_response_dto.dart';
import '../models/plan_dto.dart';

class PaymentService {
  PaymentService(this._dio);

  final Dio _dio;

  Future<List<PlanDto>> getPlans() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/payments/plans');
    final data = response.data;
    if (data == null) return [];
    return data
        .cast<Map<String, dynamic>>()
        .map(PlanDto.fromJson)
        .toList();
  }

  Future<GeneratePixResponseDto> generatePix(String planId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/payments/generate-pix',
      data: {'planId': planId},
    );
    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Resposta vazia ao gerar cobrança Pix',
      );
    }
    return GeneratePixResponseDto.fromJson(data);
  }

  Future<String> getDepositStatus(String transactionId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/payments/$transactionId/status',
    );
    return response.data?['status'] as String? ?? 'PENDING';
  }
}

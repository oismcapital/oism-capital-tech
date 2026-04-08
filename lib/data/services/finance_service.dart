import 'package:dio/dio.dart';

import '../models/finance_summary_dto.dart';

/// Cliente HTTP para dados financeiros na API Spring Boot.
///
/// Ajuste o path conforme seu controller (ex.: `@GetMapping("/api/finance/summary")`).
class FinanceService {
  FinanceService(this._dio);

  final Dio _dio;

  /// Ex.: `GET /api/finance/summary`
  Future<FinanceSummaryDto> getSummary() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/finance/summary');
    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Resposta vazia do servidor',
      );
    }
    return FinanceSummaryDto.fromJson(data);
  }
}

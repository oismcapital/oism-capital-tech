import 'package:dio/dio.dart';

import '../models/finance_summary_dto.dart';

class FinanceService {
  FinanceService(this._dio);

  final Dio _dio;

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

  Future<void> updatePreferences({required bool valorEscondido}) async {
    await _dio.patch<void>(
      '/api/wallet/preferences',
      data: {'valorEscondido': valorEscondido},
    );
  }
}

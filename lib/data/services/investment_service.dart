import 'package:dio/dio.dart';

import '../models/investment_dto.dart';

class InvestmentService {
  InvestmentService(this._dio);

  final Dio _dio;

  Future<InvestmentDto> purchase(String planId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/investments',
      data: {'planId': planId},
    );
    return InvestmentDto.fromJson(res.data!);
  }

  Future<List<InvestmentDto>> listAll() async {
    final res = await _dio.get<List<dynamic>>('/api/v1/investments');
    return (res.data ?? [])
        .map((e) => InvestmentDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<InvestmentDto>> listActive() async {
    final res = await _dio.get<List<dynamic>>('/api/v1/investments/active');
    return (res.data ?? [])
        .map((e) => InvestmentDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<InvestmentDto> withdrawInterest(int investmentId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/investments/$investmentId/withdraw-interest',
    );
    return InvestmentDto.fromJson(res.data!);
  }
}

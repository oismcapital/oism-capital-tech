import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../data/models/deposit_pix_dto.dart';

class DepositNotifier extends ChangeNotifier {
  DepositNotifier(this._dio);

  final Dio _dio;

  bool _loading = false;
  DepositPixDto? _deposit;
  String? _errorMessage;

  bool get loading => _loading;
  DepositPixDto? get deposit => _deposit;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  Future<void> generatePix(double amount) async {
    _loading = true;
    _deposit = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/payments/deposit-pix',
        data: {'valor': amount},
      );
      _deposit = DepositPixDto.fromJson(res.data!);
    } on DioException catch (e) {
      final data = e.response?.data;
      _errorMessage = (data is Map && data['error'] != null)
          ? data['error'].toString()
          : 'Erro ao gerar PIX. Tente novamente.';
    } catch (_) {
      _errorMessage = 'Erro inesperado. Tente novamente.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void reset() {
    _deposit = null;
    _errorMessage = null;
    _loading = false;
    notifyListeners();
  }
}

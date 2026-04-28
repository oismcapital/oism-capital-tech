import 'package:dio/dio.dart';
import '../models/wallet_transaction_dto.dart';

class StatementService {
  StatementService(this._dio);

  final Dio _dio;

  Future<List<WalletTransactionDto>> getStatement({
    required DateTime from,
    required DateTime to,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/wallet/statement/filter',
      queryParameters: {
        'from': '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}',
        'to': '${to.year}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')}',
      },
    );
    return (res.data ?? [])
        .map((e) => WalletTransactionDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

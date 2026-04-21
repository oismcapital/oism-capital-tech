import '../../domain/entities/finance_summary.dart';
import '../../domain/repositories/finance_repository.dart';
import '../models/finance_summary_dto.dart';
import '../services/finance_service.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  FinanceRepositoryImpl(this._financeService);

  final FinanceService _financeService;

  @override
  Future<FinanceSummary> getSummary() async {
    final dto = await _financeService.getSummary();
    return _map(dto);
  }

  FinanceSummary _map(FinanceSummaryDto dto) {
    var points = dto.performancePoints;
    if (points == null || points.isEmpty) {
      points = _defaultAscendingCurve();
    }
    return FinanceSummary(
      walletBalance: dto.walletBalance,
      totalInvested: dto.totalInvested,
      totalAccruedInterest: dto.totalAccruedInterest,
      dailyProfit: dto.dailyProfit,
      performancePoints: points,
      valorEscondido: dto.valorEscondido,
    );
  }

  static List<double> _defaultAscendingCurve() {
    return List<double>.generate(12, (i) => 100 + i * 18 + (i * i).toDouble() * 0.4);
  }
}

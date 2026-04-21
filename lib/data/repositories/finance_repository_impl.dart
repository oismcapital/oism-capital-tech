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
    return FinanceSummary(
      walletBalance: dto.walletBalance,
      totalInvested: dto.totalInvested,
      totalAccruedInterest: dto.totalAccruedInterest,
      dailyProfit: dto.dailyProfit,
      performancePoints: dto.performancePoints ?? [],
      valorEscondido: dto.valorEscondido,
    );
  }
}

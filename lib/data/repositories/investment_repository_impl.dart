import '../../domain/entities/investment.dart';
import '../../domain/repositories/investment_repository.dart';
import '../services/investment_service.dart';

class InvestmentRepositoryImpl implements InvestmentRepository {
  InvestmentRepositoryImpl(this._service);

  final InvestmentService _service;

  @override
  Future<Investment> purchase(String planId) async {
    final dto = await _service.purchase(planId);
    return dto.toEntity();
  }

  @override
  Future<List<Investment>> listAll() async {
    final dtos = await _service.listAll();
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<List<Investment>> listActive() async {
    final dtos = await _service.listActive();
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<Investment> withdrawInterest(int investmentId) async {
    final dto = await _service.withdrawInterest(investmentId);
    return dto.toEntity();
  }
}

import '../../domain/entities/pix_deposit.dart';
import '../../domain/entities/plan.dart';
import '../../domain/repositories/payment_repository.dart';
import '../services/payment_service.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._service);

  final PaymentService _service;

  @override
  Future<List<Plan>> getPlans() async {
    final dtos = await _service.getPlans();
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<PixDeposit> generatePix(String planId) async {
    final dto = await _service.generatePix(planId);
    return dto.toEntity();
  }

  @override
  Future<String> getDepositStatus(String transactionId) =>
      _service.getDepositStatus(transactionId);
}

import '../entities/plan.dart';
import '../entities/pix_deposit.dart';

/// Interface do repositório de pagamentos.
/// Troque a implementação sem tocar em nada acima desta camada.
abstract class PaymentRepository {
  Future<List<Plan>> getPlans();
  Future<PixDeposit> generatePix(String planId);
  Future<String> getDepositStatus(String transactionId);
}

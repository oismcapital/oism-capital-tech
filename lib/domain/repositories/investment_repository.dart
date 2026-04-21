import '../entities/investment.dart';

abstract class InvestmentRepository {
  Future<Investment> purchase(String planId);
  Future<List<Investment>> listAll();
  Future<List<Investment>> listActive();
  Future<Investment> withdrawInterest(int investmentId);
}

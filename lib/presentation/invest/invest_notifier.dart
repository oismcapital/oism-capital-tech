import 'package:flutter/foundation.dart';

import '../../domain/entities/investment.dart';
import '../../domain/repositories/investment_repository.dart';

class InvestNotifier extends ChangeNotifier {
  InvestNotifier(this._repository);

  final InvestmentRepository _repository;

  List<Investment> _investments = [];
  bool _loading = false;
  String? _error;

  List<Investment> get investments => _investments;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _investments = await _repository.listActive();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Retorna null em caso de sucesso, ou a mensagem de erro.
  Future<String?> withdrawInterest(int investmentId) async {
    try {
      final updated = await _repository.withdrawInterest(investmentId);
      final idx = _investments.indexWhere((i) => i.id == investmentId);
      if (idx >= 0) {
        _investments[idx] = updated;
        notifyListeners();
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Contrata um plano debitando do saldo. Retorna null em sucesso ou mensagem de erro.
  Future<String?> purchase(String planId) async {
    try {
      await _repository.purchase(planId);
      await load(); // recarrega lista de investimentos ativos
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

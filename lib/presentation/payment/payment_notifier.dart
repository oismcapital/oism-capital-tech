import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/pix_deposit.dart';
import '../../domain/entities/plan.dart';
import '../../domain/repositories/payment_repository.dart';

enum PaymentStatus { idle, loadingPlans, generatingPix, awaitingConfirmation, confirmed, expired, error }

class PaymentNotifier extends ChangeNotifier {
  PaymentNotifier(this._repository);

  final PaymentRepository _repository;

  PaymentStatus _status = PaymentStatus.idle;
  List<Plan> _plans = [];
  PixDeposit? _deposit;
  String? _errorMessage;
  Timer? _pollingTimer;

  static const _pollInterval = Duration(seconds: 5);

  PaymentStatus get status => _status;
  List<Plan> get plans => _plans;
  PixDeposit? get deposit => _deposit;
  String? get errorMessage => _errorMessage;

  Future<void> loadPlans() async {
    _setStatus(PaymentStatus.loadingPlans);
    try {
      _plans = await _repository.getPlans();
      _setStatus(PaymentStatus.idle);
    } on DioException catch (e) {
      _setError(_parseDioError(e));
    } catch (e) {
      _setError('Erro ao carregar planos. Tente novamente.');
    }
  }

  Future<void> generatePix(String planId) async {
    _setStatus(PaymentStatus.generatingPix);
    _deposit = null;
    try {
      _deposit = await _repository.generatePix(planId);
      _setStatus(PaymentStatus.awaitingConfirmation);
      _startPolling(_deposit!.transactionId);
    } on DioException catch (e) {
      _setError(_parseDioError(e));
    } catch (e) {
      _setError('Falha ao gerar cobrança Pix. Tente novamente.');
    }
  }

  void _startPolling(String transactionId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollInterval, (_) async {
      try {
        final statusStr = await _repository.getDepositStatus(transactionId);
        if (statusStr == 'COMPLETED') {
          _pollingTimer?.cancel();
          _setStatus(PaymentStatus.confirmed);
        } else if (statusStr == 'EXPIRED') {
          _pollingTimer?.cancel();
          _setStatus(PaymentStatus.expired);
        }
      } catch (_) {
        // Silencia erros de polling — não interrompe a UX
      }
    });
  }

  void reset() {
    _pollingTimer?.cancel();
    _deposit = null;
    _errorMessage = null;
    _setStatus(PaymentStatus.idle);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _setStatus(PaymentStatus s) {
    _status = s;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setStatus(PaymentStatus.error);
  }

  String _parseDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] != null) {
      return data['error'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Tempo de conexão esgotado. Verifique sua internet.';
    }
    return e.message ?? 'Erro de comunicação com o servidor.';
  }
}

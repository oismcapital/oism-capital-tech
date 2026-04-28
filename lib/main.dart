import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/network/dio_client.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/finance_repository_impl.dart';
import 'data/repositories/investment_repository_impl.dart';
import 'data/repositories/payment_repository_impl.dart';
import 'data/services/auth_service.dart';
import 'data/services/finance_service.dart';
import 'data/services/investment_service.dart';
import 'data/services/payment_service.dart';
import 'data/services/statement_service.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/finance_repository.dart';
import 'domain/repositories/investment_repository.dart';
import 'domain/repositories/payment_repository.dart';
import 'presentation/invest/invest_notifier.dart';
import 'presentation/payment/payment_notifier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final dio = DioClient.create();

  runApp(
    MultiProvider(
      providers: [
        Provider<Dio>.value(value: dio),
        Provider<AuthService>(create: (_) => AuthService(dio)),
        Provider<FinanceService>(create: (_) => FinanceService(dio)),
        Provider<PaymentService>(create: (_) => PaymentService(dio)),
        Provider<InvestmentService>(create: (_) => InvestmentService(dio)),
        Provider<StatementService>(create: (_) => StatementService(dio)),
        Provider<AuthRepository>(
          create: (c) => AuthRepositoryImpl(c.read<AuthService>()),
        ),
        Provider<FinanceRepository>(
          create: (c) => FinanceRepositoryImpl(c.read<FinanceService>()),
        ),
        Provider<PaymentRepository>(
          create: (c) => PaymentRepositoryImpl(c.read<PaymentService>()),
        ),
        Provider<InvestmentRepository>(
          create: (c) => InvestmentRepositoryImpl(c.read<InvestmentService>()),
        ),
        ChangeNotifierProvider<PaymentNotifier>(
          create: (c) => PaymentNotifier(c.read<PaymentRepository>()),
        ),
        ChangeNotifierProvider<InvestNotifier>(
          create: (c) => InvestNotifier(c.read<InvestmentRepository>()),
        ),
      ],
      child: const OismApp(),
    ),
  );
}

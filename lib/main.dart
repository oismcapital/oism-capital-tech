import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/network/dio_client.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/finance_repository_impl.dart';
import 'data/services/auth_service.dart';
import 'data/services/finance_service.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/finance_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final dio = DioClient.create();

  runApp(
    MultiProvider(
      providers: [
        Provider<Dio>.value(value: dio),
        Provider<AuthService>(create: (_) => AuthService(dio)),
        Provider<FinanceService>(create: (_) => FinanceService(dio)),
        Provider<AuthRepository>(
          create: (c) => AuthRepositoryImpl(c.read<AuthService>()),
        ),
        Provider<FinanceRepository>(
          create: (c) => FinanceRepositoryImpl(c.read<FinanceService>()),
        ),
      ],
      child: const OismApp(),
    ),
  );
}

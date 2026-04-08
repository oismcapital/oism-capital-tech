import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:oism_capital_tech/app.dart';
import 'package:oism_capital_tech/domain/entities/finance_summary.dart';
import 'package:oism_capital_tech/domain/entities/user_session.dart';
import 'package:oism_capital_tech/domain/repositories/auth_repository.dart';
import 'package:oism_capital_tech/domain/repositories/finance_repository.dart';

class _FakeFinanceRepository implements FinanceRepository {
  @override
  Future<FinanceSummary> getSummary() async {
    return FinanceSummary(
      investedBalance: 1000,
      dailyProfit: 42,
      performancePoints: List<double>.generate(8, (i) => 10 + i * 3),
    );
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<UserSession> login({required String email, required String password}) async {
    return const UserSession(accessToken: 'test');
  }

  @override
  Future<UserSession?> currentSession() async => null;

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('Carrega a Home com o cabeçalho OISM', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<FinanceRepository>(create: (_) => _FakeFinanceRepository()),
          Provider<AuthRepository>(create: (_) => _FakeAuthRepository()),
        ],
        child: const OismApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('OISM Capital Tech'), findsOneWidget);
  });
}

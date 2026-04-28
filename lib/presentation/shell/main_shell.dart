import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../deposit/deposit_page.dart';
import '../deposit/deposit_notifier.dart';
import '../extrato/extrato_page.dart';
import '../ganhos/ganhos_page.dart';
import '../home/home_page.dart';
import '../payment/plan_selection_screen.dart';
import '../perfil/perfil_page.dart';
import '../withdraw/withdraw_page.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = ['Home', 'Investir', 'Ganhos', 'Extrato', 'Perfil'];

  int get _stackIndex => _index;

  final _homeKey = HomePageKey();
  final _ganhosKey = GlobalKey<GanhosPageState>();
  final _extratoKey = GlobalKey<ExtratoPageState>();
  final _perfilKey = GlobalKey<PerfilPageState>();
  final _investirKey = GlobalKey<PlanSelectionScreenState>();

  void _reloadAll() {
    _homeKey.currentState?.reload();
    _ganhosKey.currentState?.reload();
    _extratoKey.currentState?.reload();
    _perfilKey.currentState?.reload();
    _investirKey.currentState?.reload();
  }

  void _openDeposit() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (c) => DepositNotifier(c.read<Dio>()),
          child: const DepositPage(),
        ),
      ),
    );
    _reloadAll();
  }

  void _openWithdraw() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WithdrawPage()),
    );
    _reloadAll();
  }

  void _onNavTap(int i) {
    setState(() => _index = i);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (i) {
        case 0: _homeKey.currentState?.reload(); break;
        case 1: _investirKey.currentState?.reload(); break;
        case 2: _ganhosKey.currentState?.reload(); break;
        case 3: _extratoKey.currentState?.reload(); break;
        case 4: _perfilKey.currentState?.reload(); break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _index == 0
          ? null
          : AppBar(title: Text(_titles[_index])),
      body: IndexedStack(
        index: _stackIndex,
        children: [
          HomePage(key: _homeKey, onDepositar: _openDeposit, onSacar: _openWithdraw),
          PlanSelectionScreen(key: _investirKey),
          GanhosPage(key: _ganhosKey),
          ExtratoPage(key: _extratoKey),
          PerfilPage(key: _perfilKey),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onNavTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Investir',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'Ganhos',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Extrato',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: AppColors.neonCyan.withValues(alpha: 0.15),
      ),
    );
  }
}

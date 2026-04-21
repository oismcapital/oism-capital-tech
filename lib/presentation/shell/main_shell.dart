import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../deposit/deposit_page.dart';
import '../deposit/deposit_notifier.dart';
import '../ganhos/ganhos_page.dart';
import '../home/home_page.dart';
import '../indicar/indicar_page.dart';
import '../payment/plan_selection_screen.dart';
import '../perfil/perfil_page.dart';
import '../withdraw/withdraw_page.dart';
import 'package:provider/provider.dart';
import '../../core/network/dio_client.dart';
import 'package:dio/dio.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = ['Home', 'Investir', 'Ganhos', 'Indicar', 'Perfil'];

  // stackIndex maps nav index to IndexedStack index
  // Nav:   0=Home, 1=Investir, 2=Ganhos, 3=Indicar, 4=Perfil
  // Stack: 0=Home, 1=Investir, 2=Ganhos, 3=Indicar, 4=Perfil
  int get _stackIndex => _index;

  void goTo(int index) {
    if (index >= 0 && index < _titles.length) {
      setState(() => _index = index);
    }
  }

  final _homeKey = HomePageKey();
  final _ganhosKey = GlobalKey<GanhosPageState>();
  final _perfilKey = GlobalKey<PerfilPageState>();

  void _reloadAll() {
    _homeKey.currentState?.reload();
    _ganhosKey.currentState?.reload();
    _perfilKey.currentState?.reload();
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
        case 2: _ganhosKey.currentState?.reload(); break;
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
          const PlanSelectionScreen(),
          GanhosPage(key: _ganhosKey),
          const IndicarPage(),
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
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Indicar',
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

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../ganhos/ganhos_page.dart';
import '../home/home_page.dart';
import '../invest/invest_page.dart';
import '../perfil/perfil_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = ['Home', 'Investir', 'Ganhos', 'Perfil'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _index == 0
          ? null
          : AppBar(
              title: Text(_titles[_index]),
            ),
      body: IndexedStack(
        index: _index,
        children: const [
          HomePage(),
          InvestPage(),
          GanhosPage(),
          PerfilPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
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

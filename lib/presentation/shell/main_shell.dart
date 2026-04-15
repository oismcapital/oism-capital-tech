import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../ganhos/ganhos_page.dart';
import '../home/home_page.dart';
import '../indicar/indicar_page.dart';
import '../payment/plan_selection_screen.dart';
import '../perfil/perfil_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _index = 0;

  // "Investir" (índice 1) não ocupa slot no IndexedStack — abre como rota
  // Os demais índices mapeiam: 0→Home, 2→Ganhos, 3→Indicar, 4→Perfil
  static const _titles = ['Home', 'Investir', 'Ganhos', 'Indicar', 'Perfil'];

  // Converte índice da NavBar para índice do IndexedStack (pula o 1)
  int get _stackIndex => _index > 1 ? _index - 1 : _index;

  void goTo(int index) {
    if (index >= 0 && index < _titles.length) {
      setState(() => _index = index);
    }
  }

  void _openPlanSelection() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PlanSelectionScreen()),
    );
  }

  void _onNavTap(int i) {
    // Investir (índice 1) abre a PlanSelectionScreen como rota
    if (i == 1) {
      _openPlanSelection();
      return;
    }
    setState(() => _index = i);
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
          HomePage(onDepositar: _openPlanSelection),
          const GanhosPage(),
          const IndicarPage(),
          const PerfilPage(),
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

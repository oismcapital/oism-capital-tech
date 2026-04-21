import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/finance_repository.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => PerfilPageState();
}

class PerfilPageState extends State<PerfilPage> {
  void reload() => _load();
  double _walletBalance = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final summary = await context.read<FinanceRepository>().getSummary();
      if (mounted) {
        setState(() {
          _walletBalance = summary.walletBalance;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          // Avatar e nome
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.neonCyan.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonCyan.withValues(alpha: 0.15),
                    border: Border.all(
                        color: AppColors.neonCyan.withValues(alpha: 0.4),
                        width: 2),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: AppColors.neonCyan, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Minha Conta',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'OISM Capital Tech',
                        style: TextStyle(
                            color: AppColors.textMuted.withValues(alpha: 0.8),
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Saldo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.neonGreen.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    color: AppColors.neonGreen),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Saldo em Conta',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                    _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.neonGreen))
                        : Text(
                            'R\$ ${_walletBalance.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: const TextStyle(
                                color: AppColors.neonGreen,
                                fontSize: 20,
                                fontWeight: FontWeight.w800),
                          ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Sair
          OutlinedButton.icon(
            onPressed: () async {
              await context.read<AuthRepository>().logout();
              authNotifier.value = false;
            },
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text('Sair da conta'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: BorderSide(
                  color: Colors.redAccent.withValues(alpha: 0.45)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class InvestPage extends StatelessWidget {
  const InvestPage({super.key});

  static const _plans = <_Plan>[
    _Plan(name: 'Start', priceLabel: 'R\$ 10'),
    _Plan(name: 'Basic', priceLabel: 'R\$ 30'),
    _Plan(name: 'Pro', priceLabel: 'R\$ 100'),
    _Plan(name: 'Elite', priceLabel: 'R\$ 1000'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: _plans.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = _plans[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.35)),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.neonCyan.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Icon(Icons.auto_graph, color: AppColors.neonCyan),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plano ${p.name}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Aporte mínimo',
                        style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95)),
                      ),
                    ],
                  ),
                ),
                Text(
                  p.priceLabel,
                  style: const TextStyle(
                    color: AppColors.neonCyan,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Plan {
  const _Plan({required this.name, required this.priceLabel});

  final String name;
  final String priceLabel;
}

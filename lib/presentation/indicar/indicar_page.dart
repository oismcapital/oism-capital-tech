import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class IndicarPage extends StatelessWidget {
  const IndicarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people, size: 64, color: AppColors.neonCyan.withValues(alpha: 0.7)),
            const SizedBox(height: 20),
            const Text(
              'Programa de Indicações',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Indique amigos e ganhe bônus quando eles investirem na plataforma.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class IndicarPage extends StatelessWidget {
  const IndicarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Indique amigos e acompanhe suas recompensas de indicação.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 15),
        ),
      ),
    );
  }
}

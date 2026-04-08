import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class GanhosPage extends StatelessWidget {
  const GanhosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Aqui você verá histórico de ganhos e relatórios.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 15),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.neonCyan,
      onPrimary: AppColors.background,
      secondary: AppColors.neonCyan,
      onSurface: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.25)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.neonCyan.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.neonCyan);
          }
          return IconThemeData(color: AppColors.textMuted.withValues(alpha: 0.9));
        }),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(color: AppColors.textMuted),
      ),
    );
  }
}

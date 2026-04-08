import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/shell/main_shell.dart';

class OismApp extends StatelessWidget {
  const OismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OISM Capital Tech',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const MainShell(),
    );
  }
}

import 'package:flutter/material.dart';

import 'core/auth/token_holder.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/auth_screen.dart';
import 'presentation/shell/main_shell.dart';

/// Notifier global para controlar autenticação sem perder os providers.
final authNotifier = ValueNotifier<bool>(false);

class OismApp extends StatefulWidget {
  const OismApp({super.key});

  @override
  State<OismApp> createState() => _OismAppState();
}

class _OismAppState extends State<OismApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await TokenHolder.initialize();
    authNotifier.value = TokenHolder.accessToken != null;
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oism Capital Tech',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: !_initialized
          ? const Scaffold(
              backgroundColor: Color(0xFF070B15),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
              ),
            )
          : ValueListenableBuilder<bool>(
              valueListenable: authNotifier,
              builder: (_, isLoggedIn, __) {
                return isLoggedIn ? const MainShell() : const AuthScreen();
              },
            ),
    );
  }
}

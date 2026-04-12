import 'package:flutter/material.dart';

import 'core/auth/token_holder.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/auth_screen.dart';
import 'presentation/shell/main_shell.dart';

class OismApp extends StatefulWidget {
  const OismApp({super.key});

  @override
  State<OismApp> createState() => _OismAppState();
}

class _OismAppState extends State<OismApp> {
  bool _initialized = false;
  bool _hasToken = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await TokenHolder.initialize();
    if (mounted) {
      setState(() {
        _hasToken = TokenHolder.accessToken != null;
        _initialized = true;
      });
    }
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
          : _hasToken
              ? const MainShell()
              : const AuthScreen(),
    );
  }
}

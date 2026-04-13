import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/auth/token_holder.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailCtrl = TextEditingController();
  final _loginSenhaCtrl = TextEditingController();
  bool _loginLoading = false;
  String? _loginError;

  final _registerFormKey = GlobalKey<FormState>();
  final _registerNomeCtrl = TextEditingController();
  final _registerEmailCtrl = TextEditingController();
  final _registerSenhaCtrl = TextEditingController();
  bool _registerLoading = false;
  String? _registerError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Limpa erros ao trocar de aba
      setState(() {
        _loginError = null;
        _registerError = null;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginSenhaCtrl.dispose();
    _registerNomeCtrl.dispose();
    _registerEmailCtrl.dispose();
    _registerSenhaCtrl.dispose();
    super.dispose();
  }

  String _extractErrorMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map && data['error'] != null) {
        return data['error'].toString();
      }
      if (data is String && data.isNotEmpty) return data;
    } catch (_) {}

    final status = e.response?.statusCode;
    if (status == 404) return 'Usuário não encontrado. Faça seu cadastro.';
    if (status == 401) return 'Senha incorreta.';
    if (status == 400) return 'Dados inválidos.';
    if (status == 409) return 'Este email já está em uso.';
    return 'Sem conexão com o servidor';
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe o email';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(v.trim())) return 'Email inválido';
    return null;
  }

  String? _validateSenha(String? v) {
    if (v == null || v.isEmpty) return 'Informe a senha';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  Future<void> _login() async {
    setState(() => _loginError = null);
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _loginLoading = true);
    try {
      final svc = context.read<AuthService>();
      final resp = await svc.login(
        email: _loginEmailCtrl.text.trim(),
        password: _loginSenhaCtrl.text,
      );
      await TokenHolder.setToken(resp.accessToken);
      authNotifier.value = true;
    } on DioException catch (e) {
      setState(() => _loginError = _extractErrorMessage(e));
    } catch (_) {
      setState(() => _loginError = 'Sem conexão com o servidor');
    } finally {
      if (mounted) setState(() => _loginLoading = false);
    }
  }

  Future<void> _register() async {
    setState(() => _registerError = null);
    if (!_registerFormKey.currentState!.validate()) return;
    setState(() => _registerLoading = true);
    try {
      final svc = context.read<AuthService>();
      final resp = await svc.register(
        nome: _registerNomeCtrl.text.trim(),
        email: _registerEmailCtrl.text.trim(),
        senha: _registerSenhaCtrl.text,
      );
      await TokenHolder.setToken(resp.accessToken);
      authNotifier.value = true;
    } on DioException catch (e) {
      setState(() => _registerError = _extractErrorMessage(e));
    } catch (_) {
      setState(() => _registerError = 'Sem conexão com o servidor');
    } finally {
      if (mounted) setState(() => _registerLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Text(
                'OISM Capital Tech',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  color: AppColors.neonCyan,
                  shadows: [
                    Shadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Plataforma de investimentos automatizada',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 36),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.2),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.neonCyan,
                  labelColor: AppColors.neonCyan,
                  unselectedLabelColor: AppColors.textMuted,
                  dividerColor: Colors.transparent,
                  tabs: const [Tab(text: 'Entrar'), Tab(text: 'Cadastrar')],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildLogin(), _buildRegister()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorBox(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogin() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(
            controller: _loginEmailCtrl,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 14),
          _field(
            controller: _loginSenhaCtrl,
            label: 'Senha',
            obscure: true,
            validator: _validateSenha,
          ),
          if (_loginError != null) ...[
            const SizedBox(height: 14),
            _errorBox(_loginError!),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loginLoading ? null : _login,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _loginLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.background,
                    ),
                  )
                : const Text(
                    'Entrar',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegister() {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(
            controller: _registerNomeCtrl,
            label: 'Nome completo',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
          ),
          const SizedBox(height: 14),
          _field(
            controller: _registerEmailCtrl,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 14),
          _field(
            controller: _registerSenhaCtrl,
            label: 'Senha',
            obscure: true,
            validator: _validateSenha,
          ),
          if (_registerError != null) ...[
            const SizedBox(height: 14),
            _errorBox(_registerError!),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _registerLoading ? null : _register,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _registerLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.background,
                    ),
                  )
                : const Text(
                    'Cadastrar',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.neonCyan),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

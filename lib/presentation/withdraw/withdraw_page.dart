import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../data/services/finance_service.dart';

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _pixKeyCtrl = TextEditingController();
  bool _loading = false;
  double _walletBalance = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBalance());
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _pixKeyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBalance() async {
    try {
      final summary = await context.read<FinanceRepository>().getSummary();
      if (mounted) setState(() => _walletBalance = summary.walletBalance);
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final amount = double.parse(_amountCtrl.text.replaceAll(',', '.'));

    try {
      await context.read<FinanceService>().withdraw(
            amount: amount,
            pixKey: _pixKeyCtrl.text.trim(),
          );
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Saque de R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')} solicitado!'),
            backgroundColor: AppColors.neonGreen,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sacar via PIX'),
        leading: const BackButton(color: AppColors.neonCyan),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Saldo disponível
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.neonCyan.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined,
                        color: AppColors.neonCyan),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo disponível',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 12)),
                        Text(
                          'R\$ ${_walletBalance.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Valor
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                ],
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration(
                  label: 'Valor do saque (R\$)',
                  hint: '0,00',
                  icon: Icons.attach_money_rounded,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o valor';
                  final amount =
                      double.tryParse(v.replaceAll(',', '.')) ?? 0;
                  if (amount <= 0) return 'Valor inválido';
                  if (amount > _walletBalance) return 'Saldo insuficiente';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Chave PIX
              TextFormField(
                controller: _pixKeyCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration(
                  label: 'Chave PIX',
                  hint: 'CPF, e-mail, telefone ou chave aleatória',
                  icon: Icons.pix_rounded,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Informe a chave PIX';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                'O valor será transferido para a chave PIX informada em até 1 hora útil.',
                style: TextStyle(
                    color: AppColors.textMuted.withValues(alpha: 0.7),
                    fontSize: 12),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonCyan,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  disabledBackgroundColor:
                      AppColors.neonCyan.withValues(alpha: 0.4),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.background),
                      )
                    : const Text('Confirmar Saque',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String label, required String hint, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.neonCyan, size: 20),
      labelStyle: const TextStyle(color: AppColors.textMuted),
      hintStyle:
          TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5)),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: AppColors.neonCyan, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}

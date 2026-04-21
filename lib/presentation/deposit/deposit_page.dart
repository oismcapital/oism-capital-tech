import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import 'deposit_notifier.dart';
import 'widgets/deposit_pix_sheet.dart';

class DepositPage extends StatefulWidget {
  const DepositPage({super.key});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final raw = _amountCtrl.text.replaceAll('.', '').replaceAll(',', '.');
    final amount = double.tryParse(raw) ?? 0;

    final notifier = context.read<DepositNotifier>();
    await notifier.generatePix(amount);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (notifier.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(notifier.errorMessage ?? 'Erro ao gerar PIX'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (notifier.deposit != null) {
      final dio = context.read<Dio>();
      await DepositPixSheet.show(context, notifier.deposit!, dio);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Depositar'),
        leading: const BackButton(color: AppColors.neonCyan),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              // Ícone decorativo
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonCyan.withValues(alpha: 0.12),
                    border: Border.all(
                        color: AppColors.neonCyan.withValues(alpha: 0.4),
                        width: 2),
                  ),
                  child: const Icon(Icons.pix_rounded,
                      color: AppColors.neonCyan, size: 36),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Quanto deseja depositar?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'O valor será adicionado ao seu saldo após a confirmação do PIX.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textMuted.withValues(alpha: 0.8),
                    fontSize: 13),
              ),
              const SizedBox(height: 32),
              // Campo de valor
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                ],
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  prefixText: 'R\$ ',
                  prefixStyle: const TextStyle(
                      color: AppColors.neonCyan,
                      fontSize: 28,
                      fontWeight: FontWeight.w800),
                  hintText: '0,00',
                  hintStyle: TextStyle(
                      color: AppColors.textMuted.withValues(alpha: 0.4),
                      fontSize: 28,
                      fontWeight: FontWeight.w800),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                        color: AppColors.neonCyan.withValues(alpha: 0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                        color: AppColors.neonCyan.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: AppColors.neonCyan, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o valor';
                  final raw =
                      v.replaceAll('.', '').replaceAll(',', '.');
                  final amount = double.tryParse(raw) ?? 0;
                  if (amount < 1) return 'Valor mínimo: R\$ 1,00';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Atalhos de valor
              _buildQuickAmounts(),
              const SizedBox(height: 32),
              Consumer<DepositNotifier>(
                builder: (context, notifier, _) => ElevatedButton.icon(
                  onPressed: (_submitting || notifier.loading) ? null : _submit,
                  icon: notifier.loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.background),
                        )
                      : const Icon(Icons.qr_code_rounded, size: 20),
                  label: Text(
                    notifier.loading ? 'Gerando PIX...' : 'Gerar PIX',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    disabledBackgroundColor:
                        AppColors.neonCyan.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmounts() {
    const amounts = [25.0, 50.0, 100.0, 500.0, 1000.0];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: amounts.map((v) {
        final label =
            'R\$ ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}';
        return GestureDetector(
          onTap: () => setState(() =>
              _amountCtrl.text = v.toStringAsFixed(2).replaceAll('.', ',')),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.neonCyan.withValues(alpha: 0.3)),
            ),
            child: Text(
              label,
              style: const TextStyle(
                  color: AppColors.neonCyan,
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
            ),
          ),
        );
      }).toList(),
    );
  }
}

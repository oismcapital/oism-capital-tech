import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/pix_deposit.dart';
import '../payment_notifier.dart';

class PixPaymentSheet extends StatelessWidget {
  const PixPaymentSheet({super.key, required this.deposit});

  final PixDeposit deposit;

  static Future<void> show(BuildContext context, PixDeposit deposit) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<PaymentNotifier>(),
        child: PixPaymentSheet(deposit: deposit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.neonCyan, width: 1.5),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Consumer<PaymentNotifier>(
        builder: (context, notifier, _) {
          if (notifier.status == PaymentStatus.confirmed) {
            return _buildConfirmed(context);
          }
          if (notifier.status == PaymentStatus.expired) {
            return _buildExpired(context);
          }
          return _buildPending(context);
        },
      ),
    );
  }

  Widget _buildPending(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHandle(),
        const SizedBox(height: 16),
        _buildTitle(),
        const SizedBox(height: 8),
        _buildAmountBadge(),
        const SizedBox(height: 24),
        _buildQrCode(),
        const SizedBox(height: 20),
        _buildCopyButton(context),
        const SizedBox(height: 20),
        _buildAwaitingStatus(),
        const SizedBox(height: 8),
        _buildExpiresLabel(),
      ],
    );
  }

  Widget _buildConfirmed(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHandle(),
        const SizedBox(height: 24),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.neonGreen.withValues(alpha: 0.15),
            border: Border.all(color: AppColors.neonGreen, width: 2),
          ),
          child: const Icon(Icons.check_rounded, color: AppColors.neonGreen, size: 40),
        ),
        const SizedBox(height: 16),
        const Text(
          'Pagamento confirmado!',
          style: TextStyle(
            color: AppColors.neonGreen,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'R\$ ${deposit.amount.toStringAsFixed(2).replaceAll('.', ',')} adicionado ao seu saldo.',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Fechar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildExpired(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHandle(),
        const SizedBox(height: 24),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent.withValues(alpha: 0.15),
            border: Border.all(color: Colors.redAccent, width: 2),
          ),
          child: const Icon(Icons.timer_off_rounded, color: Colors.redAccent, size: 36),
        ),
        const SizedBox(height: 16),
        const Text(
          'QR Code expirado',
          style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Gere um novo código para continuar.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.read<PaymentNotifier>().reset();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Tentar novamente', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildHandle() => Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textMuted.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildTitle() => const Text(
        'Pague com Pix',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      );

  Widget _buildAmountBadge() {
    final formatted = 'R\$ ${deposit.amount.toStringAsFixed(2).replaceAll('.', ',')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neonCyan.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
      ),
      child: Text(
        'Plano ${deposit.planName} · $formatted',
        style: const TextStyle(
          color: AppColors.neonCyan,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildQrCode() {
    Uint8List? bytes;
    try {
      bytes = base64Decode(deposit.qrCodeBase64);
    } catch (_) {}

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.25),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: bytes != null
            ? Image.memory(bytes, fit: BoxFit.contain)
            : _buildQrPlaceholder(),
      ),
    );
  }

  Widget _buildQrPlaceholder() => Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_2_rounded, size: 80, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              deposit.transactionId.substring(0, 8).toUpperCase(),
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      );

  Widget _buildCopyButton(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _copyCode(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonCyan,
            foregroundColor: AppColors.background,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: const Text(
            'Copiar Código Pix',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
      );

  Widget _buildAwaitingStatus() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.neonCyan.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Aguardando confirmação do pagamento...',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      );

  Widget _buildExpiresLabel() => Text(
        'QR Code válido por 30 minutos',
        style: TextStyle(
          color: AppColors.textMuted.withValues(alpha: 0.6),
          fontSize: 11,
        ),
      );

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: deposit.copyAndPaste));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Código Pix copiado!'),
          backgroundColor: AppColors.neonCyan.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

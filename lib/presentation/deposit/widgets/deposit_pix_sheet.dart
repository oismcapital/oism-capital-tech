import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/deposit_pix_dto.dart';

class DepositPixSheet extends StatefulWidget {
  const DepositPixSheet({
    super.key,
    required this.deposit,
    required this.dio,
  });

  final DepositPixDto deposit;
  final Dio dio;

  static Future<void> show(
      BuildContext context, DepositPixDto deposit, Dio dio) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DepositPixSheet(deposit: deposit, dio: dio),
    );
  }

  @override
  State<DepositPixSheet> createState() => _DepositPixSheetState();
}

class _DepositPixSheetState extends State<DepositPixSheet> {
  Timer? _timer;
  bool _confirmed = false;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final res = await widget.dio.get<Map<String, dynamic>>(
          '/api/v1/payments/${widget.deposit.transactionId}/status',
        );
        final status = res.data?['status'] as String? ?? 'PENDING';
        if (!mounted) return;
        if (status == 'COMPLETED') {
          _timer?.cancel();
          setState(() => _confirmed = true);
        } else if (status == 'EXPIRED') {
          _timer?.cancel();
          setState(() => _expired = true);
        }
      } catch (_) {}
    });
  }

  String get _formattedAmount =>
      'R\$ ${widget.deposit.amount.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.neonCyan, width: 1.5)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: _confirmed
          ? _buildConfirmed()
          : _expired
              ? _buildExpired()
              : _buildPending(),
    );
  }

  Widget _buildPending() {
    Uint8List? bytes;
    try {
      bytes = base64Decode(widget.deposit.qrCodeBase64);
    } catch (_) {}

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _handle(),
        const SizedBox(height: 16),
        const Text('Pague com PIX',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.neonCyan.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
          ),
          child: Text(
            'Depósito · $_formattedAmount',
            style: const TextStyle(
                color: AppColors.neonCyan,
                fontWeight: FontWeight.w700,
                fontSize: 14),
          ),
        ),
        const SizedBox(height: 24),
        // QR Code
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 2)
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: bytes != null
                ? Image.memory(bytes, fit: BoxFit.contain)
                : Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code_2_rounded,
                            size: 80, color: Colors.black87),
                        const SizedBox(height: 8),
                        Text(
                          widget.deposit.transactionId
                              .substring(0, 8)
                              .toUpperCase(),
                          style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 11,
                              fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        // Botão copiar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await Clipboard.setData(
                  ClipboardData(text: widget.deposit.copyAndPaste));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Código PIX copiado!'),
                  backgroundColor:
                      AppColors.neonCyan.withValues(alpha: 0.9),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copiar Código PIX',
                style:
                    TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.neonCyan.withValues(alpha: 0.8)),
            ),
            const SizedBox(width: 10),
            const Text('Aguardando confirmação...',
                style:
                    TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        Text('QR Code válido por 30 minutos',
            style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.6),
                fontSize: 11)),
      ],
    );
  }

  Widget _buildConfirmed() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _handle(),
        const SizedBox(height: 24),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.neonGreen.withValues(alpha: 0.15),
            border: Border.all(color: AppColors.neonGreen, width: 2),
          ),
          child: const Icon(Icons.check_rounded,
              color: AppColors.neonGreen, size: 40),
        ),
        const SizedBox(height: 16),
        const Text('Depósito confirmado!',
            style: TextStyle(
                color: AppColors.neonGreen,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('$_formattedAmount adicionado ao seu saldo.',
            style:
                const TextStyle(color: AppColors.textMuted, fontSize: 14)),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Fechar',
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildExpired() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _handle(),
        const SizedBox(height: 24),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent.withValues(alpha: 0.15),
            border: Border.all(color: Colors.redAccent, width: 2),
          ),
          child: const Icon(Icons.timer_off_rounded,
              color: Colors.redAccent, size: 36),
        ),
        const SizedBox(height: 16),
        const Text('QR Code expirado',
            style: TextStyle(
                color: Colors.redAccent,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Gere um novo código para continuar.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Tentar novamente',
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _handle() => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.textMuted.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/plan.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../invest/invest_notifier.dart';

class PlanSelectionScreen extends StatefulWidget {
  const PlanSelectionScreen({super.key});

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  List<Plan> _plans = [];
  bool _loadingPlans = true;
  double _walletBalance = 0;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() { _loadingPlans = true; _loadError = null; });
    try {
      final results = await Future.wait([
        context.read<PaymentRepository>().getPlans(),
        context.read<FinanceRepository>().getSummary(),
      ]);
      if (!mounted) return;
      setState(() {
        _plans = results[0] as List<Plan>;
        _walletBalance = (results[1] as dynamic).walletBalance as double;
        _loadingPlans = false;
      });
    } catch (e) {
      if (mounted) setState(() { _loadError = e.toString(); _loadingPlans = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha seu Plano'),
        leading: const BackButton(color: AppColors.neonCyan),
      ),
      body: _loadingPlans
          ? const Center(child: CircularProgressIndicator(color: AppColors.neonCyan))
          : _loadError != null && _plans.isEmpty
              ? _ErrorView(message: _loadError!, onRetry: _load)
              : Column(
                  children: [
                    _buildBalanceBanner(),
                    Expanded(child: _PlanList(plans: _plans, walletBalance: _walletBalance)),
                  ],
                ),
    );
  }

  Widget _buildBalanceBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_outlined,
              color: AppColors.neonCyan, size: 18),
          const SizedBox(width: 8),
          const Text('Saldo disponível:',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            'R\$ ${_walletBalance.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
                color: AppColors.neonCyan,
                fontWeight: FontWeight.w800,
                fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Lista de planos ────────────────────────────────────────────────────────────

class _PlanList extends StatelessWidget {
  const _PlanList({required this.plans, required this.walletBalance});

  final List<Plan> plans;
  final double walletBalance;

  static const _gradients = [
    [Color(0xFF546E7A), Color(0xFF37474F)],
    [Color(0xFF00ACC1), Color(0xFF00838F)],
    [Color(0xFF00C853), Color(0xFF007E33)],
    [Color(0xFF7C4DFF), Color(0xFF4527A0)],
    [Color(0xFFFFD600), Color(0xFFFF8F00)],
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: plans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        final plan = plans[i];
        final colors = _gradients[i % _gradients.length];
        return _PlanCard(
          plan: plan,
          gradientColors: colors,
          walletBalance: walletBalance,
        );
      },
    );
  }
}

// ── Card de plano ──────────────────────────────────────────────────────────────

class _PlanCard extends StatefulWidget {
  const _PlanCard({
    required this.plan,
    required this.gradientColors,
    required this.walletBalance,
  });

  final Plan plan;
  final List<Color> gradientColors;
  final double walletBalance;

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _loading = false;

  String get _formattedAmount =>
      'R\$ ${widget.plan.amount.toStringAsFixed(2).replaceAll('.', ',')}';

  bool get _hasSufficientBalance => widget.walletBalance >= widget.plan.amount;

  Future<void> _onSelect() async {
    if (_loading) return;

    if (!_hasSufficientBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Saldo insuficiente. Deposite pelo menos $_formattedAmount.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Confirmação
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Confirmar Investimento',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Deseja investir $_formattedAmount no Plano ${widget.plan.name}?\n\nEsse valor será debitado do seu saldo.',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: AppColors.background,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    setState(() => _loading = true);
    final error =
        await context.read<InvestNotifier>().purchase(widget.plan.id);
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Plano ${widget.plan.name} contratado! Acompanhe em Investimentos.'),
        backgroundColor: AppColors.neonGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sufficient = _hasSufficientBalance;
    final accentColor =
        sufficient ? widget.gradientColors.first : AppColors.textMuted;

    return GestureDetector(
      onTap: _onSelect,
      child: Opacity(
        opacity: sufficient ? 1.0 : 0.5,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.1),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                _buildRobotIcon(),
                const SizedBox(width: 16),
                Expanded(child: _buildInfo()),
                _buildPrice(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRobotIcon() => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: widget.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const _RobotFace(),
      );

  Widget _buildInfo() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plano ${widget.plan.name}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.plan.description,
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
          if (!_hasSufficientBalance) ...[
            const SizedBox(height: 4),
            Text(
              'Saldo insuficiente',
              style: TextStyle(
                  color: Colors.redAccent.withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ],
      );

  Widget _buildPrice() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formattedAmount,
            style: TextStyle(
              color: widget.gradientColors.first,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: widget.gradientColors),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _loading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Investir',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      );
}

// ── Robô desenhado com CustomPaint ─────────────────────────────────────────────

class _RobotFace extends StatelessWidget {
  const _RobotFace();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(52, 52),
      painter: _RobotPainter(),
    );
  }
}

class _RobotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final white = Paint()..color = Colors.white;
    final dark = Paint()..color = Colors.white.withValues(alpha: 0.15);
    final eyeGlow = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Cabeça (retângulo arredondado)
    final head = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 28, height: 24),
      const Radius.circular(6),
    );
    canvas.drawRRect(head, dark);
    canvas.drawRRect(head, Paint()..color = Colors.white.withValues(alpha: 0.08));

    // Antena
    final antennaPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - 12), Offset(cx, cy - 18), antennaPaint);
    canvas.drawCircle(Offset(cx, cy - 19), 2, white);

    // Olhos — brilho
    canvas.drawCircle(Offset(cx - 6, cy - 1), 4, eyeGlow);
    canvas.drawCircle(Offset(cx + 6, cy - 1), 4, eyeGlow);
    // Olhos — pupila
    canvas.drawCircle(Offset(cx - 6, cy - 1), 3, white);
    canvas.drawCircle(Offset(cx + 6, cy - 1), 3, white);
    canvas.drawCircle(Offset(cx - 6, cy - 1), 1.2,
        Paint()..color = Colors.black.withValues(alpha: 0.6));
    canvas.drawCircle(Offset(cx + 6, cy - 1), 1.2,
        Paint()..color = Colors.black.withValues(alpha: 0.6));

    // Boca (linha reta com cantos levemente curvados)
    final mouthPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final mouth = Path()
      ..moveTo(cx - 5, cy + 6)
      ..quadraticBezierTo(cx, cy + 8, cx + 5, cy + 6);
    canvas.drawPath(mouth, mouthPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Error view ─────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonCyan,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

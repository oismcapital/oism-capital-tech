import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/plan.dart';
import 'payment_notifier.dart';
import 'widgets/pix_payment_sheet.dart';

class PlanSelectionScreen extends StatefulWidget {
  const PlanSelectionScreen({super.key});

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentNotifier>().loadPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha seu Plano'),
        leading: const BackButton(color: AppColors.neonCyan),
      ),
      body: Consumer<PaymentNotifier>(
        builder: (context, notifier, _) {
          if (notifier.status == PaymentStatus.loadingPlans) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.neonCyan),
            );
          }

          if (notifier.status == PaymentStatus.error &&
              notifier.plans.isEmpty) {
            return _ErrorView(
              message: notifier.errorMessage ?? 'Erro desconhecido',
              onRetry: () => notifier.loadPlans(),
            );
          }

          return _PlanList(plans: notifier.plans);
        },
      ),
    );
  }
}

// ── Lista de planos ────────────────────────────────────────────────────────────

class _PlanList extends StatelessWidget {
  const _PlanList({required this.plans});

  final List<Plan> plans;

  // Gradientes com progressão visual: Start (cinza/azul frio) → Elite (dourado premium)
  static const _gradients = [
    // Start — azul aço discreto
    [Color(0xFF546E7A), Color(0xFF37474F)],
    // Basic — ciano/teal
    [Color(0xFF00ACC1), Color(0xFF00838F)],
    // Plus — verde neon
    [Color(0xFF00C853), Color(0xFF007E33)],
    // Pro — roxo vibrante
    [Color(0xFF7C4DFF), Color(0xFF4527A0)],
    // Elite — dourado premium
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
        return _PlanCard(plan: plan, gradientColors: colors);
      },
    );
  }
}

// ── Card de plano ──────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.gradientColors,
  });

  final Plan plan;
  final List<Color> gradientColors;

  String get _formattedAmount =>
      'R\$ ${plan.amount.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onSelect(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: gradientColors.first.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.1),
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
              _buildPrice(context),
            ],
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
            colors: gradientColors,
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
            'Plano ${plan.name}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            plan.description,
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
        ],
      );

  Widget _buildPrice(BuildContext context) => Consumer<PaymentNotifier>(
        builder: (context, notifier, _) {
          final isLoading = notifier.status == PaymentStatus.generatingPix;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formattedAmount,
                style: TextStyle(
                  color: gradientColors.first,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Selecionar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ],
          );
        },
      );

  Future<void> _onSelect(BuildContext context) async {
    final notifier = context.read<PaymentNotifier>();

    if (notifier.status == PaymentStatus.generatingPix) return;

    await notifier.generatePix(plan.id);

    if (!context.mounted) return;

    if (notifier.status == PaymentStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(notifier.errorMessage ?? 'Erro ao gerar Pix'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final deposit = notifier.deposit;
    if (deposit != null) {
      await PixPaymentSheet.show(context, deposit);
    }
  }
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

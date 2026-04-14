import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RobotTraderIllustration extends StatefulWidget {
  const RobotTraderIllustration({super.key, this.size = 200});
  final double size;

  @override
  State<RobotTraderIllustration> createState() =>
      _RobotTraderIllustrationState();
}

class _RobotTraderIllustrationState extends State<RobotTraderIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _float;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _float.value),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _Robot3DPainter(glowIntensity: _glow.value),
          ),
        ),
      ),
    );
  }
}

class _Robot3DPainter extends CustomPainter {
  final double glowIntensity;
  _Robot3DPainter({required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    _drawBase(canvas, cx, h * 0.90, w * 0.52, h * 0.06);
    _drawBody(canvas, cx, h * 0.60, w * 0.42, h * 0.34);
    _drawArm(canvas, cx - w * 0.27, h * 0.57, w * 0.10, h * 0.26, left: true);
    _drawArm(canvas, cx + w * 0.27, h * 0.57, w * 0.10, h * 0.26, left: false);
    // Mãos com conteúdo financeiro
    _drawHandLeft(canvas, cx - w * 0.27, h * 0.73, w * 0.13);
    _drawHandRight(canvas, cx + w * 0.27, h * 0.73, w * 0.14, glowIntensity);
    _drawNeck(canvas, cx, h * 0.37, w * 0.10, h * 0.06);
    _drawHead(canvas, cx, h * 0.25, w * 0.40, h * 0.25);
    _drawEye(canvas, cx - w * 0.095, h * 0.23, w * 0.065, glowIntensity);
    _drawEye(canvas, cx + w * 0.095, h * 0.23, w * 0.065, glowIntensity);
    _drawAntenna(canvas, cx, h * 0.10, h * 0.08, glowIntensity);
    _drawChestPanel(canvas, cx, h * 0.58, w * 0.25, h * 0.16, glowIntensity);
    _drawSpecular(canvas, cx - w * 0.06, h * 0.15, w * 0.11, h * 0.04);
  }

  // ── Base ────────────────────────────────────────────────────────────────────
  void _drawBase(Canvas canvas, double cx, double cy, double w, double h) {
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h * 0.5);
    canvas.drawOval(rect,
        Paint()
          ..shader = RadialGradient(colors: [
            AppColors.neonCyan.withValues(alpha: 0.5),
            AppColors.neonCyan.withValues(alpha: 0.0),
          ]).createShader(rect));
    canvas.drawOval(rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = AppColors.neonCyan.withValues(alpha: 0.55));
  }

  // ── Corpo ────────────────────────────────────────────────────────────────────
  void _drawBody(Canvas canvas, double cx, double cy, double w, double h) {
    final rr = RRect.fromRectAndCorners(
      Rect.fromCenter(center: Offset(cx, cy), width: w, height: h),
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: const Radius.circular(10),
      bottomRight: const Radius.circular(10),
    );
    canvas.drawRRect(rr.shift(const Offset(4, 5)),
        Paint()..color = Colors.black.withValues(alpha: 0.4));
    canvas.drawRRect(rr,
        Paint()
          ..shader = LinearGradient(
            colors: const [Color(0xFF1A3A6E), Color(0xFF0D2050), Color(0xFF071530)],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(rr.outerRect));
    canvas.drawRRect(rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..color = AppColors.neonCyan.withValues(alpha: 0.7));
    // Highlight lateral
    final hl = Rect.fromLTWH(rr.left + 3, rr.top + 8, 5, h * 0.5);
    canvas.drawRRect(
        RRect.fromRectAndRadius(hl, const Radius.circular(4)),
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.white.withValues(alpha: 0.22), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(hl));
  }

  // ── Braços ───────────────────────────────────────────────────────────────────
  void _drawArm(Canvas canvas, double cx, double cy, double w, double h,
      {required bool left}) {
    final rr = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: w, height: h),
        const Radius.circular(7));
    canvas.drawRRect(rr.shift(const Offset(3, 4)),
        Paint()..color = Colors.black.withValues(alpha: 0.35));
    canvas.drawRRect(rr,
        Paint()
          ..shader = LinearGradient(
            colors: const [Color(0xFF1A3A6E), Color(0xFF071530)],
            begin: left ? Alignment.centerRight : Alignment.centerLeft,
            end: left ? Alignment.centerLeft : Alignment.centerRight,
          ).createShader(rr.outerRect));
    canvas.drawRRect(rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = AppColors.neonCyan.withValues(alpha: 0.6));
    // Articulação
    final jc = Offset(cx, cy - h * 0.38);
    canvas.drawCircle(jc, w * 0.44,
        Paint()
          ..shader = RadialGradient(
            colors: const [Color(0xFF1E4A8A), Color(0xFF0A1E40)],
          ).createShader(Rect.fromCircle(center: jc, radius: w * 0.44)));
    canvas.drawCircle(jc, w * 0.44,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = AppColors.neonCyan.withValues(alpha: 0.65));
  }

  // ── Mão esquerda — segurando cifrão ─────────────────────────────────────────
  void _drawHandLeft(Canvas canvas, double cx, double cy, double r) {
    // Mão (círculo)
    canvas.drawCircle(Offset(cx, cy), r * 0.55,
        Paint()
          ..shader = RadialGradient(
            colors: const [Color(0xFF1E4A8A), Color(0xFF071530)],
          ).createShader(Rect.fromCircle(
              center: Offset(cx, cy), radius: r * 0.55)));
    canvas.drawCircle(Offset(cx, cy), r * 0.55,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = AppColors.neonCyan.withValues(alpha: 0.7));

    // Símbolo R$ (cifrão brasileiro)
    final tp = TextPainter(
      text: TextSpan(
        text: 'R\$',
        style: TextStyle(
          color: AppColors.neonCyan,
          fontSize: r * 0.62,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              color: AppColors.neonCyan.withValues(alpha: 0.8),
              blurRadius: 6,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  // ── Mão direita — segurando mini gráfico de alta ─────────────────────────────
  void _drawHandRight(Canvas canvas, double cx, double cy, double r,
      double glow) {
    // Tablet/tela na mão
    final tabRect = Rect.fromCenter(
        center: Offset(cx, cy - r * 0.1), width: r * 1.5, height: r * 1.1);
    final tabRR = RRect.fromRectAndRadius(tabRect, const Radius.circular(5));

    canvas.drawRRect(tabRR,
        Paint()
          ..shader = LinearGradient(
            colors: const [Color(0xFF0A1E40), Color(0xFF050F28)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(tabRect));
    canvas.drawRRect(tabRR,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = AppColors.neonCyan.withValues(alpha: 0.7));

    // Mini gráfico de alta dentro da tela
    final chartPath = Path();
    final pts = [
      Offset(tabRect.left + 4, tabRect.bottom - 5),
      Offset(tabRect.left + tabRect.width * 0.25, tabRect.bottom - tabRect.height * 0.45),
      Offset(tabRect.left + tabRect.width * 0.5, tabRect.bottom - tabRect.height * 0.55),
      Offset(tabRect.left + tabRect.width * 0.75, tabRect.bottom - tabRect.height * 0.75),
      Offset(tabRect.right - 4, tabRect.bottom - tabRect.height * 0.88),
    ];
    chartPath.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      final cp = Offset(
        (pts[i - 1].dx + pts[i].dx) / 2,
        (pts[i - 1].dy + pts[i].dy) / 2,
      );
      chartPath.quadraticBezierTo(pts[i - 1].dx, pts[i - 1].dy, cp.dx, cp.dy);
    }
    chartPath.lineTo(pts.last.dx, pts.last.dy);

    // Área preenchida
    final fillPath = Path.from(chartPath)
      ..lineTo(tabRect.right - 4, tabRect.bottom - 5)
      ..lineTo(tabRect.left + 4, tabRect.bottom - 5)
      ..close();
    canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            colors: [
              AppColors.neonCyan.withValues(alpha: 0.35 * glow),
              AppColors.neonCyan.withValues(alpha: 0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(tabRect));

    // Linha do gráfico
    canvas.drawPath(
        chartPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = AppColors.neonCyan.withValues(alpha: 0.9 * glow)
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);

    // Ponto final (topo)
    canvas.drawCircle(pts.last, 2.5,
        Paint()
          ..color = AppColors.neonCyan
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * glow));
    canvas.drawCircle(pts.last, 2, Paint()..color = Colors.white);

    // Seta de alta no canto superior direito
    final arrowPaint = Paint()
      ..color = AppColors.neonGreen.withValues(alpha: 0.9)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final ax = tabRect.right - 7;
    final ay = tabRect.top + 5;
    canvas.drawLine(Offset(ax, ay + 5), Offset(ax, ay), arrowPaint);
    canvas.drawLine(Offset(ax - 3, ay + 3), Offset(ax, ay), arrowPaint);
    canvas.drawLine(Offset(ax + 3, ay + 3), Offset(ax, ay), arrowPaint);
  }

  // ── Pescoço ──────────────────────────────────────────────────────────────────
  void _drawNeck(Canvas canvas, double cx, double cy, double w, double h) {
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
    canvas.drawRect(rect,
        Paint()
          ..shader = LinearGradient(
            colors: const [Color(0xFF1A3A6E), Color(0xFF071530)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(rect));
    canvas.drawRect(rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = AppColors.neonCyan.withValues(alpha: 0.5));
  }

  // ── Cabeça ───────────────────────────────────────────────────────────────────
  void _drawHead(Canvas canvas, double cx, double cy, double w, double h) {
    final rr = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: w, height: h),
        const Radius.circular(20));
    canvas.drawRRect(rr.shift(const Offset(4, 5)),
        Paint()..color = Colors.black.withValues(alpha: 0.5));
    canvas.drawRRect(rr,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.4),
            radius: 0.9,
            colors: const [Color(0xFF2A5AAA), Color(0xFF0D2050), Color(0xFF050F28)],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(rr.outerRect));
    canvas.drawRRect(rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AppColors.neonCyan.withValues(alpha: 0.8));
    // Visor
    final visor = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, cy + h * 0.05),
            width: w * 0.76,
            height: h * 0.42),
        const Radius.circular(12));
    canvas.drawRRect(visor,
        Paint()
          ..shader = LinearGradient(
            colors: [
              AppColors.neonCyan.withValues(alpha: 0.10),
              AppColors.neonCyan.withValues(alpha: 0.03),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(visor.outerRect));
    canvas.drawRRect(visor,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = AppColors.neonCyan.withValues(alpha: 0.4));
  }

  // ── Olhos ────────────────────────────────────────────────────────────────────
  void _drawEye(Canvas canvas, double cx, double cy, double r, double glow) {
    canvas.drawCircle(Offset(cx, cy), r * 1.5,
        Paint()
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * glow)
          ..color = AppColors.neonCyan.withValues(alpha: 0.3 * glow));
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()
          ..shader = RadialGradient(
            colors: [Colors.white.withValues(alpha: 0.9), AppColors.neonCyan, const Color(0xFF004466)],
            stops: const [0.0, 0.4, 1.0],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)));
    canvas.drawCircle(Offset(cx + r * 0.15, cy + r * 0.1), r * 0.35,
        Paint()..color = const Color(0xFF001A33));
    canvas.drawCircle(Offset(cx - r * 0.25, cy - r * 0.25), r * 0.18,
        Paint()..color = Colors.white.withValues(alpha: 0.85));
  }

  // ── Antena ───────────────────────────────────────────────────────────────────
  void _drawAntenna(Canvas canvas, double cx, double top, double h, double glow) {
    canvas.drawLine(Offset(cx, top + h), Offset(cx, top + h * 0.3),
        Paint()
          ..strokeWidth = 3
          ..color = AppColors.neonCyan.withValues(alpha: 0.8)
          ..strokeCap = StrokeCap.round);
    canvas.drawCircle(Offset(cx, top), 8,
        Paint()
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * glow)
          ..color = AppColors.neonCyan.withValues(alpha: 0.7 * glow));
    canvas.drawCircle(Offset(cx, top), 6,
        Paint()
          ..shader = RadialGradient(
            colors: [Colors.white, AppColors.neonCyan],
          ).createShader(Rect.fromCircle(center: Offset(cx, top), radius: 6)));
  }

  // ── Painel no peito ──────────────────────────────────────────────────────────
  void _drawChestPanel(Canvas canvas, double cx, double cy, double w, double h,
      double glow) {
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(7));
    canvas.drawRRect(rr,
        Paint()
          ..shader = LinearGradient(
            colors: [
              AppColors.neonCyan.withValues(alpha: 0.16 * glow),
              AppColors.neonCyan.withValues(alpha: 0.05 * glow),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(rect));
    canvas.drawRRect(rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = AppColors.neonCyan.withValues(alpha: 0.5 * glow));
    final lp = Paint()
      ..strokeWidth = 1
      ..color = AppColors.neonCyan.withValues(alpha: 0.35 * glow)
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 3; i++) {
      final y = rect.top + rect.height * (0.25 + i * 0.25);
      canvas.drawLine(Offset(rect.left + 5, y), Offset(rect.right - 5, y), lp);
    }
    canvas.drawCircle(Offset(cx, cy), 4,
        Paint()
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * glow)
          ..color = AppColors.neonCyan.withValues(alpha: 0.8 * glow));
    canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = AppColors.neonCyan);
  }

  // ── Reflexo especular ────────────────────────────────────────────────────────
  void _drawSpecular(Canvas canvas, double cx, double cy, double w, double h) {
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
    canvas.drawOval(rect,
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.white.withValues(alpha: 0.32), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(rect));
  }

  @override
  bool shouldRepaint(_Robot3DPainter old) => old.glowIntensity != glowIntensity;
}

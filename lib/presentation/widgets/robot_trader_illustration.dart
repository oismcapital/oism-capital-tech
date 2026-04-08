import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Ilustração estilizada de robô trader (vetor interno, sem asset externo).
class RobotTraderIllustration extends StatelessWidget {
  const RobotTraderIllustration({super.key, this.size = 200});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.92,
            height: size * 0.92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.35),
                  blurRadius: 36,
                  spreadRadius: 2,
                ),
              ],
              gradient: RadialGradient(
                colors: [
                  AppColors.neonCyan.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          CustomPaint(
            size: Size(size, size),
            painter: _RobotPainter(),
          ),
        ],
      ),
    );
  }
}

class _RobotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, 8), width: size.width * 0.55, height: size.height * 0.5),
      const Radius.circular(18),
    );

    final head = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, -size.height * 0.18), width: size.width * 0.48, height: size.height * 0.28),
      const Radius.circular(16),
    );

    final paintBody = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF111A2E),
          const Color(0xFF0B1224),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(body.outerRect);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.neonCyan.withValues(alpha: 0.85);

    canvas.drawRRect(body, paintBody);
    canvas.drawRRect(body, stroke);

    canvas.drawRRect(head, paintBody);
    canvas.drawRRect(head, stroke);

    final eyeL = Offset(center.dx - size.width * 0.1, center.dy - size.height * 0.2);
    final eyeR = Offset(center.dx + size.width * 0.1, center.dy - size.height * 0.2);
    final eyePaint = Paint()..color = AppColors.neonCyan;
    canvas.drawCircle(eyeL, 5, eyePaint);
    canvas.drawCircle(eyeR, 5, eyePaint);

    final mouth = Path()
      ..moveTo(center.dx - 18, center.dy - size.height * 0.12)
      ..quadraticBezierTo(center.dx, center.dy - size.height * 0.06, center.dx + 18, center.dy - size.height * 0.12);
    canvas.drawPath(
      mouth,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.neonCyan.withValues(alpha: 0.6),
    );

    final antenna = Path()
      ..moveTo(center.dx, center.dy - size.height * 0.33)
      ..lineTo(center.dx, center.dy - size.height * 0.42);
    canvas.drawPath(
      antenna,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = AppColors.neonCyan,
    );
    canvas.drawCircle(Offset(center.dx, center.dy - size.height * 0.44), 5, eyePaint);

    final armL = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(-size.width * 0.34, 10), width: 14, height: 52),
      const Radius.circular(8),
    );
    final armR = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(size.width * 0.34, 10), width: 14, height: 52),
      const Radius.circular(8),
    );
    canvas.drawRRect(armL, paintBody);
    canvas.drawRRect(armL, stroke);
    canvas.drawRRect(armR, paintBody);
    canvas.drawRRect(armR, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

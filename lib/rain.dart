import 'dart:math';
import 'package:flutter/material.dart';

/// Decorative particles use simulation time, so pause is automatic.
class RainPainter extends CustomPainter {
  RainPainter({required this.time, required this.intensity});
  final double time;
  final double intensity;
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: intensity * 0.4)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < (80 * intensity).round(); i++) {
      final x = random.nextDouble() * size.width;
      final y =
          (random.nextDouble() * size.height +
              time * (220 + random.nextDouble() * 160)) %
          size.height;
      canvas.drawLine(Offset(x, y), Offset(x - 3, y + 12), paint);
    }
  }

  @override
  bool shouldRepaint(RainPainter oldDelegate) =>
      oldDelegate.time != time || oldDelegate.intensity != intensity;
}

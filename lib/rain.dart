import 'dart:math';
import 'package:flutter/material.dart';

/// Decorative particles use simulation time, so pause is automatic.
class RainPainter extends CustomPainter {
  static final _streaks = _makeStreaks();
  static List<({double x, double y, double speed})> _makeStreaks() {
    final random = Random(42);
    return List.generate(
      80,
      (_) => (
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 220 + random.nextDouble() * 160,
      ),
    );
  }

  RainPainter({required this.time, required this.intensity});
  final double time;
  final double intensity;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: intensity * 0.4)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < (80 * intensity).round(); i++) {
      final drop = _streaks[i];
      final x = drop.x * size.width;
      final y = (drop.y * size.height + time * drop.speed) % size.height;
      canvas.drawLine(Offset(x, y), Offset(x - 3, y + 12), paint);
    }
  }

  @override
  bool shouldRepaint(RainPainter oldDelegate) =>
      oldDelegate.time != time || oldDelegate.intensity != intensity;
}

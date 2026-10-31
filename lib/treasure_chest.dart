import 'dart:math';
import 'package:flutter/material.dart';

/// Original vector artwork: crisp at any density, no additional image decode.
class TreasureChest extends StatelessWidget {
  const TreasureChest({
    super.key,
    required this.opened,
    this.animate = true,
    this.size = 144,
  });
  final bool opened, animate;
  final double size;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: opened ? 1 : 0),
        duration: animate ? const Duration(milliseconds: 420) : Duration.zero,
        curve: Curves.easeOutCubic,
        builder: (context, value, _) =>
            CustomPaint(painter: _ChestPainter(value)),
      ),
    ),
  );
}

class _ChestPainter extends CustomPainter {
  _ChestPainter(this.open);
  final double open;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 160, size.height / 160);
    final outline = Paint()
      ..color = const Color(0xFF66451F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeJoin = StrokeJoin.round;
    void box(Rect rect, Color color, double radius) {
      final shape = RRect.fromRectAndRadius(rect, Radius.circular(radius));
      canvas.drawRRect(shape, Paint()..color = color);
      canvas.drawRRect(shape, outline);
    }

    canvas.drawOval(
      const Rect.fromLTWH(19, 137, 122, 10),
      Paint()..color = const Color(0xFFBBCDB6).withValues(alpha: .5),
    );
    canvas.drawCircle(
      const Offset(80, 80),
      61,
      Paint()
        ..color = const Color(0xFFFFE7A0).withValues(alpha: .3 + open * .35),
    );
    box(const Rect.fromLTWH(24, 77, 112, 60), const Color(0xFFB47733), 9);
    box(const Rect.fromLTWH(34, 86, 92, 39), const Color(0xFFDDA453), 4);
    canvas.drawLine(
      const Offset(36, 105),
      const Offset(124, 105),
      Paint()
        ..color = const Color(0xFFC18B3F)
        ..strokeWidth = 2,
    );
    for (final x in [42.0, 109.0]) {
      box(Rect.fromLTWH(x, 78, 10, 58), const Color(0xFFFFD56B), 2);
    }
    // Lid pivots around its rear edge; contents appear only after it opens.
    canvas.save();
    canvas.translate(24, 77);
    canvas.rotate(-open * .40);
    box(Rect.fromLTWH(0, -37 - open * 12, 112, 37), const Color(0xFFEAC16C), 9);
    for (final x in [18.0, 85.0]) {
      box(
        Rect.fromLTWH(x, -37 - open * 12, 10, 37),
        const Color(0xFFFFDD80),
        2,
      );
    }
    canvas.restore();
    box(const Rect.fromLTWH(69, 74, 23, 28), const Color(0xFFFFDD80), 5);
    canvas.drawCircle(
      const Offset(80.5, 85),
      3,
      Paint()..color = const Color(0xFF66451F),
    );
    canvas.drawLine(
      const Offset(80.5, 85),
      const Offset(80.5, 93),
      Paint()
        ..color = const Color(0xFF66451F)
        ..strokeWidth = 3,
    );
    if (open > 0) {
      for (var i = 0; i < 3; i++) {
        final x = 62.0 + i * 23, y = 65 - sin(i + 1) * 23 * open;
        canvas.drawCircle(
          Offset(x, y),
          10 * open,
          Paint()..color = const Color(0xFFFFD154),
        );
        canvas.drawCircle(
          Offset(x, y),
          7 * open,
          Paint()
            ..color = const Color(0xFFAC771A)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }
    for (final point in [
      const Offset(19, 39),
      const Offset(137, 26),
      const Offset(145, 85),
    ]) {
      final sparkle = Path()
        ..moveTo(point.dx, point.dy - 7)
        ..lineTo(point.dx + 2, point.dy - 2)
        ..lineTo(point.dx + 7, point.dy)
        ..lineTo(point.dx + 2, point.dy + 2)
        ..lineTo(point.dx, point.dy + 7)
        ..lineTo(point.dx - 2, point.dy + 2)
        ..lineTo(point.dx - 7, point.dy)
        ..lineTo(point.dx - 2, point.dy - 2)
        ..close();
      canvas.drawPath(sparkle, Paint()..color = const Color(0xFFB57C20));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ChestPainter oldDelegate) =>
      oldDelegate.open != open;
}

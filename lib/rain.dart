import 'dart:math';
import 'package:flutter/material.dart';

class RainDrop {
  double x;
  double y;
  double speed;
  double length;

  RainDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
  });
}

class RainPainter extends CustomPainter {
  final List<RainDrop> drops;
  final double opacity;

  RainPainter({required this.drops, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (final drop in drops) {
      canvas.drawLine(
        Offset(drop.x, drop.y),
        Offset(drop.x - 2, drop.y + drop.length),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(RainPainter oldDelegate) => true;
}

class RainEffect extends StatefulWidget {
  final AnimationController gameController;
  final int skyPhase;

  const RainEffect({
    Key? key,
    required this.gameController,
    required this.skyPhase,
  }) : super(key: key);

  @override
  State<RainEffect> createState() => _RainEffectState();
}

class _RainEffectState extends State<RainEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _rainController;
  final List<RainDrop> _drops = [];
  final Random _random = Random();
  Size _lastSize = Size.zero;
  static const int _maxDrops = 150;

  @override
  void initState() {
    super.initState();
    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(days: 99),
    );
    _rainController.addListener(_tick);

    if (widget.gameController.isAnimating) {
      _rainController.forward();
    }
    widget.gameController.addStatusListener(_onGameStatus);
  }

  void _onGameStatus(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      if (!_rainController.isAnimating) _rainController.forward();
    } else if (status == AnimationStatus.dismissed ||
        status == AnimationStatus.completed) {
      _rainController.stop();
    }
  }

  void _initDrops(Size size) {
    _drops.clear();
    int count = _dropCount();
    for (int i = 0; i < count; i++) {
      _drops.add(_createDrop(size, randomY: true));
    }
  }

  int _dropCount() {
    if (widget.skyPhase < 2) return 0;
    return ((_maxDrops * (widget.skyPhase - 1)) ~/ (4)).clamp(0, _maxDrops);
  }

  RainDrop _createDrop(Size size, {bool randomY = false}) {
    return RainDrop(
      x: _random.nextDouble() * size.width,
      y: randomY ? _random.nextDouble() * size.height : -_random.nextDouble() * 40,
      speed: 600 + _random.nextDouble() * 400,
      length: 12 + _random.nextDouble() * 18,
    );
  }

  void _tick() {
    if (_lastSize == Size.zero) return;
    final int targetCount = _dropCount();

    while (_drops.length < targetCount) {
      _drops.add(_createDrop(_lastSize, randomY: true));
    }
    while (_drops.length > targetCount) {
      _drops.removeLast();
    }

    const double dt = 1 / 60;
    for (final drop in _drops) {
      drop.y += drop.speed * dt;
      if (drop.y > _lastSize.height) {
        drop.y = -drop.length;
        drop.x = _random.nextDouble() * _lastSize.width;
      }
    }
    setState(() {});
  }

  double _rainOpacity() {
    if (widget.skyPhase < 2) return 0.0;
    return ((widget.skyPhase - 1) / 4).clamp(0.0, 1.0);
  }

  @override
  void didUpdateWidget(RainEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gameController.isAnimating && !_rainController.isAnimating) {
      _rainController.forward();
    }
  }

  @override
  void dispose() {
    widget.gameController.removeStatusListener(_onGameStatus);
    _rainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (_lastSize != size) {
          _lastSize = size;
          if (_drops.isEmpty) _initDrops(size);
        }
        return IgnorePointer(
          child: CustomPaint(
            size: size,
            painter: RainPainter(drops: _drops, opacity: _rainOpacity()),
          ),
        );
      },
    );
  }
}

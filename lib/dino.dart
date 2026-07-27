import 'package:flutter/material.dart';
import 'constants.dart';
import 'game_object.dart';
import 'sprite.dart';

final dinoIdle = Sprite()
  ..imagePath = "assets/images/Dino  idle.png"
  ..imageWidth = 88
  ..imageHeight = 94;

final dinoRun1 = Sprite()
  ..imagePath = "assets/images/Dino run 1.png"
  ..imageWidth = 88
  ..imageHeight = 94;

final dinoRun2 = Sprite()
  ..imagePath = "assets/images/Dino run 2.png"
  ..imageWidth = 88
  ..imageHeight = 94;

final dinoJump = Sprite()
  ..imagePath = "assets/images/Dino Jump.png"
  ..imageWidth = 88
  ..imageHeight = 94;

final dinoDead = Sprite()
  ..imagePath = "assets/images/Dino Dead.png"
  ..imageWidth = 88
  ..imageHeight = 94;

enum DinoState {
  idle,
  jumping,
  running,
  dead,
}

class Dino extends GameObject {
  Sprite currentSprite = dinoIdle;
  double dispY = 0;
  double velY = 0;
  DinoState state = DinoState.idle;
  int _jumpCount = 0;
  static const int _maxJumps = 2;
  int frameDurationMs = 150;

  @override
  Widget render() {
    return _DinoWidget(state: state, imagePath: currentSprite.imagePath);
  }

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
      screenSize.width / 10,
      screenSize.height / 1.75 - currentSprite.imageHeight - dispY,
      currentSprite.imageWidth.toDouble(),
      currentSprite.imageHeight.toDouble(),
    );
  }

  @override
  void update(Duration lastUpdate, Duration? elapsedTime) {
    if (state == DinoState.idle) {
      currentSprite = dinoIdle;
      return;
    }

    if (state == DinoState.running) {
      try {
        currentSprite =
            (elapsedTime!.inMilliseconds ~/ frameDurationMs) % 2 == 0
                ? dinoRun1
                : dinoRun2;
      } catch (_) {
        currentSprite = dinoRun1;
      }
    } else if (state == DinoState.jumping) {
      currentSprite = dinoJump;
    }

    double elapsedTimeSeconds;
    try {
      elapsedTimeSeconds = (elapsedTime! - lastUpdate).inMilliseconds / 1000;
    } catch (_) {
      elapsedTimeSeconds = 0;
    }

    dispY += velY * elapsedTimeSeconds;
    if (dispY <= 0) {
      dispY = 0;
      velY = 0;
      _jumpCount = 0;
      state = DinoState.running;
    } else {
      velY -= gravity * elapsedTimeSeconds;
    }
  }

  void jump() {
    if (_jumpCount < _maxJumps) {
      state = DinoState.jumping;
      velY = _jumpCount == 0 ? jumpVelocity : jumpVelocity * 1.25;
      _jumpCount++;
    }
  }

  void die() {
    currentSprite = dinoDead;
    state = DinoState.dead;
  }
}

class _DinoWidget extends StatefulWidget {
  final DinoState state;
  final String imagePath;

  const _DinoWidget({required this.state, required this.imagePath});

  @override
  State<_DinoWidget> createState() => _DinoWidgetState();
}

class _DinoWidgetState extends State<_DinoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  DinoState? _lastState;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_DinoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == DinoState.jumping && _lastState != DinoState.jumping) {
      _pulseController.forward(from: 0.0).then((_) => _pulseController.reverse());
    }
    _lastState = widget.state;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(widget.imagePath);

    // Run sprites (Dino run 1/2) already face right — no flip needed.
    // Idle, jump, and dead sprites face left — flip them.
    bool needsFlip = widget.state != DinoState.running;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.cyanAccent.withValues(alpha: _pulseAnimation.value),
            BlendMode.srcATop,
          ),
          child: child,
        );
      },
      child: needsFlip ? Transform.flip(flipX: true, child: image) : image,
    );
  }
}

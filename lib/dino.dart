import 'package:flutter/widgets.dart';
import 'constants.dart';
import 'dino_avatar.dart';
import 'game_object.dart';

enum DinoState { idle, jumping, running, dead }

class Dino extends GameObject {
  double dispY = 0;
  double velY = 0;
  DinoState state = DinoState.idle;
  int _jumpCount = 0;
  double landingRemaining = 0;

  @override
  Widget render() => const DinoAvatar();

  @override
  Rect getRect(Size screenSize, double runDistance) => Rect.fromLTWH(
    screenSize.width / 10,
    screenSize.height / 1.75 - 94 - dispY,
    88,
    94,
  );

  @override
  void update(Duration lastUpdate, Duration elapsedTime) {
    if (state == DinoState.dead || state == DinoState.idle) return;
    final dt = ((elapsedTime - lastUpdate).inMicroseconds / 1000000).clamp(
      0.0,
      0.05,
    );
    landingRemaining = (landingRemaining - dt).clamp(0, 0.10);
    final wasAirborne = state == DinoState.jumping;
    dispY += velY * dt;
    if (dispY <= 0) {
      dispY = 0;
      velY = 0;
      _jumpCount = 0;
      state = DinoState.running;
      if (wasAirborne) landingRemaining = 0.10;
    } else {
      velY -= gravity * dt;
    }
  }

  void jump() {
    if (state == DinoState.dead || state == DinoState.idle || _jumpCount >= 2) {
      return;
    }
    state = DinoState.jumping;
    landingRemaining = 0;
    // The second jump stays inside the logical viewport even near the apex.
    velY = _jumpCount == 0 ? jumpVelocity : jumpVelocity * 1.1;
    _jumpCount++;
  }

  void die() {
    state = DinoState.dead;
  }
}

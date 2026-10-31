import 'dart:math';

import 'package:flutter/widgets.dart';

import 'cactus.dart';
import 'constants.dart';
import 'dino.dart';
import 'game_object.dart';
import 'ptera.dart';

enum RunState { menu, playing, paused, gameOver }

enum Difficulty {
  easy('Easy', 28, 40, 1.65, 900),
  normal('Normal', 36, 52, 1.45, 650);

  const Difficulty(
    this.label,
    this.startSpeed,
    this.maxSpeed,
    this.obstacleSeconds,
    this.birdDistance,
  );

  final String label;
  final double startSpeed;
  final double maxSpeed;
  final double obstacleSeconds;
  final double birdDistance;
}

class Collectible {
  Collectible(this.location);
  final Offset location;

  Rect rect(double distance) => Rect.fromCenter(
    center: Offset(
      (location.dx - distance) * worlToPixelRatio,
      GameEngine.floorY - location.dy,
    ),
    width: 28,
    height: 28,
  );
}

/// Simulation uses one logical viewport on every device. Rendering scales it.
/// The UI owns the ticker; paused/background time is never fed into this model.
class GameEngine extends ChangeNotifier {
  GameEngine({Random? random}) : _random = random ?? Random();

  static const viewport = Size(400, 720);
  static const floorY = 720 / 1.75;
  static const stepSeconds = 1 / 120;
  final Random _random;

  RunState state = RunState.menu;
  Difficulty difficulty = Difficulty.easy;
  Dino dino = Dino();
  double distance = 0;
  double speed = Difficulty.easy.startSpeed;
  double time = 0;
  double _accumulator = 0;
  double _nextObstacle = 95;
  double _nextStar = 65;
  int runStars = 0;
  final List<GameObject> obstacles = [];
  final List<Collectible> stars = [];

  int get score => distance.floor();
  int get skyPhase => (distance ~/ 180) % skyGradients.length;
  int get terrain => (distance ~/ 500) % 3;

  void start(Difficulty selected) {
    difficulty = selected;
    dino = Dino()..state = DinoState.running;
    distance = 0;
    speed = selected.startSpeed;
    time = 0;
    runStars = 0;
    _accumulator = 0;
    _nextObstacle = 95;
    _nextStar = 65;
    obstacles.clear();
    stars.clear();
    state = RunState.playing;
    notifyListeners();
  }

  void pause() {
    if (state != RunState.playing) return;
    state = RunState.paused;
    _accumulator = 0;
    notifyListeners();
  }

  void resume() {
    if (state != RunState.paused) return;
    state = RunState.playing;
    notifyListeners();
  }

  void home() {
    state = RunState.menu;
    dino = Dino();
    obstacles.clear();
    stars.clear();
    distance = 0;
    time = 0;
    _accumulator = 0;
    notifyListeners();
  }

  bool jump() {
    if (state != RunState.playing) return false;
    final before = dino.velY;
    dino.jump();
    return dino.velY != before;
  }

  /// Cap catch-up work after a dropped frame; never teleport past obstacles.
  void advance(double seconds) {
    if (state != RunState.playing || !seconds.isFinite || seconds <= 0) return;
    _accumulator += min(seconds, 0.1);
    while (_accumulator >= stepSeconds && state == RunState.playing) {
      _step();
      _accumulator -= stepSeconds;
    }
    notifyListeners();
  }

  void _step() {
    final previous = Duration(microseconds: (time * 1000000).round());
    time += stepSeconds;
    final elapsed = Duration(microseconds: (time * 1000000).round());
    dino.update(previous, elapsed);
    speed = min(difficulty.maxSpeed, speed + acceleration * stepSeconds);
    distance += speed * stepSeconds;

    if (_nextObstacle - distance < viewport.width / worlToPixelRatio + 20) {
      final isBird =
          distance >= difficulty.birdDistance && _random.nextInt(4) == 0;
      final GameObject object = isBird
          ? Ptera(worldLocation: Offset(_nextObstacle, 20))
          : Cactus(worldLocation: Offset(_nextObstacle, 0), random: _random);
      obstacles.add(object);
      final width = object.getRect(viewport, distance).width / worlToPixelRatio;
      // Reserve enough time for two jumps and a landing at the highest speed.
      _nextObstacle +=
          width +
          difficulty.maxSpeed *
              (difficulty.obstacleSeconds + _random.nextDouble() * 0.4);
    }
    if (_nextStar - distance < 55) {
      // Stars stay close to the ground and are optional; no risky mandatory path.
      stars.add(Collectible(Offset(_nextStar, 70)));
      _nextStar += 30 + _random.nextDouble() * 22;
    }

    for (final object in obstacles) {
      object.update(previous, elapsed);
    }
    obstacles.removeWhere((o) => o.getRect(viewport, distance).right < -20);
    final player = hitbox(dino.getRect(viewport, distance), 0.55, 0.78);
    for (final object in obstacles) {
      if (player.overlaps(
        hitbox(object.getRect(viewport, distance), 0.6, 0.75),
      )) {
        state = RunState.gameOver;
        dino.die();
        return;
      }
    }
    stars.removeWhere((star) {
      final rect = star.rect(distance);
      if (player.overlaps(rect)) {
        runStars++;
        return true;
      }
      return rect.right < 0;
    });
  }

  static Rect hitbox(Rect rect, double widthFactor, double heightFactor) =>
      Rect.fromCenter(
        center: rect.center,
        width: rect.width * widthFactor,
        height: rect.height * heightFactor,
      );
}

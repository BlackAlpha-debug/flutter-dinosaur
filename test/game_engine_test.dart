import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dinosaur/dino.dart';
import 'package:flutter_dinosaur/game_engine.dart';

void main() {
  late GameEngine game;
  setUp(() => game = GameEngine(random: Random(7)));
  tearDown(() => game.dispose());

  test('restart resets airborne state and simulation clocks', () {
    game.start(Difficulty.normal);
    game.jump();
    game.advance(0.08);
    expect(game.dino.dispY, greaterThan(0));
    game.start(Difficulty.easy);
    expect(game.time, 0);
    expect(game.distance, 0);
    expect(game.dino.velY, 0);
    expect(game.dino.dispY, 0);
    expect(game.runPickups, 0);
    expect(game.jump(), isTrue);
    game.advance(0.02);
    expect(game.dino.dispY, greaterThan(0));
  });

  test('pause ignores elapsed time and inputs, resume preserves run', () {
    game.start(Difficulty.easy);
    game.advance(0.1);
    game.pause();
    final distance = game.distance;
    game.advance(500);
    expect(game.distance, distance);
    expect(game.jump(), isFalse);
    game.resume();
    game.advance(1 / 60);
    expect(game.distance - distance, lessThan(1));
  });

  test('double jump is limited and landing restores jumps', () {
    game.start(Difficulty.easy);
    expect(game.jump(), isTrue);
    game.advance(0.1);
    expect(game.jump(), isTrue);
    final velocity = game.dino.velY;
    expect(game.jump(), isFalse);
    expect(game.dino.velY, velocity);
    for (var i = 0; i < 120; i++) {
      game.dino.update(
        Duration(milliseconds: i * 16),
        Duration(milliseconds: (i + 1) * 16),
      );
    }
    expect(game.dino.state, DinoState.running);
    expect(game.jump(), isTrue);
  });

  test('frame catch-up is bounded and invalid deltas are ignored', () {
    game.start(Difficulty.easy);
    game.advance(1000);
    expect(game.distance, lessThan(4));
    final distance = game.distance;
    game.advance(double.nan);
    game.advance(-1);
    expect(game.distance, distance);
  });

  test('simulation is consistent across 30 and 120 Hz rendering', () {
    final slow = GameEngine(random: Random(1))..start(Difficulty.easy);
    final fast = GameEngine(random: Random(1))..start(Difficulty.easy);
    for (var i = 0; i < 30; i++) {
      slow.advance(1 / 30);
    }
    for (var i = 0; i < 120; i++) {
      fast.advance(1 / 120);
    }
    expect(slow.distance, closeTo(fast.distance, 0.3));
    expect(slow.speed, closeTo(fast.speed, 0.01));
    slow.dispose();
    fast.dispose();
  });

  test('small obstacles always have positive collision boxes', () {
    final rect = GameEngine.hitbox(
      const Rect.fromLTWH(0, 0, 34, 70),
      0.6,
      0.75,
    );
    expect(rect.width, greaterThan(0));
    expect(rect.height, greaterThan(0));
    expect(rect.width, lessThan(34));
  });

  test('double jumping near the apex keeps the character on screen', () {
    final dino = Dino()..state = DinoState.running;
    dino.jump();
    var elapsed = Duration.zero;
    while (dino.velY > 0) {
      final next = elapsed + const Duration(microseconds: 8333);
      dino.update(elapsed, next);
      elapsed = next;
    }
    dino.jump();
    for (var i = 0; i < 180; i++) {
      final next = elapsed + const Duration(microseconds: 8333);
      dino.update(elapsed, next);
      elapsed = next;
      expect(dino.getRect(GameEngine.viewport, 0).top, greaterThanOrEqualTo(0));
    }
  });

  test('an unattended run ends on collision and remains frozen', () {
    game.start(Difficulty.easy);
    for (var i = 0; i < 1000 && game.state == RunState.playing; i++) {
      game.advance(1 / 60);
    }
    expect(game.state, RunState.gameOver);
    final score = game.score;
    game.advance(0.1);
    expect(game.score, score);
    expect(game.jump(), isFalse);
    expect(game.dino.state, DinoState.dead);
  });

  test('long runs cap speed and recycle safely with spaced obstacles', () {
    game.start(Difficulty.normal);
    for (var i = 0; i < 18000; i++) {
      // Move the player above obstacles to exercise a long uninterrupted run.
      game.dino.dispY = 350;
      game.dino.velY = 0;
      game.advance(1 / 60);
      expect(game.obstacles.length, lessThan(5));
      expect(game.coins.length, lessThan(12));
      if (game.obstacles.length > 1) {
        final a = game.obstacles[0].getRect(GameEngine.viewport, game.distance);
        final b = game.obstacles[1].getRect(GameEngine.viewport, game.distance);
        expect(
          b.left - a.right,
          greaterThanOrEqualTo(
            Difficulty.normal.maxSpeed *
                    Difficulty.normal.obstacleSeconds *
                    10 -
                0.01,
          ),
        );
      }
    }
    expect(game.state, RunState.playing);
    expect(game.speed, Difficulty.normal.maxSpeed);
    expect(game.terrain, inInclusiveRange(0, 2));
    expect(game.skyPhase, inInclusiveRange(0, 4));
  });
}

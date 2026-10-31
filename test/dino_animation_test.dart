import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dinosaur/dino.dart';
import 'package:flutter_dinosaur/dino_animation.dart';
import 'package:flutter_dinosaur/dino_avatar.dart';
import 'package:flutter_dinosaur/dino_catalog.dart';
import 'package:flutter_dinosaur/dino_shop_page.dart';
import 'package:flutter_dinosaur/game_engine.dart';
import 'package:flutter_dinosaur/player_progress.dart';

void main() {
  test('stride visits all six poses and loops with world movement', () {
    expect(
      [
        for (var i = 0; i < 6; i++)
          dinoFrame(distance: i * 20 / 6 + .01, running: true),
      ],
      [0, 1, 2, 3, 4, 5],
    );
    expect(dinoFrame(distance: 20, running: true), 0);
    expect(dinoFrame(distance: 10, running: true), 3);
    expect(dinoFrame(distance: double.nan, running: true), 1);
  });

  test('jump and landing override feet; reduced motion holds neutral', () {
    expect(dinoFrame(distance: 10, jumping: true, running: true), 6);
    expect(dinoFrame(distance: 10, landing: true, running: true), 7);
    expect(dinoFrame(distance: 10, jumping: true, reduceMotion: true), 1);
    expect(dinoFrame(distance: 10, landing: true, reduceMotion: true), 1);
  });

  test('pause freezes pose and landing timer; restart clears both', () {
    final game = GameEngine(random: Random(4))..start(Difficulty.easy);
    game.dino.landingRemaining = .1;
    game.advance(.02);
    game.pause();
    final distance = game.distance, remaining = game.dino.landingRemaining;
    game.advance(20);
    expect(game.distance, distance);
    expect(game.dino.landingRemaining, remaining);
    game.resume();
    game.advance(.1);
    expect(game.dino.landingRemaining, 0);
    game.start(Difficulty.easy);
    expect(game.dino.landingRemaining, 0);
    game.dispose();
  });

  test('landing crouch triggers once and jumping interrupts it', () {
    final dino = Dino()
      ..state = DinoState.jumping
      ..dispY = 1
      ..velY = -100;
    dino.update(Duration.zero, const Duration(milliseconds: 20));
    expect(dino.state, DinoState.running);
    expect(dino.landingRemaining, .1);
    dino.update(Duration.zero, const Duration(milliseconds: 20));
    expect(dino.landingRemaining, closeTo(.08, .0001));
    dino.jump();
    expect(dino.landingRemaining, 0);
    expect(dino.state, DinoState.jumping);
  });

  for (final character in dinoCatalog) {
    testWidgets('${character.name} runs, hops and stops in its preview', (
      tester,
    ) async {
      final progress = PlayerProgress()..effects = false;
      await tester.pumpWidget(
        MaterialApp(
          home: DinoPreviewPage(progress: progress, character: character),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Run preview'));
      await tester.pump(const Duration(milliseconds: 200));
      var avatar = tester.widget<DinoAvatar>(find.byType(DinoAvatar));
      expect(avatar.running, true);
      await tester.tap(find.text('Try a hop'));
      await tester.pump(const Duration(milliseconds: 200));
      avatar = tester.widget<DinoAvatar>(find.byType(DinoAvatar));
      expect(avatar.jumping, true);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text('Stop running'));
      await tester.pumpAndSettle();
      expect(tester.widget<DinoAvatar>(find.byType(DinoAvatar)).running, false);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      progress.dispose();
    });
  }

  testWidgets('device reduced animation disables motion preview controls', (
    tester,
  ) async {
    final progress = PlayerProgress();
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: DinoPreviewPage(progress: progress, character: dinoCatalog.first),
      ),
    );
    await tester.pumpAndSettle();
    for (final label in ['Run preview', 'Try a hop']) {
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, label))
            .onPressed,
        isNull,
      );
    }
    await tester.pumpWidget(const SizedBox());
    progress.dispose();
  });
}

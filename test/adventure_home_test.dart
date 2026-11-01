import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dinosaur/adventure_home.dart';
import 'package:flutter_dinosaur/dino_avatar.dart';
import 'package:flutter_dinosaur/game_engine.dart';
import 'package:flutter_dinosaur/game_scene.dart';
import 'package:flutter_dinosaur/player_progress.dart';

void main() {
  testWidgets(
    'home hop is playful without starting or spending; all destinations work',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final progress = PlayerProgress();
      final actions = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdventureHome(
              progress: progress,
              difficulty: Difficulty.easy,
              onPlay: () => actions.add('play'),
              onShop: () => actions.add('shop'),
              onCollection: () => actions.add('collection'),
              onGifts: () => actions.add('gifts'),
              onSettings: () => actions.add('settings'),
              onGrownUps: () => actions.add('grown-ups'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Try a hop with Sprout'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        tester.widget<DinoAvatar>(find.byType(DinoAvatar).first).jumping,
        true,
      );
      expect(progress.coins, 0);
      expect(actions, isEmpty);
      await tester.pumpAndSettle();
      for (final label in [
        'Dino Shop',
        'My Dinosaurs',
        'Weekly Gifts · Gift ready',
      ]) {
        final target = find.bySemanticsLabel(label);
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        expect(
          tester.getSemantics(target),
          matchesSemantics(label: label, isButton: true, hasTapAction: true),
        );
        await tester.tap(target);
      }
      for (final label in ['Settings', 'For grown-ups', 'Play · Easy']) {
        final target = find.text(label);
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        await tester.tap(target);
      }
      expect(actions, [
        'shop',
        'collection',
        'gifts',
        'settings',
        'grown-ups',
        'play',
      ]);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      progress.dispose();
      semantics.dispose();
    },
  );

  testWidgets('home respects device reduced animation', (tester) async {
    final progress = PlayerProgress();
    void noop() {}
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: Scaffold(
          body: AdventureHome(
            progress: progress,
            difficulty: Difficulty.easy,
            onPlay: noop,
            onShop: noop,
            onCollection: noop,
            onGifts: noop,
            onSettings: noop,
            onGrownUps: noop,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tap Sprout to hop!'), findsNothing);
    expect(
      tester.widget<DinoAvatar>(find.byType(DinoAvatar).first).jumping,
      false,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    progress.dispose();
  });

  testWidgets('coin feedback follows simulation time and expires', (
    tester,
  ) async {
    final game = GameEngine()..start(Difficulty.easy);
    game.coins.add(Collectible(const Offset(8.4, 50)));
    game.advance(.02);
    Widget scene() => MaterialApp(
      home: SizedBox(
        width: 400,
        height: 720,
        child: GameScene(game: game, effects: true),
      ),
    );
    await tester.pumpWidget(scene());
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(6));
    final collectedAt = game.lastPickupTime;
    game.pause();
    game.advance(100);
    expect(game.lastPickupTime, collectedAt);
    game.resume();
    for (var i = 0; i < 6; i++) {
      game.advance(.1);
    }
    await tester.pumpWidget(scene());
    expect(find.byIcon(Icons.star_rounded), findsNothing);
    game.start(Difficulty.easy);
    expect(game.lastPickupTime, double.negativeInfinity);
    await tester.pumpWidget(const SizedBox());
    game.dispose();
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dinosaur/game_engine.dart';
import 'package:flutter_dinosaur/main.dart';
import 'package:flutter_dinosaur/player_progress.dart';
import 'package:flutter_dinosaur/game_audio.dart';

class RecordingAudio implements GameAudio {
  final sounds = <String>[];
  int stops = 0;
  @override
  Future<void> play(String sound) async {
    sounds.add(sound);
  }

  @override
  Future<void> stop() async {
    stops++;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  testWidgets('stars bank once, scores save on pause and audio stops', (
    tester,
  ) async {
    final game = GameEngine();
    final progress = PlayerProgress();
    final audio = RecordingAudio();
    await tester.pumpWidget(MyApp(progress: progress, audio: audio));
    // Use a directly controlled engine to collect a known reachable star.
    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(engine: game, progress: progress, audio: audio),
      ),
    );
    await tester.ensureVisible(find.text('Play · Easy'));
    await tester.tap(find.text('Play · Easy'));
    await tester.pump();
    game.coins.add(Collectible(const Offset(8.4, 50)));
    game.advance(0.02);
    game.pause();
    await tester.pump();
    expect(progress.stars, 1);
    expect(audio.sounds, contains('star'));
    final best = progress.best(Difficulty.easy);
    game.resume();
    game.advance(0.1);
    game.pause();
    await tester.pump();
    expect(progress.stars, 1);
    expect(progress.best(Difficulty.easy), greaterThanOrEqualTo(best));
    expect(audio.stops, greaterThan(0));
    expect(find.textContaining('pickups ×'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await progress.flush();
    game.dispose();
    progress.dispose();
  });

  testWidgets('reset progress requires confirmation', (tester) async {
    final progress = PlayerProgress()..addStars(15);
    await tester.pumpWidget(MyApp(progress: progress));
    await tester.ensureVisible(find.text('For grown-ups'));
    await tester.tap(find.text('For grown-ups'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Reset progress'));
    await tester.tap(find.text('Reset progress'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep progress'));
    await tester.pumpAndSettle();
    expect(progress.stars, 15);
    await tester.ensureVisible(find.text('Reset progress'));
    await tester.tap(find.text('Reset progress'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Erase progress'));
    await tester.pumpAndSettle();
    expect(progress.stars, 0);
    await tester.pumpWidget(const SizedBox());
    await progress.flush();
    progress.dispose();
  });

  testWidgets('start, pause, settings and resume preserve the run', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Little Dino'), findsOneWidget);
    expect(find.text('Force Kill Dino'), findsNothing);
    await tester.ensureVisible(find.text('Play · Easy'));
    await tester.tap(find.text('Play · Easy'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byTooltip('Pause game'));
    await tester.pump();
    expect(find.text('Take a little break'), findsOneWidget);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Normal'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Keep going'), findsOneWidget);
    await tester.tap(find.text('Keep going'));
    await tester.pump();
    expect(find.text('Take a little break'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('background pauses and foreground requires deliberate resume', (
    tester,
  ) async {
    final game = GameEngine();
    await tester.pumpWidget(MaterialApp(home: GameScreen(engine: game)));
    await tester.ensureVisible(find.text('Play · Easy'));
    await tester.tap(find.text('Play · Easy'));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(game.state, RunState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(game.state, RunState.paused);
    await tester.pumpWidget(const SizedBox());
    game.dispose();
  });

  testWidgets('small screen and large text menu/settings do not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: const GameScreen(),
      ),
    );
    await tester.ensureVisible(find.text('Settings'));
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dinosaur/game_engine.dart';
import 'package:flutter_dinosaur/main.dart';
import 'package:flutter_dinosaur/privacy_policy_page.dart';

class ImmediatePolicyBundle extends CachingAssetBundle {
  static final text = File('docs/PRIVACY_POLICY.md').readAsStringSync();
  @override
  Future<ByteData> load(String key) => rootBundle.load(key);
  @override
  Future<String> loadString(String key, {bool cache = true}) =>
      key == 'docs/PRIVACY_POLICY.md'
      ? SynchronousFuture(text)
      : rootBundle.loadString(key, cache: cache);
}

void main() {
  final cases = <({String name, Size size, double scale, EdgeInsets insets})>[
    (
      name: 'small phone with large text/notch',
      size: const Size(320, 480),
      scale: 2,
      insets: const EdgeInsets.only(top: 28, bottom: 24),
    ),
    (
      name: 'narrow split-screen',
      size: const Size(280, 600),
      scale: 1.5,
      insets: EdgeInsets.zero,
    ),
    (
      name: 'tablet portrait',
      size: const Size(800, 1280),
      scale: 1.5,
      insets: EdgeInsets.zero,
    ),
    (
      name: 'tablet landscape',
      size: const Size(1280, 800),
      scale: 1.5,
      insets: EdgeInsets.zero,
    ),
    (
      name: 'short landscape window',
      size: const Size(640, 320),
      scale: 1.5,
      insets: EdgeInsets.zero,
    ),
    (
      name: 'foldable window with large text',
      size: const Size(720, 600),
      scale: 2,
      insets: EdgeInsets.zero,
    ),
  ];

  for (final scenario in cases) {
    testWidgets('${scenario.name}: play, pause, settings and privacy fit', (
      tester,
    ) async {
      tester.view.physicalSize = scenario.size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final game = GameEngine();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          builder: (context, child) => DefaultAssetBundle(
            bundle: ImmediatePolicyBundle(),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scenario.scale),
                padding: scenario.insets,
                viewPadding: scenario.insets,
              ),
              child: child!,
            ),
          ),
          home: GameScreen(engine: game),
        ),
      );
      await tester.ensureVisible(find.text('Play · Easy'));
      await tester.tap(find.text('Play · Easy'));
      await tester.pump();
      expect(game.state, RunState.playing);
      game.distance = 123456;
      game.runStars = 1234;
      game.pause();
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Settings'));
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Back home'));
      await tester.tap(find.text('Back home'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('For grown-ups'));
      await tester.tap(find.text('For grown-ups'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Full privacy policy'));
      await tester.tap(find.text('Full privacy policy'));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(PrivacyPolicyPage), findsOneWidget);
      expect(find.textContaining('muzammiljawad6@gmail.com'), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      game.dispose();
    });
  }

  testWidgets('resizing a running window pauses without losing progress', (
    tester,
  ) async {
    final game = GameEngine();
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: GameScreen(engine: game)));
    await tester.ensureVisible(find.text('Play · Easy'));
    await tester.tap(find.text('Play · Easy'));
    await tester.pump();
    game.advance(0.1);
    final distance = game.distance;
    tester.view.physicalSize = const Size(700, 500);
    await tester.pump();
    expect(game.state, RunState.paused);
    expect(game.distance, distance);
    await tester.pumpWidget(const SizedBox());
    tester.view.resetPhysicalSize();
    game.dispose();
  });
}

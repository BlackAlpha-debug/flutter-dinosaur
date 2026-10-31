import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dinosaur/game_engine.dart';
import 'package:flutter_dinosaur/ptera.dart';
import 'package:flutter_dinosaur/sprite_atlas.dart';

void main() {
  test('wingbeat visits all poses and loops without changing its hitbox', () {
    final bird = Ptera(worldLocation: const Offset(40, 20));
    final bounds = bird.getRect(GameEngine.viewport, 0);
    for (var i = 0; i < 8; i++) {
      bird.update(Duration.zero, Duration(milliseconds: i * 80));
      expect(bird.frame, i);
      expect(bird.getRect(GameEngine.viewport, 0), bounds);
    }
    bird.update(Duration.zero, const Duration(milliseconds: 640));
    expect(bird.frame, 0);
    expect(bounds.size, const Size(92, 80));
  });

  test(
    'pause freezes the flying obstacle and resume continues its wingbeat',
    () {
      final game = GameEngine()..start(Difficulty.easy);
      final bird = Ptera(worldLocation: const Offset(40, 20));
      game.obstacles.add(bird);
      game.advance(.1);
      final pose = bird.frame;
      game.pause();
      game.advance(100);
      expect(bird.frame, pose);
      game.resume();
      game.advance(.08);
      expect(bird.frame, isNot(pose));
      game.dispose();
    },
  );

  testWidgets('device reduced motion holds level wings', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: SizedBox(width: 92, height: 80, child: PteraAvatar(frame: 5)),
        ),
      ),
    );
    expect(tester.widget<SpriteAtlas>(find.byType(SpriteAtlas)).frame, 2);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('all eight flight poses render with the shared atlas', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: RepaintBoundary(
            key: boundaryKey,
            child: ColoredBox(
              color: const Color(0xFFFFF9EC),
              child: SizedBox(
                width: 640,
                height: 320,
                child: Wrap(
                  children: [
                    for (var i = 0; i < 8; i++)
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: PteraAvatar(frame: i),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => precacheImage(
        ResizeImage.resizeIfNeeded(
          1536,
          null,
          const AssetImage(PteraAvatar.asset),
        ),
        tester.element(find.byType(PteraAvatar).first),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SpriteAtlas), findsNWidgets(8));
    expect(tester.takeException(), isNull);
    if (const bool.fromEnvironment('CAPTURE_PTERA')) {
      await tester.runAsync(() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          'screenshots/ptera-wingbeat.png',
        ).writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }
    await tester.pumpWidget(const SizedBox());
  });
}

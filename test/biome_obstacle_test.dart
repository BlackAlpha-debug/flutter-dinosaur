import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dinosaur/cactus.dart';
import 'package:flutter_dinosaur/game_engine.dart';
import 'package:flutter_dinosaur/game_scene.dart';
import 'package:flutter_dinosaur/sprite_atlas.dart';
import 'package:flutter_dinosaur/world_scenery.dart';
import 'support/fixed_variant_random.dart';

void main() {
  testWidgets('queued ground obstacles change skin with the current world', (
    tester,
  ) async {
    final game = GameEngine()..start(Difficulty.easy);
    final obstacle = Cactus(
      worldLocation: const Offset(20, 0),
      random: FixedVariantRandom(0),
    );
    final size = obstacle.getRect(GameEngine.viewport, 0).size;
    game.obstacles.add(obstacle);
    for (var terrain = 0; terrain < 3; terrain++) {
      game.distance = terrain * 500.0;
      await tester.pumpWidget(
        MaterialApp(home: GameScene(game: game, effects: false)),
      );
      await tester.pumpAndSettle();
      final skin = tester.widget<GroundObstacleAvatar>(
        find.byType(GroundObstacleAvatar),
      );
      expect(skin.terrain, terrain);
      expect(obstacle.getRect(GameEngine.viewport, game.distance).size, size);
      expect(
        obstacle.getRect(GameEngine.viewport, game.distance).bottom,
        GameEngine.floorY,
      );
      if (terrain > 0) {
        final atlas = tester
            .widgetList<SpriteAtlas>(find.byType(SpriteAtlas))
            .firstWhere((sprite) => sprite.asset.contains('obstacles-'));
        expect(atlas.asset, GroundObstacleAvatar.assets[terrain - 1]);
        expect(atlas.stretch, true);
      }
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    game.dispose();
  });

  testWidgets('all six sizes render for cacti, rocks and ice slabs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 450);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final boundary = GlobalKey();
    await tester.runAsync(() async {
      final font = FontLoader('ObstaclePreviewRoboto')
        ..addFont(rootBundle.load('assets/fonts/roboto-bold.ttf'));
      await font.load();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'ObstaclePreviewRoboto'),
        home: Scaffold(
          body: RepaintBoundary(
            key: boundary,
            child: Column(
              children: [
                for (var terrain = 0; terrain < 3; terrain++)
                  SizedBox(
                    height: 150,
                    child: ColoredBox(
                      color: [
                        const Color(0xFFE9F1DB),
                        const Color(0xFFFFE5CE),
                        const Color(0xFFE3F4FF),
                      ][terrain],
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                worldNames[terrain],
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          for (var variant = 0; variant < 6; variant++)
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    height: 110,
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: SizedBox(
                                        width: cacti[variant].imageWidth
                                            .toDouble(),
                                        height: cacti[variant].imageHeight
                                            .toDouble(),
                                        child: GroundObstacleAvatar(
                                          terrain: terrain,
                                          variant: variant,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${cacti[variant].imageWidth} × ${cacti[variant].imageHeight}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      final context = tester.element(find.byType(GroundObstacleAvatar).first);
      await Future.wait([
        for (final asset in GroundObstacleAvatar.assets)
          precacheImage(
            ResizeImage.resizeIfNeeded(1536, null, AssetImage(asset)),
            context,
          ),
        for (final sprite in cacti)
          precacheImage(AssetImage(sprite.imagePath), context),
      ]);
    });
    await tester.pumpAndSettle();
    expect(find.byType(GroundObstacleAvatar), findsNWidgets(18));
    expect(tester.takeException(), isNull);
    if (const bool.fromEnvironment('CAPTURE_OBSTACLES')) {
      await tester.runAsync(() async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await render.toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          'screenshots/biome-obstacles.png',
        ).writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }
    await tester.pumpWidget(const SizedBox());
  });
}

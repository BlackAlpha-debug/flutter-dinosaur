import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dinosaur/cactus.dart';
import 'package:flutter_dinosaur/dino_avatar.dart';
import 'package:flutter_dinosaur/game_engine.dart';
import 'package:flutter_dinosaur/game_scene.dart';
import 'package:flutter_dinosaur/world_scenery.dart';
import 'support/fixed_variant_random.dart';

void main() {
  for (var terrain = 0; terrain < 3; terrain++) {
    testWidgets(
      '${worldNames[terrain]} uses its painted clearing at the same ground line',
      (tester) async {
        tester.view.physicalSize = const Size(400, 720);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final game = GameEngine()..start(Difficulty.easy);
        game.distance = terrain * 500 + 30;
        final cactus = Cactus(
          worldLocation: Offset(game.distance + 27, 0),
          random: FixedVariantRandom(0),
        );
        game.obstacles.add(cactus);
        for (var i = 0; i < 3; i++) {
          game.coins.add(
            Collectible(Offset(game.distance + 16 + i * 4, i == 1 ? 100 : 65)),
          );
        }
        final capture = GlobalKey();
        await tester.runAsync(() async {
          final font = FontLoader('GroundPreviewRoboto')
            ..addFont(rootBundle.load('assets/fonts/roboto-bold.ttf'));
          await font.load();
          final icons = FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
          await icons.load();
        });
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'GroundPreviewRoboto'),
            home: Scaffold(
              body: RepaintBoundary(
                key: capture,
                child: GameScene(game: game, effects: false),
              ),
            ),
          ),
        );
        await tester.runAsync(() async {
          final context = tester.element(find.byType(GameScene));
          await Future.wait([
            precacheImage(
              ResizeImage.resizeIfNeeded(
                1000,
                null,
                AssetImage(worldArtwork[terrain]),
              ),
              context,
            ),
            precacheImage(
              ResizeImage.resizeIfNeeded(
                1536,
                null,
                const AssetImage('assets/runtime/sprout-run.png'),
              ),
              context,
            ),
            precacheImage(AssetImage(cactus.sprite.imagePath), context),
            if (terrain > 0)
              precacheImage(
                ResizeImage.resizeIfNeeded(
                  1536,
                  null,
                  AssetImage(GroundObstacleAvatar.assets[terrain - 1]),
                ),
                context,
              ),
          ]);
        });
        await tester.pumpAndSettle();
        expect(
          tester.getBottomLeft(find.byType(DinoAvatar)).dy,
          closeTo(720 * .78, .01),
        );
        expect(
          cactus.getRect(GameEngine.viewport, game.distance).bottom,
          GameEngine.floorY,
        );
        expect(find.text(worldNames[terrain]), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (const bool.fromEnvironment('CAPTURE_GROUNDS')) {
          await tester.runAsync(() async {
            final boundary =
                capture.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              'screenshots/ground-${['jungle', 'canyon', 'ice'][terrain]}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.pumpWidget(const SizedBox());
        game.dispose();
      },
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';

import 'constants.dart';
import 'game_object.dart';
import 'sprite.dart';
import 'sprite_atlas.dart';

List<Sprite> cacti = [
  Sprite()
    ..imagePath = "assets/images/cacti/cacti_group.png"
    ..imageWidth = 104
    ..imageHeight = 100,
  Sprite()
    ..imagePath = "assets/images/cacti/cacti_large_1.png"
    ..imageWidth = 50
    ..imageHeight = 100,
  Sprite()
    ..imagePath = "assets/images/cacti/cacti_large_2.png"
    ..imageWidth = 98
    ..imageHeight = 100,
  Sprite()
    ..imagePath = "assets/images/cacti/cacti_small_1.png"
    ..imageWidth = 34
    ..imageHeight = 70,
  Sprite()
    ..imagePath = "assets/images/cacti/cacti_small_2.png"
    ..imageWidth = 68
    ..imageHeight = 70,
  Sprite()
    ..imagePath = "assets/images/cacti/cacti_small_3.png"
    ..imageWidth = 102
    ..imageHeight = 70,
];

class Cactus extends GameObject {
  final Sprite sprite;
  final Offset worldLocation;

  Cactus({required this.worldLocation, Random? random})
    : sprite = cacti[(random ?? Random()).nextInt(cacti.length)];

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
      (worldLocation.dx - runDistance) * worlToPixelRatio,
      screenSize.height / 1.75 - sprite.imageHeight,
      sprite.imageWidth.toDouble(),
      sprite.imageHeight.toDouble(),
    );
  }

  @override
  Widget render() => renderForTerrain(0);

  // The scene chooses the current biome so queued obstacles change appearance
  // with the world, while their original model dimensions remain identical.
  Widget renderForTerrain(int terrain) =>
      GroundObstacleAvatar(terrain: terrain, variant: cacti.indexOf(sprite));
}

class GroundObstacleAvatar extends StatelessWidget {
  const GroundObstacleAvatar({
    super.key,
    required this.terrain,
    required this.variant,
  });
  final int terrain, variant;
  static const assets = [
    'assets/runtime/obstacles-rocks.png',
    'assets/runtime/obstacles-ice.png',
  ];
  static const _layouts = [0, 1, 2, 1, 2, 0];
  // Source pixel bounds of the three upright arrangements in 443.5px cells.
  // Cropping transparent margins fills each original obstacle rectangle instead
  // of leaving an invisible collision region around a small picture.
  static const _rockBounds = [
    Rect.fromLTRB(58, 121, 419, 408),
    Rect.fromLTRB(148, 95, 329, 409),
    Rect.fromLTRB(63, 127, 395, 410),
  ];
  static const _iceBounds = [
    Rect.fromLTRB(51, 69, 436, 434),
    Rect.fromLTRB(140, 55, 328, 435),
    Rect.fromLTRB(66, 79, 394, 435),
  ];

  Widget _cactus() {
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(Color(0xFF2E7D32), BlendMode.srcATop),
      child: Image.asset(cacti[variant].imagePath),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (terrain == 0) return _cactus();
    final frame = _layouts[variant];
    final bounds = (terrain == 1 ? _rockBounds : _iceBounds)[frame];
    return SpriteAtlas(
      asset: assets[terrain - 1],
      frame: frame,
      stretch: true,
      sourceBounds: Rect.fromLTRB(
        bounds.left / 443.5,
        bounds.top / 443.5,
        bounds.right / 443.5,
        bounds.bottom / 443.5,
      ),
      placeholder: _cactus(),
    );
  }
}

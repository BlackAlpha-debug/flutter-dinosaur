import 'package:flutter/material.dart';
import 'constants.dart';

const groundArtwork = [
  'assets/images/Grass Ground.png',
  'assets/runtime/stone-ground-deep.png',
  'assets/runtime/ice-ground-deep.png',
];

class GroundSurface extends StatelessWidget {
  const GroundSurface({
    super.key,
    required this.terrain,
    required this.distance,
    required this.groundY,
  });
  final int terrain;
  final double distance, groundY;

  static ImageProvider<Object> imageFor(int terrain) =>
      ResizeImage.resizeIfNeeded(
        terrain > 0 ? 1000 : null,
        null,
        AssetImage(groundArtwork[terrain]),
      );

  @override
  Widget build(BuildContext context) {
    final pixels = distance * worlToPixelRatio;
    final tile = (pixels / 500).floor();
    return Stack(
      children: [
        // Preserve the original mud. Stone and ice each use one continuous
        // textured image from the walkable ledge to below the viewport.
        if (terrain == 0)
          Positioned(
            left: 0,
            right: 0,
            top: groundY + 15,
            bottom: 0,
            child: const ColoredBox(color: Color(0xFF98724A)),
          ),
        for (var i = 0; i < 2; i++)
          Positioned(
            left: i * 500 - pixels % 500,
            // Measured planes: stone ~570px, ice ~715px in 1254px images,
            // rendered at 500px. Both align to the existing collision ground.
            top: groundY - [425.0, 227.0, 285.0][terrain],
            width: 500,
            height: 500,
            child: Transform.flip(
              // Matching mirrored edges prevent hard repeat seams.
              flipX: terrain > 0 && (tile + i).isOdd,
              child: Image(
                image: imageFor(terrain),
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
              ),
            ),
          ),
      ],
    );
  }
}

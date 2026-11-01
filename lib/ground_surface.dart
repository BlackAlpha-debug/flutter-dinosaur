import 'package:flutter/material.dart';
import 'constants.dart';

const groundArtwork = [
  'assets/images/Grass Ground.png',
  'assets/runtime/stone-ground-deep.png',
  'assets/images/Ice Ground.png',
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
        terrain == 1 ? 1000 : null,
        null,
        AssetImage(groundArtwork[terrain]),
      );

  @override
  Widget build(BuildContext context) {
    final pixels = distance * worlToPixelRatio;
    final tile = (pixels / 500).floor();
    return Stack(
      children: [
        // Preserve the original mud and ice fill. Stone uses the same continuous
        // textured image from the walkable ledge to below the viewport.
        if (terrain != 1)
          Positioned(
            left: 0,
            right: 0,
            top: groundY + 15,
            bottom: 0,
            child: ColoredBox(
              color: terrain == 0
                  ? const Color(0xFF98724A)
                  : const Color(0xFF91BFC7),
            ),
          ),
        for (var i = 0; i < 2; i++)
          Positioned(
            left: i * 500 - pixels % 500,
            // Stone's measured top plane is ~570px in a 1254px image, rendered
            // at 500px. This aligns its walkable surface to the original ground.
            top: groundY - [425.0, 227.0, 455.0][terrain],
            width: 500,
            height: 500,
            child: Transform.flip(
              // Matching mirrored edges prevent a hard repeat seam in the rock.
              flipX: terrain == 1 && (tile + i).isOdd,
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

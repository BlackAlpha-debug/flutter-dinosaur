import 'dart:math';
import 'package:flutter/material.dart';

const worldNames = ['Jungle Trail', 'Sunset Canyon', 'Crystal Valley'];
const worldArtwork = [
  'assets/runtime/home-jungle.png',
  'assets/runtime/world-canyon.png',
  'assets/runtime/world-ice.png',
];

/// Slow background drift contrasts with the faster foreground trail. The
/// overscan avoids seams and never changes the playable world coordinates.
class WorldScenery extends StatelessWidget {
  const WorldScenery({
    super.key,
    required this.terrain,
    required this.distance,
    required this.skyPhase,
    required this.effects,
  });
  final int terrain, skyPhase;
  final double distance;
  final bool effects;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final artwork = SizedBox(
        key: ValueKey(terrain),
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: ClipRect(
          child: OverflowBox(
            minWidth: constraints.maxHeight * 4 / 3,
            maxWidth: constraints.maxHeight * 4 / 3,
            minHeight: constraints.maxHeight,
            maxHeight: constraints.maxHeight,
            child: Transform.translate(
              offset: Offset(effects ? sin(distance / 140) * 65 : 0, 0),
              child: Image.asset(
                worldArtwork[terrain],
                fit: BoxFit.cover,
                cacheWidth: 1000,
                excludeFromSemantics: true,
              ),
            ),
          ),
        ),
      );
      return Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: effects
                ? const Duration(milliseconds: 650)
                : Duration.zero,
            child: artwork,
          ),
          if (skyPhase >= 2)
            ColoredBox(
              color: const Color(
                0xFF28214B,
              ).withValues(alpha: (skyPhase - 1) * .10),
            ),
        ],
      );
    },
  );
}

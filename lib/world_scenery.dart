import 'package:flutter/material.dart';

const worldNames = ['Grass Trail', 'Stone Trail', 'Ice Trail'];

/// Original open sky, sun/moon and small clouds. Illustrated landscapes are
/// reserved for the home screen and are not part of the playable scene.
class WorldScenery extends StatelessWidget {
  const WorldScenery({
    super.key,
    required this.distance,
    required this.skyPhase,
    required this.effects,
  });
  final int skyPhase;
  final double distance;
  final bool effects;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned(
        right: 38,
        top: 65,
        child: Icon(
          skyPhase >= 3 ? Icons.nightlight_round : Icons.wb_sunny_rounded,
          size: 55,
          color: const Color(0xFFFFE9A8),
        ),
      ),
      for (var i = 0; i < 4; i++)
        Positioned(
          left: ((i * 150 + 70 - (effects ? distance * 1.5 : 0)) % 600) - 100,
          top: 100.0 + (i % 2) * 55,
          child: Image.asset(
            'assets/images/cloud filled.png',
            width: 92,
            height: 45,
            cacheWidth: 184,
            excludeFromSemantics: true,
          ),
        ),
    ],
  );
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'dino_catalog.dart';

/// One transparent, aligned runtime sprite with subtle procedural animation.
/// Every visual offset stays small relative to the forgiving collision box.
class DinoAvatar extends StatelessWidget {
  const DinoAvatar({
    super.key,
    this.time = 0,
    this.running = false,
    this.jumping = false,
    this.effects = true,
    this.color = 0,
    this.characterId = 'sprout',
  });
  final double time;
  final bool running;
  final bool jumping;
  final bool effects;
  final int color;
  final String characterId;

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      characterById(characterId).asset,
      fit: BoxFit.contain,
      cacheWidth: 320,
      filterQuality: FilterQuality.medium,
    );
    if (color != 0 && characterId == 'sprout') {
      image = ColorFiltered(
        colorFilter: ColorFilter.matrix(_hue(color == 1 ? -0.9 : 2.2)),
        child: image,
      );
    }
    if (!effects) return image;
    final bounce = running ? sin(time * 20) : 0.0;
    return Transform.translate(
      offset: Offset(0, -bounce.abs() * 2),
      child: Transform.rotate(
        angle: jumping ? -0.07 : bounce * 0.025,
        child: image,
      ),
    );
  }

  // Standard luminance-preserving hue rotation; white eyes remain white.
  List<double> _hue(double angle) {
    final c = cos(angle), s = sin(angle);
    return [
      .213 + c * .787 - s * .213,
      .715 - c * .715 - s * .715,
      .072 - c * .072 + s * .928,
      0,
      0,
      .213 - c * .213 + s * .143,
      .715 + c * .285 + s * .140,
      .072 - c * .072 - s * .283,
      0,
      0,
      .213 - c * .213 - s * .787,
      .715 - c * .715 + s * .715,
      .072 + c * .928 + s * .072,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'dino_animation.dart';
import 'dino_catalog.dart';
import 'sprite_atlas.dart';

/// Static portraits in menus; a shared, decoded atlas for gameplay/preview.
class DinoAvatar extends StatelessWidget {
  const DinoAvatar({
    super.key,
    this.time = 0,
    this.distance = 0,
    this.running = false,
    this.jumping = false,
    this.landing = false,
    this.effects = true,
    this.color = 0,
    this.characterId = 'sprout',
  });
  final double time;
  final double distance;
  final bool running;
  final bool jumping;
  final bool landing;
  final bool effects;
  final int color;
  final String characterId;

  @override
  Widget build(BuildContext context) {
    final character = characterById(characterId);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    Widget image = Image.asset(
      character.asset,
      fit: BoxFit.contain,
      cacheWidth: 320,
      filterQuality: FilterQuality.medium,
    );
    if (running || jumping || landing) {
      final frame = dinoFrame(
        distance: distance,
        running: running,
        jumping: jumping,
        landing: landing,
        reduceMotion: reduceMotion,
      );
      image = SpriteAtlas(
        asset: character.animationAsset,
        baseline: character.footBaselines[frame] / 443.5,
        frame: frame,
        placeholder: image,
      );
    }
    if (color != 0 && characterId == 'sprout') {
      image = ColorFiltered(
        colorFilter: ColorFilter.matrix(_hue(color == 1 ? -0.9 : 2.2)),
        child: image,
      );
    }
    // Poses already contain recoil/contact. Extra per-frame bobbing would
    // detach planted feet from the ground. Only a small airborne tilt remains.
    if (!effects || reduceMotion || !jumping) return image;
    return Transform.rotate(angle: -0.04, child: image);
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

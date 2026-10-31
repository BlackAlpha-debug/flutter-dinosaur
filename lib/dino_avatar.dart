import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dino_animation.dart';
import 'dino_catalog.dart';

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
      image = _AtlasSprite(
        asset: character.animationAsset,
        footBaselines: character.footBaselines,
        frame: dinoFrame(
          distance: distance,
          running: running,
          jumping: jumping,
          landing: landing,
          reduceMotion: reduceMotion,
        ),
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

class _AtlasSprite extends StatefulWidget {
  const _AtlasSprite({
    required this.asset,
    required this.footBaselines,
    required this.frame,
    required this.placeholder,
  });
  final String asset;
  final List<double> footBaselines;
  final int frame;
  final Widget placeholder;

  @override
  State<_AtlasSprite> createState() => _AtlasSpriteState();
}

class _AtlasSpriteState extends State<_AtlasSprite> {
  ImageStream? _stream;
  ImageInfo? _info;
  late final _listener = ImageStreamListener(_loaded);

  void _loaded(ImageInfo info, bool synchronousCall) {
    final previous = _info;
    setState(() => _info = info);
    previous?.dispose();
  }

  void _resolve() {
    // 384 pixels per cell is sufficient for the 240dp preview; no per-frame
    // decoding, file reads or independent tickers during the run.
    final next = ResizeImage.resizeIfNeeded(
      1536,
      null,
      AssetImage(widget.asset),
    ).resolve(createLocalImageConfiguration(context));
    if (_stream?.key == next.key) return;
    _stream?.removeListener(_listener);
    _info?.dispose();
    _info = null;
    _stream = next..addListener(_listener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant _AtlasSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset) _resolve();
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    _info?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _info == null
      ? widget.placeholder
      : CustomPaint(
          painter: _AtlasPainter(
            _info!.image,
            widget.frame,
            widget.footBaselines[widget.frame] / 443.5,
          ),
        );
}

class _AtlasPainter extends CustomPainter {
  _AtlasPainter(this.image, this.frame, this.footBaseline);
  final ui.Image image;
  final int frame;
  final double footBaseline;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = image.width / 4, cellHeight = image.height / 2;
    final source = Rect.fromLTWH(
      frame % 4 * cellWidth,
      frame ~/ 4 * cellHeight,
      cellWidth,
      cellHeight,
    ).deflate(0.5); // Avoid sampling a neighboring cell at fractional edges.
    final side = min(size.width, size.height);
    final destination = Rect.fromLTWH(
      (size.width - side) / 2,
      size.height - side * footBaseline,
      side,
      side,
    );
    canvas.drawImageRect(
      image,
      source,
      destination,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(covariant _AtlasPainter oldDelegate) =>
      oldDelegate.image != image ||
      oldDelegate.frame != frame ||
      oldDelegate.footBaseline != footBaseline;
}

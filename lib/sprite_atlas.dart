import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Cached transparent 4x2 atlas shared by dinosaurs and flying obstacles.
class SpriteAtlas extends StatefulWidget {
  const SpriteAtlas({
    super.key,
    required this.asset,
    this.baseline = 1,
    this.offset = Offset.zero,
    this.sourceBounds = const Rect.fromLTWH(0, 0, 1, 1),
    this.stretch = false,
    required this.frame,
    required this.placeholder,
  });
  final String asset;
  final double baseline;
  final Offset offset;
  final Rect sourceBounds;
  final bool stretch;
  final int frame;
  final Widget placeholder;

  @override
  State<SpriteAtlas> createState() => _SpriteAtlasState();
}

class _SpriteAtlasState extends State<SpriteAtlas> {
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
  void didUpdateWidget(covariant SpriteAtlas oldWidget) {
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
            widget.baseline,
            widget.offset,
            widget.sourceBounds,
            widget.stretch,
          ),
        );
}

class _AtlasPainter extends CustomPainter {
  _AtlasPainter(
    this.image,
    this.frame,
    this.footBaseline,
    this.offset,
    this.sourceBounds,
    this.stretch,
  );
  final ui.Image image;
  final int frame;
  final double footBaseline;
  final Offset offset;
  final Rect sourceBounds;
  final bool stretch;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = image.width / 4, cellHeight = image.height / 2;
    final source = Rect.fromLTWH(
      (frame % 4 + sourceBounds.left) * cellWidth,
      (frame ~/ 4 + sourceBounds.top) * cellHeight,
      sourceBounds.width * cellWidth,
      sourceBounds.height * cellHeight,
    ).deflate(0.5); // Avoid sampling a neighboring cell at fractional edges.
    final side = min(size.width, size.height);
    final drawWidth = stretch ? size.width : side;
    final drawHeight = stretch ? size.height : side;
    final destination = Rect.fromLTWH(
      (size.width - drawWidth) / 2 + drawWidth * offset.dx,
      size.height - drawHeight * footBaseline + drawHeight * offset.dy,
      drawWidth,
      drawHeight,
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
      oldDelegate.footBaseline != footBaseline ||
      oldDelegate.offset != offset ||
      oldDelegate.sourceBounds != sourceBounds ||
      oldDelegate.stretch != stretch;
}

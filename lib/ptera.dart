import 'package:flutter/widgets.dart';
import 'constants.dart';
import 'game_object.dart';
import 'sprite_atlas.dart';

/// A complete 640ms wingbeat, driven only by the simulation clock.
int pteraFrame(Duration elapsed) => (elapsed.inMicroseconds ~/ 80000) % 8;

class Ptera extends GameObject {
  Ptera({required this.worldLocation});
  final Offset worldLocation;
  int frame = 0;

  @override
  Rect getRect(Size screenSize, double runDistance) => Rect.fromLTWH(
    (worldLocation.dx - runDistance) * worlToPixelRatio,
    4 / 7 * screenSize.height - 80 - worldLocation.dy,
    92,
    80,
  );

  @override
  Widget render() => PteraAvatar(frame: frame);

  @override
  void update(Duration lastUpdate, Duration elapsedTime) {
    frame = pteraFrame(elapsedTime);
  }
}

class PteraAvatar extends StatelessWidget {
  const PteraAvatar({super.key, required this.frame});
  final int frame;
  static const asset = 'assets/runtime/ptera-flight.png';
  // Measured eye anchors remove generated row-to-row body movement while
  // preserving wing travel. Offsets are source pixels divided by cell size.
  static const _anchors = [
    Offset(6, 0),
    Offset(3.5, 0),
    Offset(-2, 0),
    Offset(-3.5, 0),
    Offset(-6, 32.5),
    Offset(-3.5, 33.5),
    Offset(-1, 35.5),
    Offset(6.5, 36.5),
  ];
  @override
  Widget build(BuildContext context) {
    final pose = MediaQuery.disableAnimationsOf(context) ? 2 : frame % 8;
    return SpriteAtlas(
      asset: asset,
      frame: pose,
      offset: _anchors[pose] / 443.5,
      placeholder: const SizedBox.expand(),
    );
  }
}

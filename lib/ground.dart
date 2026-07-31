import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'game_object.dart';
import 'sprite.dart';

final grassGround = Sprite()
  ..imagePath = "assets/images/Grass Ground.png"
  ..imageWidth = 500
  ..imageHeight = 500;

final stoneGround = Sprite()
  ..imagePath = "assets/images/Stone Ground.png"
  ..imageWidth = 500
  ..imageHeight = 500;

final iceGround = Sprite()
  ..imagePath = "assets/images/Ice Ground.png"
  ..imageWidth = 500
  ..imageHeight = 500;

final _groundTypes = [grassGround, stoneGround, iceGround];
final _surfaceOffsets = [425.0, 460.0, 455.0];

Sprite groundSprite = grassGround;
double groundSurfaceOffset = 425.0;
double _targetOffset = 425.0;

void updateGroundType(double runDistance) {
  int index = (runDistance ~/ 500) % 3;
  groundSprite = _groundTypes[index];
  _targetOffset = _surfaceOffsets[index];
  double diff = _targetOffset - groundSurfaceOffset;
  if (diff.abs() > 0.5) {
    groundSurfaceOffset += diff * 0.15;
  } else {
    groundSurfaceOffset = _targetOffset;
  }
}

class Ground extends GameObject {
  final Offset worldLocation;

  Ground({required this.worldLocation});

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
      (worldLocation.dx - runDistance) * worlToPixelRatio,
      screenSize.height / 1.75 - groundSurfaceOffset,
      groundSprite.imageWidth.toDouble(),
      groundSprite.imageHeight.toDouble(),
    );
  }

  @override
  Widget render() {
    return Image.asset(groundSprite.imagePath);
  }
}

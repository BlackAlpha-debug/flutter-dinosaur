import 'dart:math';

/// Caps simulation/render notifications at 60 per second on 90/120/144 Hz
/// displays while preserving elapsed time and the engine's fixed physics step.
class FrameClock {
  Duration? _previous;
  double _carry = 0;
  static const framesPerSecond = 60;

  void reset() {
    _previous = null;
    _carry = 0;
  }

  double consume(Duration elapsed) {
    final previous = _previous;
    _previous = elapsed;
    if (previous == null) return 0;
    final delta = (elapsed - previous).inMicroseconds / 1000000;
    if (delta <= 0) return 0;
    _carry += min(delta, 0.1);
    // Ticker timestamps have microsecond precision; allow one microsecond of
    // rounding so a 60 Hz display does not alternate between missed/double frames.
    final frames = ((_carry + 0.000001) * framesPerSecond).floor();
    if (frames == 0) return 0;
    final seconds = frames / framesPerSecond;
    _carry = max(-0.000001, _carry - seconds);
    return seconds;
  }
}

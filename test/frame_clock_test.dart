import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dinosaur/frame_clock.dart';

void main() {
  for (final hz in [30, 60, 90, 120, 144]) {
    test(
      '$hz Hz display keeps elapsed time and renders at most 60 times/s',
      () {
        final clock = FrameClock();
        var rendered = 0;
        var total = 0.0;
        for (var i = 0; i <= hz * 2; i++) {
          final dt = clock.consume(
            Duration(microseconds: (i * 1000000 / hz).round()),
          );
          total += dt;
          if (dt > 0) rendered++;
        }
        expect(total, closeTo(2, 1 / 60));
        expect(rendered, lessThanOrEqualTo(120));
        expect(rendered, greaterThanOrEqualTo(hz < 60 ? hz * 2 : 118));
      },
    );
  }
  test(
    'reset discards background time and long stalls have bounded catch-up',
    () {
      final clock = FrameClock();
      clock.consume(Duration.zero);
      expect(
        clock.consume(const Duration(seconds: 30)),
        lessThanOrEqualTo(0.1),
      );
      clock.reset();
      expect(clock.consume(const Duration(seconds: 200)), 0);
      expect(
        clock.consume(const Duration(seconds: 200, milliseconds: 17)),
        closeTo(1 / 60, 1e-6),
      );
    },
  );
}

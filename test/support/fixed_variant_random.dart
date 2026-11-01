import 'dart:math';

/// Deterministic obstacle choice for visual fixtures; never used by the app.
class FixedVariantRandom implements Random {
  FixedVariantRandom(this.variant);
  final int variant;
  @override
  int nextInt(int max) => variant % max;
  @override
  double nextDouble() => .5;
  @override
  bool nextBool() => true;
}

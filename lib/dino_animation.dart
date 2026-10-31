/// Atlas layout: six run poses, tucked airborne pose, then landing crouch.
/// Distance comes from the simulation, so pause/death cannot advance the feet.
int dinoFrame({
  required double distance,
  bool running = false,
  bool jumping = false,
  bool landing = false,
  bool reduceMotion = false,
}) {
  if (reduceMotion) return 1;
  if (jumping) return 6;
  if (landing) return 7;
  if (!running || !distance.isFinite) return 1;
  // One stride per 200 logical pixels; 8.4–17.4 frames/s at game speeds.
  return ((distance / 20 * 6).floor()) % 6;
}

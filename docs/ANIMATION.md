# Dinosaur animation upgrade

The existing avatars used one transparent illustration with bounce/tilt. This
upgrade introduces a per-character sprite atlas with six running poses, a jump
pose and a landing pose. Original character illustrations remain for static
shop cards and menus.

## Acceptance criteria

- All four characters visibly alternate their feet during a run.
- Preserve each character's colors, face, silhouette and right-facing direction.
- One consistent frame box and ground baseline; no clipped tails, frills or sails.
- Running cadence follows world speed. Jumping holds an airborne pose and landing
  briefly settles before the running cycle resumes.
- Animation uses simulation time and freezes when paused/backgrounded/game over.
- Reduced-effects mode keeps the essential foot cycle but removes decorative
  bounce/squash; OS reduced-animation mode can hold a neutral frame.
- Preview controls demonstrate the same run/jump frames as gameplay.
- Every character shares existing physics/hitboxes. Sprite choice never changes
  jump height, speed, collection reach or collision fairness.

## Work phases

1. Create and inspect transparent 4×2 sprite atlases using built-in imagegen;
   preserve source artwork and record prompts/provenance.
2. Implement deterministic pose selection, speed-dependent foot cadence, landing
   state and live run/jump previews. Test timing, pause and reduced-motion behavior.
3. Render contact sheets/actual previews, inspect them, run existing regression
   tests and Android/native/browser checks; commit and push verified changes as
   BlackAlpha-debug. Android Studio and emulator remain closed.

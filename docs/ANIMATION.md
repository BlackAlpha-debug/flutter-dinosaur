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

## Asset provenance and implementation

Created November 1, 2026 with built-in imagegen, editing each original character
portrait as its identity reference. Four final `assets/runtime/*-run.png` files
are 1774×887 RGBA, with six running frames followed by jump and landing poses.
Rejected sheets with grid marks or a nose crossing a cell boundary were replaced.
The original generated outputs and static portraits were retained.

Common prompt: production transparent 2:1 sprite atlas, four equal columns and
two equal rows, one complete right-facing dinosaur per square cell, no grid/text/
scenery/shadows. Preserve face, proportions, colors and silhouette from reference.
Lock head/torso/tail scale. Run poses: contact-A, recoil-A, passing-A, contact-B,
recoil-B, passing-B; then tucked jump and soft crouched landing. Alternate feet
and opposing arms. Keep generous transparent margins around noses/tails/species
features; no overlap between cells. Bramble/Nova revisions explicitly requested
70–75% character width inside each cell to avoid edge clipping.

Sprites decode once through Flutter's image cache at 1536px sheet width. A source
rectangle selects each frame; there is no per-frame decoding or independent game
animation ticker. Measured foot baselines keep contact frames on the same ground.
Each six-frame stride covers 200 logical pixels, giving 8.4–17.4 frames/second
across the existing speed range. Landing lasts 100ms of simulation time and a
new jump interrupts it immediately. Collision boxes and physics are unchanged.

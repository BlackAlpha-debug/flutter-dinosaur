# Home and first-play review — November 1, 2026

Audience: ages 6–8. Goal: make starting an adventure understandable and inviting.
No claim of improved retention or child appeal can be established without testing
with children and parents.

## Captured baseline

Fresh 390×844 captures from this review, not cached screenshots:

1. **Home — usable, weak invitation.** [Screenshot](../screenshots/home-audit/01-home-before.png).
   The static portrait floats on an empty background. The instruction card and
   separate text blocks push Play down. Small outlined shop/collection controls
   give little visual sense of the characters and rewards inside. Large Play
   and plain language are strengths; enlarged text/scroll and screen-reader
   behavior require separate checks.
2. **First play — clear controls, weak composition.** [Screenshot](../screenshots/home-audit/02-first-play-before.png).
   Jump, pause and gold are understandable, but unused underground occupies much
   of the view and reduces the visible sense of an adventure. The capture alone
   does not establish timing, animation quality or physical-device performance.

## Implementation phases

1. Add original illustrated scenery for the home stage, preserving character
   identities and the existing green/cream palette.
2. Build a tappable selected-character stage, prominent Play, picture-led shop
   and collection cards, a clear gift destination, compact instructions, and
   accessible settings/grown-ups actions. Respect reduced effects/motion.
3. Improve playfield camera composition without changing physics, collision
   boxes or reward amounts. Verify layout, interactions and existing flows,
   capture the result, build an APK and commit/push as BlackAlpha-debug.

## Research grounding

- [Google: Designing engaging apps](https://developers.google.com/building-for-kids/designing-engaging-apps):
  simple consistent navigation, large touch targets, essential visual feedback,
  important content first, and testing assumptions with children/parents.
- [NN/g: Designing for Kids — Cognitive Considerations](https://www.nngroup.com/articles/kids-cognition/):
  research including ages 6–8 supports clear goals and specific visual
  instructions. This informs the design; it does not validate this game.

The phone was unavailable for the initial capture and was reconnected later.
Browser captures and automated checks provide the design baseline; the final APK
will also be installed on the connected phone. Child/parent play-testing remains.

## Playfield scope added during implementation

The owner also requested a more amusing, less monotonous game screen. The three
existing terrain stages now get distinct illustrated scenery: Jungle Trail,
Sunset Canyon and Crystal Valley. Their existing distance progression is retained.
Slow background drift, a 650ms scenery crossfade and small coin sparkles add visual
feedback. All are bounded, simulation-driven where applicable and respect the
extra-effects/device reduced-animation setting. All objects and ground move by
the same camera offset; collision coordinates and reward rules remain unchanged.

## New artwork provenance

Built-in imagegen, November 1, 2026. All three final images are 1448×1086 RGB/RGBA
landscapes; originals retained in the tool output folder and copied into runtime:

- `assets/runtime/home-jungle.png`: Sprout portrait used only as style reference.
  Prompt: bright storybook prehistoric clearing, cyan sky, soft clouds, layered
  teal mountains, mint hills, waterfall, jungle leaves, orange flowers and stones
  at the far edges, open calm center, grassy platform near the lower quarter.
  Bold clean contours, rounded shapes, glossy shading; no characters, text, UI,
  coins or props. Full-bleed 4:3 scenery.
- `assets/runtime/world-canyon.png`: home jungle used as style reference; warm
  peach/gold sky, apricot sandstone mesas, lavender distant mountains, turquoise
  river, fern silhouettes at edges and a pale sandstone clearing in the lower
  quarter. No characters, text/UI, coins, cacti, sun or moon discs.
- `assets/runtime/world-ice.png`: same reference/style; periwinkle/cyan sky,
  snowy violet mountains, frozen waterfall/lake, lavender firs, mint ferns,
  rounded turquoise crystals and snowbanks framing an open ice clearing below
  the lower quarter. No characters, text/UI, coins, sun or moon discs.

The three outputs were inspected before use. Background decode width is capped
at 1000px and shared between home/game for the jungle asset. The home hop uses
the existing poses, with no independent perpetual animation loop.

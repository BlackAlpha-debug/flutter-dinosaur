# Home and first-play review — November 1, 2026

## Classic gameplay scenery restored — 1.4.3+11

The owner requested removal of the illustrated gameplay landscapes and confirmed
restoring the original scrolling ground strips. The home screen remains as
approved. Gameplay now shows the original sky gradient, sun/moon and small clouds,
with Grass Trail, Stone Trail and Ice Trail labels. Original grass/mud and ice
surfaces are restored. Canyon/crystal landscape source files remain in the
repository as history but are no longer bundled or rendered in gameplay.
The home jungle is still bundled exclusively for the home screen.

The stone ground is a new full-depth tile inspired by `assets/images/Stone Ground.png`.
`assets/runtime/stone-ground-deep.png` supplies both its rocky walking ledge and
the entire visible underside. No flat grey rectangle sits beneath it. Alternating
mirrored tiles share identical boundary pixels to avoid a hard scrolling seam.
The visual walking plane is aligned to the same logical ground; the new rock/ice
obstacles, character poses, physics, jump timing and rewards remain unchanged.

### Stone artwork provenance

Created November 1, 2026 with built-in imagegen, using the original Stone Ground
image as a reference. Final runtime file: `assets/runtime/stone-ground-deep.png`,
1254×1254 RGBA. The generated original was preserved and copied into the repo.
Prompt: improve the original side-scrolling stone surface into a seamless square
terrain tile; transparent sky above a continuous near-horizontal limestone ledge,
a narrow pale top plane with tiny moss seams, and connected irregular chunky
grey/cream/blue-grey rock all the way to the bottom. Include cracks, chips,
pebbles, darker crevices, varied shading and geological layers; no flat grey
fill, regular brick grid, scenery, actors, props, labels, borders or bottom edge.
The output's measured walking plane is approximately source row 570, rendered
at a 227px offset in each 500px tile. Runtime decode width is capped at 1000px.

The current `ground-*.png` captures show this revision. Earlier comparisons and
the sections below are historical iterations, not the current gameplay scenery.

## Biome obstacle follow-up — 1.4.2+10

Ground obstacles now match the current world: jungle cacti, warm canyon rock
blocks and upright crystal-valley ice slabs. Each has the same six original
width/height combinations. Three illustrated arrangements (single, pair and a
three-piece cluster with mixed heights) are fitted into those existing boxes.
The world selects the skin while rendering, so queued obstacles also change
with the scenery; no old-world cactus persists into the canyon or ice stage.
The flying obstacle is unchanged. Both themed atlases are prepared when a run
starts to avoid a late image decode at the first world change.

[All variants](../screenshots/biome-obstacles.png),
[canyon rocks](../screenshots/ground-canyon.png),
[three-slab ice cluster](../screenshots/ground-ice.png).
These are actual Flutter renders of deterministic test fixtures. Reproduce:
`flutter test --dart-define=CAPTURE_OBSTACLES=true --dart-define=CAPTURE_GROUNDS=true test/biome_obstacle_test.dart test/world_ground_test.dart`.

### Obstacle artwork provenance

Built-in imagegen, November 1, 2026; both selected atlases are 1774×887 RGBA with
four columns and two rows. Final runtime paths:

- `assets/runtime/obstacles-rocks.png`, referenced `world-canyon.png` for style.
- `assets/runtime/obstacles-ice.png`, referenced `world-ice.png` for style.

Common prompt: isolated static cartoon ground obstacles, same bold painted
style as the scene, exactly 4×2 square cells on transparent 2:1 canvas, complete
silhouettes, generous clear margins, aligned bases, no floor strip, scenery,
shadow, labels or grid. Reading-order variants: tall three-piece mixed-height
group, tall single, tall pair, small single, short pair, short group, angled tall
piece and alternative group. Rocks: rounded terracotta/apricot sandstone blocks,
peach highlights, warm outlines and a few broad cracks. Ice: cyan/turquoise
upright blunt slabs, deep-blue/lavender outlines, white glints and snow caps,
different heights within groups; no needle spikes. The first rock sheet was
rejected for edge marks/spacing, then revised with 15% clear margins and no grid.
Generated originals were preserved; the selected files were copied into runtime.

Measured source rectangles remove transparent margins before fitting art into
the original obstacle boxes, keeping visible geometry consistent with the
existing forgiving collision rules. The shared renderer's defaults for dinosaurs
and the flyer are unchanged. No new accounts, SDKs or network behavior are added.

## Ground follow-up — 1.4.1+9

The owner liked the new home and requested removal of the scrolling foreground
strip. The three original tiled ground sprites are now unbundled; their source
files remain in the repository. Each existing world illustration supplies its
own continuous painted surface: jungle grass, canyon sandstone and crystal ice.
Soft green/brown/blue contact shadows anchor the dinosaur and cacti at the same
ground line. Airborne dinosaur shadows fade with height. No new artwork was
required, and collision/jump/spawn/reward rules are unchanged.

All three surfaces are captured by actual Flutter rendering with deterministic
preview fixtures (dinosaur, cactus and coins). These fixtures are test-only and
do not add a production debug mode:

- [Jungle grass](../screenshots/ground-jungle.png)
- [Canyon sandstone](../screenshots/ground-canyon.png)
- [Crystal ice](../screenshots/ground-ice.png)

Reproduce captures: `flutter test --dart-define=CAPTURE_GROUNDS=true test/world_ground_test.dart`.
The tests verify the visual dinosaur baseline and cactus collision ground line
for all three biomes. The earlier comparison captures below document 1.4.0;
the surface previews above show the follow-up.

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

## Inspected result

1. **Home — working, clearer task entry.** [Current home](../screenshots/home-audit/03-home-after.png),
   [comparison](../screenshots/home-audit/home-comparison.png).
   The selected character stands in an illustrated clearing and responds to a
   tap with the real jump/landing poses. Play is larger and higher in the screen.
   Shop/collection use character pictures, gifts use the chest, and settings and
   grown-ups actions remain visible. Hop and all six destinations passed action
   checks; the custom cards expose named screen-reader tap actions. Large text
   reflows/scrolls rather than clipping controls. This improves hierarchy; it
   does not establish that children prefer it.
2. **First play — working, more visual depth.** [Current playfield](../screenshots/home-audit/04-first-play-after.png),
   [comparison](../screenshots/home-audit/play-comparison.png).
   Illustrated scenery replaces the flat background/underground. The trail,
   coins and character stay distinct in the inspected frame. Slow background
   drift and short collection sparkles are decorative, disabled with reduced
   effects/motion. Jump, pause, results and the existing economy flows passed.
   Device frame pacing, long sessions and actual child comprehension/enjoyment
   still need play-testing; screenshots cannot establish those outcomes.

Fresh baseline/current screenshots and the exact side-by-side comparison
captures were opened and inspected before acceptance. Automated checks comprise
60 passing tests, clean analysis, and a headless browser flow with no external
requests, JavaScript errors or failed HTTP responses. The browser includes the
new home hop as well as shop, previews, gifts, privacy and persistence.

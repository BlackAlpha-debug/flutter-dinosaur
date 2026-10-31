# Asset provenance and runtime use

Original files are preserved. The Flutter manifest bundles only the runtime
character, terrain, cloud, small cactus/bird assets, LICENSE and local sounds.

## Runtime dinosaur

- File: `assets/runtime/dino.png`, RGBA, 1254 × 1254, about 920 KiB.
- Created 2026-10-31 with the built-in imagegen tool (background extraction).
- Reference: existing `assets/images/Dino color/Dino run 1.png`.
- Transparency was inspected; corner alpha is zero. Runtime decode is capped at
  320 pixels wide, reused by the image cache. Color variants use a hue matrix.
- This portrait remains static in menus. Gameplay now uses the frame-by-frame
  atlases documented in [ANIMATION.md](ANIMATION.md).
- Prompt: isolate the original friendly right-facing green dinosaur; remove all
  scenic background, footprints, ground and shadow; preserve pose, colors, face,
  linework and complete limbs/tail; true transparent background, square canvas,
  tight transparent margin, clean silhouette at 88 pixels high; no new objects.

Exact tool prompt:

> Use case: background-extraction. Asset type: transparent runtime character
> sprite for the existing Little Dino Flutter children's runner. Edit target:
> attached existing dinosaur running pose. Remove ALL green scenic background,
> ground, footprints, and cast shadow. Preserve only the complete friendly green
> dinosaur, its cyan back spikes, yellow belly, happy face, original linework,
> original colors, original running pose and right-facing direction. Keep all
> limbs and tail intact. Center the dinosaur in a square canvas with a tight
> consistent 4 percent transparent margin on each side; the feet should be near
> the bottom of the canvas. True alpha transparency everywhere outside the
> dinosaur, including the spaces between limbs. No scenery, no text, no
> checkerboard baked into pixels, no new objects. The isolated silhouette must
> read cleanly at 88 pixels high.

## Weekly gift artwork

The weekly gift treasure chest is original vector artwork drawn by
`lib/treasure_chest.dart`, with a short lid-opening animation. It needs no bitmap
asset or external download and respects reduced-effects/device motion settings.

## Audio

`tools/generate_sounds.py` creates the three short original PCM effects in
`assets/audio/`. Run `python tools/generate_sounds.py` to reproduce them. No
samples, songs or third-party sound recordings are used.

## Fonts

Roboto regular/bold/black are bundled from the installed Flutter SDK's material
font cache. Their Apache 2.0 notice is retained in
`assets/fonts/roboto_license.txt` and registered in the in-app license screen.
Bundling the typeface avoids remote font fetches in the browser build.

Flutter's observed Noto Sans Symbols fallback is also bundled (69,116-byte WOFF2)
under `assets/font-fallbacks/`. The web bootstrap points the engine's fallback
base URL at this local directory. The unmodified font comes from the engine's
Google Fonts URL; its SIL Open Font License 1.1 is retained in
`assets/fonts/OFL_NotoSansSymbols.txt` and in the in-app licenses.
Source: https://github.com/google/fonts/tree/main/ofl/notosanssymbols

## Existing art and code

The original project license is MIT, Copyright 2022 Hevesh Lakhwani, retained in
LICENSE and shown in the in-app licenses page. The publisher must verify the
origin and commercial-use rights for the supplied illustration references,
launcher icon, terrain, cloud and cactus artwork before distribution. The old
pixel-art bird remains as source history; the bundled flyer now uses the new
generated cartoon atlas documented in ANIMATION.md.
An AI background extraction does not establish rights to its source illustration.

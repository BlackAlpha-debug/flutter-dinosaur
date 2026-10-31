# Dinosaur character artwork

Created November 1, 2026 with built-in imagegen. Existing `assets/runtime/dino.png`
was a style reference. Original assets are preserved. Final outputs:

- `assets/runtime/bramble.png`: teal triceratops with cream horns/mint frill.
- `assets/runtime/sunny.png`: amber stegosaurus with coral/yellow plates.
- `assets/runtime/nova.png`: lavender spinosaurus with turquoise/violet sail.

All three: 1254×1254 RGBA, transparent corners, visually inspected complete
silhouettes. Runtime decodes capped at 320 pixels, common physics/hitboxes.
These portraits remain in static menus/cards. See ANIMATION.md for the later
frame-by-frame run/jump/landing atlases used during movement.

## Final prompt set

Common: one original children's runner sprite; input is style reference only.
Match bold dark clean outlines, glossy shading, oversized friendly eye, happy
smile, rounded baby proportions. Full character faces RIGHT in side-view running
pose, all limbs/tail/species features intact. Tight square framing with 4%
transparent margins, feet near bottom. Readable at 88×94 game pixels. True alpha
outside silhouette. No scene, floor, cast shadow, text, props, coins, watermark,
weapons or extra characters. Standalone polished cartoon sprite, not a mockup.

Bramble: cute teal baby TRICERATOPS, large turquoise frill edged with mint
scallops, three cream horns, peach belly, four short legs and little tail.

Sunny: amber-orange baby STEGOSAURUS, large rounded coral/sunflower dorsal plates,
cream belly, chubby legs and thick little tail, cheerful friendly expression.

Nova: lavender-purple baby SPINOSAURUS, short rounded crocodile-like snout,
scalloped violet/turquoise sail with golden star-shaped skin markings, peach
belly, tiny arms and strong running legs. No loose star objects.

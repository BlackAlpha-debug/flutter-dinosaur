# Simple character home — November 3, 2026

The owner selected **“Simple, cute character screen”** after finding the
illustrated, card-based home unappealing. This revision follows that choice.

## Design

- A warm plain background with a soft pastel circle behind one large character.
- Centered Little Dino title, a small gold counter, and the selected friend's name.
- A prominent Play button with a shallow cushion shadow.
- Compact shop, collection and gift shortcuts in one secondary row.
- Large-text/narrow windows stack the shortcuts into readable rows.
- Settings and grown-ups controls remain available at the bottom.
- Tapping the character uses the same hop/landing poses, with reduced-motion
  and extra-effects preferences respected. There is no perpetual home ticker.

The home reuses the existing dinosaur artwork and Material icons. No new bitmap
illustration is required. The old jungle painting is retained as source history
but removed from the runtime bundle. Gameplay, original sky, full-depth terrain,
obstacle skins, coin prices, gifts and persistence are outside this change.

## Work phases

1. Replace the jungle panel and large navigation cards with the simple character
   layout while preserving callbacks and accessible names.
2. Verify actions, reduced motion, scrolling, enlarged text, and actual rendered
   appearance. Preserve the previous home capture at
   `screenshots/home-simple/01-before.png` for comparison.
3. Build the Android test APK, verify its package/assets, update download
   documentation and commit/push as BlackAlpha-debug.

The previous screenshot records the prior implementation; it is not a newly
captured usability study. Layout checks and a visual review cannot establish
children's enjoyment. Play-testing with children and parents remains necessary.

## Verified result

- All 65 tests pass and analysis is clean. Existing home action checks cover the
  hop, Play, shop, collection, gifts, settings and grown-ups controls; device
  reduced motion and enlarged-text/small-screen reflow remain covered.
- Fresh browser captures were inspected for Sprout, the equipped Bramble, the
  hop pose and a 320×568 screen. See `screenshots/home-simple/02-after.png`,
  `03-hop.png` and `04-small-screen.png`.
- Full browser regression passed with no external requests, JavaScript errors
  or failed HTTP responses. Shop purchase/equip, all four running/jumping
  previews, daily gifts, privacy and reload persistence still work.
- The smoke driver's Back action now dispatches the accessible click directly
  before waiting for route transition; this avoids stale outgoing Flutter web
  semantics during pointer hit-test retries. App navigation behavior was not
  changed to work around the test.
- Android 1.5.0 / build 13 passed build, native packaging and 16 KB alignment
  checks. The old landscape images are excluded from the APK. The debug-signed
  preview is available on [GitHub Releases](https://github.com/BlackAlpha-debug/flutter-dinosaur/releases/tag/v1.5.0-preview.1).
  The phone was disconnected, so native visual/feel testing is still pending.

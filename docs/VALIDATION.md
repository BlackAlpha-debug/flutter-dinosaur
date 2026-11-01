# Validation record

## November 1, 2026 — painted ground surfaces (1.4.1+9)

- Removed the three scrolling ground overlays from rendering and bundling. The
  world's painted grass, sandstone or ice is now the surface. Contact shadows
  anchor the dinosaur/cacti; jumps, actor dimensions, collision coordinates,
  obstacle timing and rewards are unchanged.
- All 63 tests pass and analysis is clean. Three new checks confirm the visual
  dinosaur baseline and cactus collision ground across every biome. Optional
  Flutter-rendered previews load the real fonts/icons; all three were inspected.
- Native debug build, compatibility and official 16 KB zipalign checks passed.
  The update installed successfully on the connected phone without clearing data;
  package metadata confirms 1.4.1 / versionCode 9, API 24 minimum and target 36.
- Source change: `2bee972`. Preview fixtures contain only test-side actors/coins;
  no production debug mode or real-player progress changes were introduced.

## November 1, 2026 — interactive home and illustrated playfields (1.4.0+8)

- Captured and inspected the current home/first-play flow before editing. The
  numbered review, research sources, art prompts, scope and evidence limits are
  in HOME_EXPERIENCE.md. Exact before/after comparison captures were inspected
  at matching 390×844 browser dimensions.
- Home now has a selected-character jungle stage, tap-to-hop interaction, larger
  Play action, picture-based shop/collection cards and a treasure destination.
  Custom cards expose named screen-reader tap actions. No perpetual home ticker
  is introduced; reduced effects/device animation settings suppress the hop.
- Gameplay now uses three original illustrated backdrops, slow background drift,
  bounded scenery crossfades, world names and brief coin sparkles. Camera shifts
  ground, collectibles and actors together; physics, difficulty, spawning,
  character prices and coin/gift amounts are unchanged. Flat underground fill
  is replaced by the illustrated foreground.
- Format checks and analysis clean. All 60 tests passed. Three new tests verify
  the home hop and all six destinations, accessible card actions, reduced motion,
  and simulation-timed pickup feedback. Existing small/large-text phone/tablet,
  animation, storage, shop, gift and game regressions pass.
- Web build and full headless browser smoke flow passed with zero external
  requests, JavaScript errors or failed HTTP responses. The flow now includes
  the home hop, plus the four character previews and all prior economy/privacy/
  persistence checks. Home, hop, first play and both comparison captures were
  opened and inspected. All 31 local README references resolve.
- Android debug build passed, with all three scenery assets confirmed bundled.
  Native compatibility and official 16 KB zipalign checks passed. Update install
  on the connected phone succeeded, preserving app data; package metadata confirms
  1.4.0 / versionCode 8, minimum API 24 and target API 36. The phone was locked
  during the attempted screen check; that capture was rejected and removed.
  Native layout/feel and frame pacing therefore remain unverified at this point.
- Art/review commit: `00cf860`. Implementation commit: `c168fd4`. Gradle and
  the local preview server were stopped. Android Studio/emulator were not used.
- These checks validate implementation and visible layout, not children's
  enjoyment or retention. Short supervised play sessions with ages 6–8 and
  parents remain the next evidence needed for those outcomes.

## November 1, 2026 — cartoon flying obstacle and simpler results (1.3.1+7)

- Removed the pickup/multiplier calculation from pause/results; final score,
  earned gold and best score remain. A screen regression check confirms the
  breakdown text is absent.
- Replaced the bundled pixel-art flyer with a new coral cartoon pterosaur and
  eight-pose 640ms wingbeat. Built-in imagegen output: 1774×887 transparent RGBA;
  inspected per-cell opaque bounds stay inside every frame. Prompt, revision
  rationale and measured anchor offsets are documented in ANIMATION.md.
- Extracted the existing dinosaur atlas renderer into shared SpriteAtlas;
  dinosaurs retain their measured foot baselines and the flyer uses eye offsets
  to stabilize its body. One cached image is sampled by source rectangles.
  Flying obstacle dimensions, spawn timing, height and collisions are unchanged.
- Analyzer clean; all 57 tests passed. Four new checks cover all flight poses,
  unchanged bounds, pause/resume, reduced motion and actual Flutter rendering.
  The optional capture exporter also passed; its eight-pose sheet was inspected
  at `screenshots/ptera-wingbeat.png`. Existing tests for every dinosaur preview,
  responsive layouts, coins, gifts and storage still pass.
- Android debug build passed; native compatibility and official 16 KB zipalign
  checks passed. The APK was installed successfully as an update on the connected
  phone without clearing app data. Package inspection confirmed version 1.3.1,
  versionCode 7, minimum API 24 and target API 36. Flight feel/frame pacing on
  physical hardware was not measured by the install/package check.
- README feature/version/architecture and asset documentation updated; all 30
  local README references resolve. Score simplification commit: `f794edd`.
  Artwork/rendering commit: `d1682bf`. Gradle was stopped after the build;
  Android Studio and emulator were not launched.

## November 1, 2026 — treasure trail and project README (1.3.0+6)

- Replaced the long weekly-gift list with a daily chest, prominent claim action,
  balance/streak chips, progress bar, a winding seven-stop board and a larger
  600-gold final treasure. Original vector chest artwork opens when claimed;
  extra-effects and device reduced-motion settings control its animation.
- Fixed amounts, one claim per local date, visit counting and missed-day reward
  preservation are unchanged. The seventh gift stays visibly completed until
  the next eligible day, then the board resets for a fresh seven-gift trail.
- All 53 tests pass; analyzer clean. Existing gift-page layout checks cover
  small phones, short landscape windows and tablets at 200% text. A new UI test
  claims all seven gifts, checks each completion state, and checks the new-day
  reset. Numeric progress-bar semantics preserve screen-reader compatibility.
- Web build and headless Chrome regression passed: no external requests,
  JavaScript errors or failed HTTP responses. The daily chest, complete trail,
  claimed chest, updated balance and progress were visually inspected. Captures
  are `weekly-gifts.png`, `weekly-trail.png` and `weekly-gifts-claimed.png` under
  `screenshots/`. A focused extra capture positions the whole seven-stop board
  below the app bar for the README; no production state was modified by it.
- Android debug APK built; manifest confirms 1.3.0 / versionCode 6, minimum API 24
  and target API 36. Native compatibility and official 16 KB zipalign checks
  passed for seven 64-bit libraries; all three expected ABIs are present.
  The debug application ID is still a placeholder; permanent release identity,
  signing and physical-device testing remain in RELEASE.md.
- Rewrote README with project status, visual previews, controls, economy tables,
  seven-gift rules, installation, verification, architecture, privacy, platform
  support, release setup, documentation index, contribution/support and licensing.
  All 29 local document/image references resolve. Existing artwork rights review
  and original MIT attribution remain explicit.
- Feature commit: `fdd7880`. README commit: `baf1ce6`. Gradle and the local preview
  server were stopped afterward; Android Studio/emulator were not launched.

## November 1, 2026 — dinosaur leg animation (1.2.1+5)

- All four dinosaurs now use six running poses, an airborne pose and a landing
  crouch, with measured foot baselines. Stride cadence follows world distance;
  pause/background/game-over cannot advance the animation. Landing lasts 100ms
  and a new jump immediately interrupts it. Existing physics/hitboxes are intact.
- Static menus/cards retain their portraits. Preview pages have Run preview,
  Stop running and Try a hop controls using the gameplay atlases. Reduced-effects
  mode retains leg movement; OS reduced animation holds a neutral pose and
  disables preview controls.
- Analyzer clean; all 52 tests passed. Nine new checks cover the stride loop,
  pose priorities, reduced motion, pause/restart/landing timers, all four preview
  run/hop/stop flows and device animation settings.
- Web build passed. Headless installed Chrome confirmed changing run frames,
  jump and stop for every character, plus the existing gameplay/pause/settings,
  privacy, purchase, collection, gift and persistence flows. No external requests,
  JavaScript errors or failed HTTP responses. Run-frame pairs, all four airborne
  previews and the gameplay screenshot were inspected for feet and clipping.
  Reproducible procedure: `tools/browser_smoke.cjs`; results and captures are in
  `screenshots/`. Screenshots show sampled poses, not a measured frame-rate test.
- Android debug APK built successfully. Native ELF and ZIP 16 KB alignment checks
  passed for all seven 64-bit libraries, with ARM32/ARM64/x86-64 present. Official
  Android SDK `zipalign -c -P 16 4` also passed. Gradle and the local preview server
  were stopped afterward; Android Studio/emulator were never launched.
- Physical-device animation feel and low-end frame pacing remain unmeasured.
  A signed release AAB and owner Play Console requirements remain in RELEASE.md.

## November 1, 2026 — gold, characters and weekly gifts

- Version 1.2.0+4 adds three difficulty multipliers, a local gold wallet,
  one-time legacy-star migration, three generated characters, separate shop,
  preview and collection pages, and repeating weekly gifts without accounts.
- All 43 tests pass and analyzer is clean. Tests cover migration/reload, exact
  price boundaries for all three purchases, buy/cancel/idempotent ownership,
  selection, multiplier credit, Hard simulation/recycling, seven-day wrap,
  duplicate/missed/backward dates, visits without gift claims, reset and
  responsive new pages at 200% text.
- Generated assets were inspected: 1254×1254 RGBA with transparent backgrounds.
  Prompts/provenance are in DINO_ART.md. Character abilities remain identical.
- Ads remain disabled; only a provider boundary and future-integration checklist
  were added. No ad SDK or provider account was configured.
- Version 1.2.0+4 debug build and final incremental build passed; native ELF
  and ZIP 16 KB checks passed for all seven 64-bit libraries and three ABIs.
- Browser pass: 11 base checks plus six economy checks, zero external requests,
  JavaScript errors or failed HTTP responses. Confirmed a 1,000-gold purchase,
  equipped ownership, collection, 100-gold daily gift and persisted selection/
  balance after reload. Test wallet started at 1,200 and ended at 300 gold.
  This is a clearly marked local-storage fixture, not a production coin-grant UI.
  All three preview screenshots, shop and gift page were visually inspected.
- Physical play-testing, low-end performance, final signed AAB/16 KB device
  testing, store declarations and publisher release identity/key remain owner
  prerequisites. Offline clock changes cannot be made tamper-proof locally.

## November 1, 2026 — privacy and Android optimization

- Completed the publication-ready policy with the confirmed support/privacy
  email, local progress handling, optional support correspondence, retention,
  deletion and Notion/Google platform distinctions. Bundled the same document
  behind **For grown-ups → Full privacy policy**, readable offline.
- All 31 automated tests passed. Added 30/60/90/120/144 Hz clock checks and a
  viewport matrix covering small phones, 200% text/notches, narrow split-screen,
  portrait/landscape tablets, short windows and foldable-sized resizing.
- Fixed discovered HUD/footer and grown-ups-action overflows. Layout tests read
  the actual policy text through a synchronous test bundle; browser validation
  separately checks real asset loading. Analyzer clean.
- Native packaging checks on the final version 1.1.1+3 debug APK passed for all seven 64-bit
  libraries: ELF load alignment and uncompressed ZIP alignment. ARM32, ARM64 and
  x86-64 were present. The Android SDK's official `zipalign -c -P 16 4` also passed.
- Version 1.1.1+3 Android debug build passed. Manifest confirms API 24 minimum,
  target API 36 and version code 3. ZIP inspection confirms the complete policy
  asset is present with the correct contact email.
- Final headless Chrome pass completed all 11 checks, including real HTTP loading
  of the bundled full policy/contact and saved-score reload. Zero external
  requests, JavaScript errors or failed HTTP responses. New policy/gameplay
  screenshots were inspected; results are in `screenshots/browser-results.json`.
- No physical devices, Android Studio or emulator were used. Per-device frame
  time, memory, battery and thermal performance still need profile/release tests.

## October 31, 2026 — initial implementation

## Verified locally

- Flutter 3.44.7 / Dart 3.12.2 on Windows.
- Phase 1: seven initial simulation regressions passed.
- Expanded suite: 18 tests passed, including restart, double jump, on-screen jump
  bounds, pause/resume, 30/120 Hz consistency, capped difficulty, safe recycling
  over a simulated five-minute run, collision, positive small-obstacle hitboxes,
  star banking, audio stop, confirmed reset, storage/reload/failure recovery,
  lifecycle pause and small-screen enlarged-text UI.
- Dart formatting and Flutter analyzer passed after final build integration.
- Browser release build compiled successfully; modern Flutter bootstrap used.
- Headless installed Chrome exercised menu, start, pause, settings, resume,
  collision/results, home and local best-score persistence through page reload.
  No JavaScript errors. Captured screenshots were inspected.
- The initial browser pass detected remote fallback font requests. Roboto and
  the engine's symbol fallback are now bundled locally. The final pass completed
  all ten flow checks with zero external HTTP requests, zero JavaScript errors
  and zero failed HTTP responses. Saved Easy best score 86 survived page reload.
- Actual browser captures include 390×844 and 320×568 viewports. Screenshots and
  machine-readable results are in `screenshots/`. Headless software-renderer GPU
  readback warnings occurred during screenshots; these were not app exceptions.
- Generated character alpha inspected: RGBA, transparent corner pixels. Originals
  retained, only selected runtime art is bundled. Font/audio notices retained.
- Production preflight correctly exits with a clear missing release.properties
  message; no production signing files or passwords were created.
- Gradle `:app:preReleaseBuild` also rejected missing production identity through
  `validateProductionRelease`, before release compilation, with the documented
  configuration message. This failure was expected and verifies the release guard.
- Git remote identity verified: BlackAlpha-debug; remote main matched local HEAD
  before changes.

## Build integration

- Initial Android build exposed old AGP/Kotlin warnings and a JNI NDK mismatch.
  Updated to AGP 8.13.1, Kotlin 2.3.0 and installed NDK 28.2.13676358, matching
  the current preferences Android implementation. Android debug build succeeded;
  a final incremental build also passed with the completed local font assets.
  APK manifest inspection confirms version 1.1.0+2, min SDK 24, target SDK 36,
  Little Dino label, disabled backup and extraction rules. Debug-only INTERNET
  permission is present for Flutter tooling, as expected; this is a debug APK.
  Packaged game assets/fonts/audio total 1,935,258 uncompressed bytes; oversized
  source illustration variants are excluded. This is not a Play download estimate.
- Gradle emitted nonfatal embedded-Kotlin and Gradle-deprecation warnings from
  the included Flutter build. The pinned Gradle 8.14.1 build succeeds; do not
  switch to Gradle 9 without checking Flutter/plugin compatibility.
- Final suite rerun passed all 18 tests in isolation. An earlier repeat had a
  Flutter test-compiler temporary-file error before executing any tests; it was
  stopped and rerun after compilation completed. No application test failed.

## Required owner/device validation before store submission

- Supply the permanent application ID, support email, hosted policy URL and upload
  key. Complete the policy draft and verify commercial rights for supplied art.
- Test the signed AAB through Play internal testing on physical Android phones:
  low-end performance, startup, repeated retry, rapid double jump, interruptions,
  screen lock/unlock, Android Back, saved progress, sound/mute and airplane mode.
- Test actual tablet/foldable resizing, safe areas, large fonts, TalkBack and
  reduced-animation settings. The scaled simulation keeps difficulty consistent;
  simulated viewport tests do not replace physical-device accessibility testing.
- Test native 16 KB page-size compatibility. A successful debug build or browser
  run is not proof of signed-release native alignment or device compatibility.
- Listen to effects on a real phone at several volume levels; verify no sounds
  continue after backgrounding. Browser smoke checks do not evaluate loudness.
- Play-test with children aged 6–8 and parents; tune reaction gaps, instructions,
  retry encouragement and session lengths from observed feedback.
- Complete Play declarations, developer verification, content rating, Data safety,
  target audience and required closed testing/production access.

Android Studio and the Android emulator were stopped at the owner's request and
were not relaunched. Command-line Gradle compilation uses at most two workers.
No Play Console upload, store publication or physical-device verification occurred.

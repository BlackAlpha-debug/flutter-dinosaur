# Little Dino implementation plan

Audience: ages 6–8. Offline play, no advertising, no purchases, no accounts,
no analytics. Publisher: BlackAlpha-debug (confirmed GitHub remote). Support email,
permanent Android application ID, and public privacy-policy URL are pending.

Work proceeds in the order below. Each phase has a verification gate. Local
implementation can finish without publishing; external account setup, tester
recruitment, legal identity and final upload credentials require the owner.

## Phase 1 — Reliable game simulation

- Separate simulation from widgets in a testable game engine.
- Model menu, playing, paused and game-over states explicitly.
- Use bounded elapsed time and a fixed simulation step; never advance while
  paused. Reset the ticker baseline on every start/resume.
- Recreate run state on restart, including dinosaur velocity/jump count,
  distance, terrain, obstacle queue and simulation clocks.
- Use safe collection removal and proportional, positive collision boxes.
- Provide capped Easy/Normal settings and a single obstacle queue with minimum
  reaction/recovery spacing. Delay flying enemies until the player has practice.
- Derive sky and terrain directly from distance. Freeze particles on pause.
- Gate: engine regression tests for restart, pause, double jump, collisions,
  bounded difficulty, obstacle spacing and long-running recycling; analyzer.

## Phase 2 — Children’s interaction flow

- Build a welcoming menu, large Play button and visual double-jump instructions.
- Add a visible pause control, resume/retry/home actions and encouraging results.
- Pause on background/inactive/lock and Android Back; require deliberate resume.
- Replace raw physics inputs and the development kill button with safe settings.
- Scale a consistent logical playfield to phones/tablets, keep controls inside
  safe areas, and allow scrolling in dialogs/large-text layouts.
- Add semantic labels, generous touch targets, contrast and reduced-effects mode.
- Gate: widget tests for start/pause/resume/settings/retry and narrow/large layouts.

## Phase 3 — Offline progress and sound

- Save separate best scores for each difficulty, collected stars, selected color,
  difficulty and audio/effects settings locally.
- Load preferences before enabling play. Serialize writes and handle storage
  failure visibly without blocking offline play.
- Add collectible stars and a small set of cosmetic colors earned through play.
- Add short locally bundled generated sounds with a saved mute control; no
  network dependencies or background playback. No unimplemented music toggle.
- Include a confirmed local progress-reset action in the grown-ups area.
- Gate: persistence/reload/reset/failure tests plus sound lifecycle checks.

## Phase 4 — Runtime artwork and presentation

- Preserve source art; introduce transparent runtime dinosaur artwork with
  consistent pose sizes/alignment and code-driven motion where appropriate.
- Keep only used files in the Flutter asset manifest; bound image decode sizes.
- Use transparent existing small flying-enemy art and aligned terrain rendering.
- Provide friendly in-game illustration, soft effects and predictable sky phases.
- Record generated asset provenance and inspect alpha/size and actual rendering.
- Gate: asset existence checks, visual screenshots, no missing assets/overflow.

## Phase 5 — Android release preparation

- Replace debug release signing with opt-in private upload-key configuration;
  missing signing/identity must fail clearly for a production build.
- Keep debug builds runnable while the permanent app ID is pending.
- Disable Android cloud backup for the local child-game progress store.
- Add in-app privacy/offline information, publisher/license information and a
  privacy-policy draft that accurately describes the implemented app.
- Add versioning, release instructions, Play Console checklist and store copy.
- Add repeatable verification/CI for formatting, analysis, tests and debug build.
- Gate: Android debug build; expected rejection of unconfigured production build;
  release documentation reviewed against current official sources.
- Owner dependencies: permanent app ID, support email, public policy URL, private
  upload key, Play Console declarations/content rating and production access.

## Phase 6 — Complete validation and handoff

- Run format, analyzer, all regression tests and an Android build.
- Exercise the actual app through a lightweight browser if tooling permits;
  capture menu, gameplay, pause/settings and results. Android device checks stay
  manual: the owner explicitly asked to close the emulator/Android Studio because
  the laptop cannot support them. Do not launch either again.
- Record exact completed checks and unresolved limitations in VALIDATION.md.
- Supply manual checks for physical low-end phones, tablets, accessibility,
  16 KB devices, sound, extended runs and children/parent feedback.
- Gate: local checks pass; explicitly distinguish local readiness from store
  approval. Do not claim physical-device, 16 KB or child-user testing if absent.

## Deliberately later

Extra worlds, adventure levels, educational fact cards, additional characters and
local achievements can follow user testing. Avoid subscriptions, chat, online
leaderboards, streak pressure, notifications and monetization in this first release.

## Research sources

- [Flutter Android release guide](https://docs.flutter.dev/deployment/android)
- [Flutter lifecycle API](https://api.flutter.dev/flutter/widgets/AppLifecycleListener-class.html)
- [Shared preferences](https://pub.dev/packages/shared_preferences)
- [Google Play Families](https://support.google.com/googleplay/android-developer/answer/9893335)
- [Google Play user data](https://support.google.com/googleplay/android-developer/answer/10144311)
- [Target API requirements](https://developer.android.com/google/play/requirements/target-sdk)
- [16 KB page sizes](https://developer.android.com/guide/practices/page-sizes)
- [New personal account testing](https://support.google.com/googleplay/android-developer/answer/14151465)

## Execution log

- Planning: repository and tools inspected; clean working tree; Flutter 3.44.7;
  no phone is connected. Android emulator stopped at owner's request; no Android
  Studio process was running. Use headless tests/browser and command-line builds.
- Phase 1: seven simulation regression tests passed, including a simulated
  five-minute run, reset, pause, double jump, collision and spacing checks.
- Phase 2: start/pause/settings/resume, background lifecycle and small-screen
  enlarged-text widget checks passed before adding persistence. Menus now scroll
  to fit short displays. Phase 3 adds persistence and bundled original sound.
- Phase 3: all 14 simulation, UI and persistence tests passed. Local scores,
  settings, stars and unlocks are saved; sound is bundled with mute support.
- Phase 4: generated and inspected a transparent runtime dinosaur; preserved the
  original references; replaced oversized enemy art with small transparent
  sprites and removed unused images from the bundled asset manifest.
- Phase 5: private signing/identity templates, production validation, Android
  backup exclusions, in-app privacy/licenses/reset, policy draft, store copy,
  release runbook and verification workflow implemented. Owner details remain
  deliberately pending.
- Phase 6: final serial run passed all 18 tests; formatting/analyzer clean;
  Android debug build and final incremental build passed; headless Chrome passed
  ten flow checks with zero external requests/errors. Screenshots inspected and
  APK version/SDK/backup settings checked. Remaining store/device checks are in
  VALIDATION.md. Git commit/push follows this verified local implementation.
- November 1 follow-up: completed the public Notion-ready policy with the owner's
  contact email and added the same policy offline in-app. Optimized render/HUD
  cadence, rain and lazy audio initialization; fixed large-text/short-window
  overflows and resize handling. All 31 tests, analyzer, Android 1.1.1+3 debug
  build, native ELF/ZIP alignment checks and 11 browser flow checks passed.

# Android compatibility and optimization

Updated November 1, 2026. Target devices are supported Android phones and tablets;
universal compatibility across every Android device or manufacturer is not claimed.

## Supported baseline

- Android 7.0 / API 24 minimum, matching the current Flutter/preferences stack.
- Target/compile API 36 with the pinned Flutter 3.44.7 SDK.
- Universal APK includes ARM 32-bit (`armeabi-v7a`), ARM 64-bit (`arm64-v8a`)
  and x86-64. Google Play App Bundles deliver device-specific resources/native
  libraries rather than requiring every device to download a universal APK.
- AGP 8.13.1, Kotlin 2.3.0, NDK 28.2.13676358, Java target 17.
- Large screens may override a portrait orientation request. The game uses a
  consistent logical playfield, safe-area controls and scrollable menus/dialogs.
- Devices below API 24 and other CPU architectures are outside this build's
  supported range. TV, Wear OS and automotive interfaces are not designed targets.

## Changes made

- Cap world notifications at 60 Hz on high-refresh screens while retaining elapsed
  time and fixed-step physics. Tests cover 30, 60, 90, 120 and 144 Hz timestamps.
- Keep the scene on its own listenable/repaint boundary. HUD and controls rebuild
  at most five times per second during a run; state/star changes update immediately.
- Cache normalized rain parameters once rather than generating random values on
  every frame. Existing effects and OS reduced-animation settings still apply.
- Create native audio players on first use, saving startup work and resources
  when sound is disabled. Stop sounds on backgrounding and dispose after use.
- Pause on fold/rotation/window metrics changes so resize does not lose a run.
- Fit numeric counters inside their columns, keep labels readable and hide the
  repeated jump hint in short/large-text windows rather than overflowing the HUD.
- Scroll settings and grown-ups actions within the dialog; keep Done visible.
  In short/wide windows, crop unused underground space to enlarge the play area
  while preserving the entire jump arc and logical collision coordinates.
- Keep the transparent dinosaur decode capped at 320 pixels and clouds at 184;
  use only selected runtime assets. Image cache limits are managed by Flutter.
- Pin minimum API explicitly, preserve native ABI coverage and add repeatable
  ZIP/ELF alignment checks to local verification and CI.

## Automated viewport checks

| Scenario | Logical pixels | Text scale |
| --- | --- | --- |
| Small phone, top notch and bottom inset | 320×480 | 200% |
| Narrow split-screen | 280×600 | 150% |
| Tablet portrait | 800×1280 | 150% |
| Tablet landscape | 1280×800 | 150% |
| Short landscape window | 640×320 | 150% |
| Foldable-sized window | 720×600 | 200% |

Each test exercises play, a long score/star counter, pause, settings, grown-ups
information and the complete offline policy. A separate check resizes an active
window and verifies preserved run progress. These are simulated layouts, not a
claim that physical foldable hardware or every Android version has been tested.

## Native packaging verification

Run `python tools/check_android_compatibility.py PATH_TO_UNIVERSAL_APK`.
It checks all three expected ABIs, every 64-bit ELF PT_LOAD alignment and the ZIP
data offsets of uncompressed 64-bit `.so` libraries. It reads ZIP entries directly
without extracting large native binaries or needing an emulator.

Also run the Android SDK's official `zipalign -c -P 16 4 PATH_TO_APK`.
Both checks passed for the version 1.1.1+3 debug APK: all seven 64-bit libraries
passed ELF/ZIP alignment, and all three expected ABIs were present.
The final signed App Bundle and APKs generated from it must be checked again.
Packaging checks cannot replace starting and playing the game on a 16 KB device.

## Physical testing still needed

Use a low-memory phone, an ARM32 Android 7 device if supported customers use it,
a modern ARM64 phone, tablets/foldables, high-refresh screens, TalkBack, 200% text,
airplane mode and 16 KB page-size hardware. Measure frame timing, memory, audio,
battery and thermal behavior in profile/release mode. Debug APK size/frame timing
does not represent a Play release. No Android Studio or emulator is launched on
the owner's laptop.

Sources: [Flutter supported platforms](https://docs.flutter.dev/reference/supported-platforms),
[Android 16 KB requirements](https://developer.android.com/guide/practices/page-sizes),
[zipalign](https://developer.android.com/tools/zipalign).

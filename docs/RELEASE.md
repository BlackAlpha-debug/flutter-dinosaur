# Android release runbook

## Current owner decisions

Publisher is BlackAlpha-debug. Audience is ages 6–8, offline, no ads or purchases.
Privacy/support contact is muzammiljawad6@gmail.com. Permanent application ID,
public Notion policy URL, upload key and Play Console account details are not
supplied. A production build deliberately fails without
them. A debug APK is for testing only. No Android Studio/emulator is required.

## Downloadable Android test build

The current public preview is [v1.4.4-preview.1](https://github.com/BlackAlpha-debug/flutter-dinosaur/releases/tag/v1.4.4-preview.1):

- [APK download](https://github.com/BlackAlpha-debug/flutter-dinosaur/releases/download/v1.4.4-preview.1/little-dino-1.4.4-preview.apk)
- [SHA-256 file](https://github.com/BlackAlpha-debug/flutter-dinosaur/releases/download/v1.4.4-preview.1/little-dino-1.4.4-preview.apk.sha256)
- Version 1.4.4, Android version code 12; Android 7.0/API 24 minimum.
- Debug-signed test build, separate from the signed Play Store release below.

APK SHA-256: `e249759cd6527afb1dcdc7d8357ba77630d5196198515a6de6695174842318ab`.
The exact file was installed successfully on the connected phone. It is hosted
as a GitHub Release asset, so downloading does not depend on a workflow artifact's
14-day retention period. Source, store identity and signing prerequisites remain
documented below.

## Local checks

Run `powershell -File tools/verify.ps1`. Flutter/Android SDK/Java must already be
installed. Connect a physical phone later to test `flutter run -d DEVICE_ID`.
Do not launch an emulator on the owner's laptop.

The Android build uses Gradle 8.14.1, AGP 8.13.1 and Kotlin 2.3.0, aligned with
the current shared-preferences Android implementation. Java bytecode targets 17.
NDK 28.2.13676358 is pinned for its JNI dependency; install it via the Android
SDK command-line tools if it is absent. It is already installed on this machine.
Successful GitHub verification runs retain a `little-dino-debug-apk` artifact
for 14 days for device testing. This is not a Play release bundle.

## Identity and signing

1. Copy `android/release.properties.example` to `android/release.properties` and
   fill in a permanent lowercase application ID, support email and public policy
   URL. The namespace/Kotlin class can remain unchanged: the application ID
   defines the Play app identity. Changing that ID after launch creates a new app.
2. Publish `docs/PRIVACY_POLICY.md` on a public read-only Notion page; verify its URL without
   signing in. The release helper passes the support contact/hosted URL into the
   grown-ups screen using Dart defines. The screen also contains the full offline
   policy. Plain `flutter build` does not supply these optional display defines.
3. Create an upload keystore privately using Android's keytool instructions in
   the [Flutter release guide](https://docs.flutter.dev/deployment/android).
   Keep an encrypted backup. Do not paste its passwords into chat or Git.
4. Copy `android/key.properties.example` to `android/key.properties`; configure
   the private keystore. All four key fields are required. Real configuration
   and keystores are ignored by Git. No debug-key fallback exists.
5. Set an unused increasing versionCode using `pubspec.yaml` or build flags.
6. Run `powershell -File tools/build_release.ps1`. It validates identity and key
   file configuration before invoking Flutter, then embeds the public contact
   details. The current pubspec version is 1.5.0+13; increase it for later uploads.
   The artifact is under `build/app/outputs/bundle/release/`.
7. Inspect the bundle's package name, target SDK, merged permissions and native
   alignment. Verify 64-bit and 16 KB support with Android tooling and a suitable
   physical/test device. Do not infer it from a successful Dart test/build.

## Play Console

- Register/verify the developer account and app identity; configure Play App Signing.
- Declare target audience accurately (ages 6–8), complete Families compliance,
  content-rating questionnaire, ads declaration (no ads) and app access (no login).
- Complete Data safety from the final artifact and SDK inventory. The game has
  local preferences and local sounds; do not mark platform store activity as an
  app feature or assume every dependency transmits data because it supports HTTP.
- Publish the completed privacy policy in Console and make it accessible in-app.
- Confirm source artwork rights and retain original MIT notice and package licenses.
- Prepare store icon (512×512), feature graphic (1024×500), real screenshots,
  title, short/full descriptions and support email. Do not use debug screenshots
  containing development controls or claim untested educational benefits.
- Use internal testing first. Personal accounts created after November 13, 2023
  currently need at least 12 closed-test opt-ins continuously for 14 days before
  applying for production access. Passing that duration does not guarantee approval.
- Review pre-launch report, crashes/ANRs and parent/child feedback; then stage rollout.

## Policy references checked 2026-10-31

- [Families](https://support.google.com/googleplay/android-developer/answer/9893335)
- [User Data/privacy](https://support.google.com/googleplay/android-developer/answer/10144311)
- [Target SDK](https://developer.android.com/google/play/requirements/target-sdk):
  new phone apps target API 36 or later at the time of this review. Check Console
  again on upload; the project follows the installed Flutter target SDK.
- [16 KB native compatibility](https://developer.android.com/guide/practices/page-sizes)
- [Personal-account testing](https://support.google.com/googleplay/android-developer/answer/14151465)

## Draft store copy

Title: Little Dino

Short description: Hop, collect gold and meet cheerful dinosaurs in an offline adventure.

Full description: Join a cheerful little dinosaur for a hopping adventure! Tap
to jump and tap again for a double jump. Dodge cacti, meet flying dinosaurs and
collect gold to buy new dinosaur friends. Preview Bramble, Sunny and Nova in the
shop, then choose your owned dinosaur in My Dinosaurs. Easy, Normal and Hard give
×1, ×2 and ×3 gold. Claim seven repeating weekly gifts without losing reward
progress when you miss a day. Pause whenever you need a break. Progress stays on
your device. Designed for ages 6–8, with no ads, no real-money purchases and no
account needed. Includes optional sound effects and an effects setting.

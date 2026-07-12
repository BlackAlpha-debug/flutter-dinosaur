<img width="621" height="876" alt="Screenshot 2026-07-12 132557" src="https://github.com/user-attachments/assets/06db7c2a-f6da-4fcd-92ac-3583a4cc1dea" /><p align="center">
  <h1 align="center">Flutter Dino Runner</h1>
  <p align="center">
    <strong>Chrome Dinosaur Game — Reimagined in Flutter</strong>
  </p>
  <p align="center">
    A cross-platform dinosaur runner game inspired by Chrome's offline dino, built with Flutter. Features double jump, dynamic day-to-night sky transitions, animated rain particles, jump glow effects, and a game-over flash — all running at 60fps with custom painters and animation controllers.
  </p>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-orange?style=flat-square" alt="Platforms">
  <img src="https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/status-playable-brightgreen?style=flat-square" alt="Status">
</p>

---

## Gameplay Preview

<p align="center">
  <img src="https://github.com/user-attachments/assets/4ae09f2b-1add-465e-b8ee-41a551a6b5b" alt="Day Sky" width="32%">
  <img src="https://github.com/user-attachments/assets/f6ae0f29-652b-442c-b3a2-c0aee0c27baa" alt="Sunset Sky" width="32%">
  <img src="[screenshots/night.png](https://github.com/user-attachments/assets/ffa8af64-e6ce-4eba-83b5-d1ba100ed259)" alt="Night Sky with Rain" width="32%">
</p>

---

## Download APK

<p align="center">
  <a href="https://github.com/BlackAlpha-debug/flutter-dinosaur/releases/latest/download/app-release.apk">
    <img src="https://img.shields.io/badge/Download-APK%20(Latest)-brightgreen?style=for-the-badge&logo=android&logoColor=white" alt="Download APK">
  </a>
</p>

| Version | Download |
|---------|----------|
| v2.0 (with effects) | [app-release.apk](https://github.com/BlackAlpha-debug/flutter-dinosaur/releases/latest/download/app-release.apk) |
| v1.1 | [app-release.apk](https://github.com/BlackAlpha-debug/flutter-dinosaur/releases/download/1.1/app-release.apk) |
| v1.0 | [app-release.apk](https://github.com/BlackAlpha-debug/flutter-dinosaur/releases/download/1.0/app-release.apk) |

> **Install on Android:** Download the `.apk` file, enable "Install from unknown sources" in your device settings if prompted, and tap the downloaded file to install.

---

## Features

- **Double Jump** — tap once to jump, tap again mid-air for a higher + wider second jump
- **Dynamic Sky Transitions** — background gradient shifts from day through sunset into night as your score climbs (every 100 points)
- **Animated Rain** — a `CustomPainter` particle system draws falling rain streaks that intensify as the sky darkens; fully decorative, no collision interference
- **Jump Glow Effect** — the dino pulses with a cyan tint on each jump using `ColorFiltered` and a dedicated `AnimationController`
- **Game-Over Flash** — a brief red overlay flashes on collision via an animated opacity layer
- **Progressive Difficulty** — fewer obstacles at low scores, density ramps up as you approach 800 points
- **1.75x Speed** — faster base velocity for a more exciting pace
- **Configurable Physics** — in-app settings dialog to tweak gravity, acceleration, jump velocity, and day/night offset in real time

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App                            │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │              AnimatedContainer                     │   │
│  │         (score-based sky gradient)                 │   │
│  │                                                    │   │
│  │  ┌──────────────────────────────────────────┐     │   │
│  │  │         Stack (game layers)               │     │   │
│  │  │                                            │     │   │
│  │  │  ┌─ RainEffect (CustomPainter)            │     │   │
│  │  │  │   └─ particle system, IgnorePointer    │     │   │
│  │  │  │                                         │     │   │
│  │  │  ├─ Clouds / Ground / Cacti               │     │   │
│  │  │  │   └─ AnimatedBuilder per object        │     │   │
│  │  │  │                                         │     │   │
│  │  │  ├─ Dino (_DinoWidget)                    │     │   │
│  │  │  │   └─ ColorFiltered jump pulse          │     │   │
│  │  │  │                                         │     │   │
│  │  │  ├─ Score / High Score text               │     │   │
│  │  │  │                                         │     │   │
│  │  │  └─ Death flash overlay (red, animated)   │     │   │
│  │  └──────────────────────────────────────────┘     │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  worldController (AnimationController, days: 99)         │
│    └─ drives _update() → physics, collision, spawning    │
└─────────────────────────────────────────────────────────┘
```

---

## Quick Start

```bash
# Clone the repository
git clone https://github.com/BlackAlpha-debug/flutter-dinosaur.git
cd flutter-dinosaur

# Get dependencies
flutter pub get

# Run on your device
flutter run
```

| Command | What it does |
|---------|--------------|
| `flutter run` | Launch on connected device / emulator |
| `flutter run -d chrome` | Run as a web app in Chrome |
| `flutter run -d windows` | Run as a Windows desktop app |
| `flutter build apk` | Build a release APK for Android |

---

## Project Structure

```
lib/
  main.dart         Game screen, world controller, background gradient,
                    obstacle spawning, death flash, rain integration
  dino.dart         Dino class + _DinoWidget with jump pulse animation
  rain.dart         RainEffect widget + RainPainter (CustomPainter particles)
  constants.dart    Physics values, sky gradient palettes, tuning knobs
  cactus.dart       Cactus obstacle (sprite + collision rect)
  cloud.dart        Cloud decoration (parallax layer)
  ground.dart       Scrolling ground tiles
  game_object.dart  Abstract base class for all game entities
  sprite.dart       Sprite data class (path, dimensions)
  ptera.dart        Pterodactyl obstacle (unused, available for extension)

assets/images/     All sprite sheets (dino frames, cacti, clouds, ground)
```

---

## Game Mechanics

| Mechanic | Details |
|----------|---------|
| **Jumping** | First tap: normal jump. Second tap mid-air: 1.25x velocity boost |
| **Speed** | Base velocity 52.5 (1.75x original), accelerates over time |
| **Obstacles** | Extra gap (~390 units at score 0) shrinks linearly to 0 at score 800 |
| **Sky phases** | Day → Early Sunset → Deep Sunset → Dusk → Night (every 100 pts) |
| **Rain** | Starts at phase 2 (score 200), max intensity at phase 4 (score 400+) |
| **Gravity** | 2500 (configurable via settings) |

---

## Building the APK

```bash
# Debug APK
flutter build apk --debug

# Release APK (optimized, smaller)
flutter build apk --release

# The APK will be at:
# build/app/outputs/flutter-apk/app-release.apk
```

---

## License

MIT

---

<p align="center">
  Built with Flutter, custom painters, and a dinosaur that refuses to go extinct.
</p>

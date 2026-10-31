# Gold coins, dinosaur shop and weekly gifts

Created November 1, 2026. Owner decisions: Easy ×1, Normal ×2, Hard ×3;
ads prepared for later and disabled now. Preserve the original free dinosaur
and add three purchasable cosmetic dinosaurs. Commit and push every completed
phase as BlackAlpha-debug, using the existing configured author identity.

## Product behavior

- Home links to Play, Dino Shop, My Dinosaurs, Weekly Gifts, Settings and
  For grown-ups. Gameplay/result screens show the run reward and wallet clearly.
- Gold coins are earned virtual currency, not real money; no cash checkout,
  purchase SDK, subscription or monetary value. Buying a dinosaur spends coins
  once and grants permanent local ownership. Preview is free before buying.
- Each physical coin pickup grants 10 gold on Easy, 20 on Normal, 30 on Hard.
  Show the multiplier before starting and in the run/results UI. Place small,
  spaced coin trails between obstacles, with some optional jump-height coins.
  Never require a risky collectible to continue. Tune the Hard speed/spacing
  safely rather than making the level unavoidably difficult.
- Convert existing saved stars to gold at 10 gold per star once, retaining
  separate best scores, settings and previously earned color selections.
- Catalog: Sprout (original, free); Bramble (teal baby triceratops, 1,000);
  Sunny (amber baby stegosaurus, 10,000); Nova (lavender baby spinosaurus, 25,000).
  All characters share collision/jump/speed rules; differences are cosmetic.
- Each dinosaur has a full preview/detail page with price, ownership, wallet,
  coin shortfall and Buy/Use actions. A purchase confirmation shows the exact
  deduction. Owned dinosaurs cannot be bought twice. Selection persists.
- Weekly gifts: 100, 150, 200, 250, 300, 400 and 600 gold. Claim one reward per
  local calendar day; after day 7 the next eligible visit begins a new cycle.
  Missed days pause reward progression; a separate consecutive-visit counter
  can reset without removing currency or resetting the reward track. No account,
  notifications, countdown pressure, lost-reward messages or ad viewing required.
- Store wallet, character ownership/selection, reward day and last-claim date
  together in one versioned local record. Offline device time is not a trusted
  anti-cheat clock; reject duplicate/backward-date claims, but do not claim that
  advancing the clock can be prevented without a server.

## Phase 0 — Plan and scope

Deliver this plan and record accepted choices. Commit:
`docs: plan gold coins, dinosaur shop and weekly gifts`.

## Phase 1 — Local wallet, catalog and migration

Add typed character metadata, a version-2 progress record, one-time star migration,
wallet credits, insufficient-funds protection, idempotent ownership and selection.
Keep existing best-score keys and settings. Purchases and claims are single-record
mutations, with serialized persistence and existing storage-error handling.
Gate: migration/reload, balance, duplicate purchase and selection tests.
Commit: `feat: add persistent coin wallet and dinosaur ownership`.

## Phase 2 — Coins and three difficulty levels

Add Hard without renaming saved Easy/Normal identities. Add ×1/×2/×3 rewards;
replace star rendering with clear gold coin visuals; spawn bounded trails and
bank earned gold exactly once. Update sounds, HUD, result breakdown and settings.
Gate: multiplier, coin placement/recycling, restart, collision and all-difficulty
simulation tests plus existing regressions.
Commit: `feat: add gold coin trails and difficulty reward multipliers`.

## Phase 3 — Three original character assets

Use built-in imagegen with the original dinosaur as a style reference. Create
three distinct, right-facing cartoon dinosaurs with real alpha transparency,
complete silhouettes, consistent framing and bottom foot alignment. Preserve
the original files and record prompts/provenance. Use bounded cached decodes and
the same gameplay hitboxes for every dinosaur.
Gate: inspect every asset, check files/alpha and catalog references.
Commit: `feat: add three illustrated dinosaur characters`.

## Phase 4 — Shop, previews and collection pages

Add a home wallet, separate shop and owned-collection routes, full character
preview pages, confirmed coin purchases and persistent Use selection. Make
navigation, prices and locked/owned/equipped states readable on phones/tablets
and large text. Preserve the settings, grown-ups and privacy flows.
Gate: preview without purchase, insufficient funds, confirm/cancel, duplicate
tap, select/reload and responsive widget checks.
Commit: `feat: add dinosaur shop previews and collection pages`.

## Phase 5 — Repeating weekly gifts

Implement an injected-clock reward service in progress storage and a seven-day
gift page. Home shows a quiet available indicator, without interrupting gameplay.
Save claims atomically with wallet balance; replaying UI events cannot pay twice.
Gate: same day, next day, missed day, backward date, day-7 wrap, reload and reset.
Commit: `feat: add repeating seven-day gifts and visit streaks`.

## Phase 6 — Ads seam, privacy, integration and release checks

Document a disabled ad-provider interface; no SDK, ad requests or ad-view rewards
in this release. Future live integration requires provider/account configuration,
a currently Families self-certified SDK version, child treatment, appropriate
content/format controls, consent handling where applicable, policy/Data safety
updates and testing. Do not claim the current no-ads policy covers a future SDK.

Update the privacy policy for coins, ownership and local reward/visit dates.
Run format/analyzer, regression/layout tests, Android debug build, native 16 KB
checks and browser purchase/collection/gift flows. Capture screenshots and record
physical-device/owner prerequisites. Keep Studio/emulator closed.
Commit: `chore: verify coin economy and document future ads integration`.

## Current ads answer and references

The Flutter app can technically support an ads plugin later. It currently has
no ads. Child-targeted ads must use eligible Families self-certified SDK versions,
avoid personalized/remarketing ads and meet Google Play's child ad-format rules.
Do not put ads over the jump area or show them unexpectedly on launch/death.

- [Google Play Families](https://support.google.com/googleplay/android-developer/answer/9893335)
- [AdMob Families guidance](https://support.google.com/admob/answer/6223431)
- [Current age treatment guidance](https://support.google.com/admob/answer/6219315)

## Execution log

- Phase 0: choices confirmed, repository clean, plan written. Implementation follows
  in phase order with a commit and push after each verified phase.
- Phase 0 pushed: `0a41cd0` — plan.
- Phase 1 pushed: `b443d86` — wallet/catalog, v1 migration and purchase tests.
- Phase 2 pushed: `05db7b5` — coin trails, Hard and ×1/×2/×3 rewards.
- Phase 3 pushed: `bfece2d` — generated/inspected three transparent character assets.
- Phase 4 pushed: `bc9d042` — shop, previews, collection and confirmed purchases.
- Phase 5 pushed: `2decbea` — repeating gifts, local dates and visit counts.
- Phase 6: all 43 tests and analyzer pass. Version 1.2.0+4 Android debug build,
  native ELF/ZIP 16 KB checks and browser flows passed. Browser confirmed a
  1,000-gold purchase, equipped collection, daily gift and persistence after
  reload, using a documented test-wallet fixture. No external requests/errors.

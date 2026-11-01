import 'dart:math';
import 'package:flutter/material.dart';
import 'dino_avatar.dart';
import 'dino_catalog.dart';
import 'dino_shop_page.dart';
import 'game_engine.dart';
import 'player_progress.dart';
import 'treasure_chest.dart';

const _ink = Color(0xFF173C35);

class AdventureHome extends StatelessWidget {
  const AdventureHome({
    super.key,
    required this.progress,
    required this.difficulty,
    required this.onPlay,
    required this.onShop,
    required this.onCollection,
    required this.onGifts,
    required this.onSettings,
    required this.onGrownUps,
  });
  final PlayerProgress progress;
  final Difficulty difficulty;
  final VoidCallback onPlay,
      onShop,
      onCollection,
      onGifts,
      onSettings,
      onGrownUps;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 8,
              spacing: 12,
              children: [
                const Text(
                  'Little Dino',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE8A8),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.monetization_on_rounded,
                        color: Color(0xFF805410),
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Gold ${formatGold(progress.coins)}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _AdventureStage(
              characterId: progress.selectedDino,
              color: progress.color,
              effects: progress.effects,
            ),
            if (progress.effects &&
                !MediaQuery.disableAnimationsOf(context)) ...[
              const SizedBox(height: 8),
              Text(
                'Tap ${characterById(progress.selectedDino).name} to hop!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF287350),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 64),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                textStyle: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              onPressed: onPlay,
              icon: const Icon(Icons.play_arrow_rounded, size: 34),
              label: Text(
                'Play · ${difficulty.label}',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap to jump. Tap again to jump higher!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            if (progress.storageError) ...[
              const SizedBox(height: 12),
              const Text(
                'Progress could not be saved on this device. You can still play.',
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: progress.retrySave,
                child: const Text('Try saving again'),
              ),
            ],
            const SizedBox(height: 18),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _PictureDestination(
                      title: 'Dino Shop',
                      subtitle: 'Meet new friends',
                      characterId: 'bramble',
                      background: const Color(0xFFE3F0E6),
                      onTap: onShop,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PictureDestination(
                      title: 'My Dinosaurs',
                      subtitle:
                          '${dinoCatalog.where((dino) => progress.owns(dino.id)).length} of 4 friends',
                      characterId: progress.selectedDino,
                      background: const Color(0xFFEAE6F7),
                      onTap: onCollection,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              button: true,
              onTap: onGifts,
              label: progress.giftAvailable
                  ? 'Weekly Gifts · Gift ready'
                  : 'Weekly Gifts',
              excludeSemantics: true,
              child: Material(
                color: const Color(0xFFFFEDC4),
                borderRadius: BorderRadius.circular(22),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onGifts,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const TreasureChest(
                          opened: false,
                          animate: false,
                          size: 64,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Weekly Gifts',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                progress.giftAvailable
                                    ? 'Your treasure is ready!'
                                    : 'See your treasure trail',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: _ink),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              children: [
                TextButton.icon(
                  onPressed: onSettings,
                  icon: const Icon(Icons.tune_rounded, size: 20),
                  label: const Text('Settings'),
                ),
                TextButton.icon(
                  onPressed: onGrownUps,
                  icon: const Icon(Icons.family_restroom_rounded, size: 20),
                  label: const Text('For grown-ups'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _PictureDestination extends StatelessWidget {
  const _PictureDestination({
    required this.title,
    required this.subtitle,
    required this.characterId,
    required this.background,
    required this.onTap,
  });
  final String title, subtitle, characterId;
  final Color background;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    onTap: onTap,
    label: title,
    excludeSemantics: true,
    child: Material(
      color: background,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 66,
                child: DinoAvatar(characterId: characterId, effects: false),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _AdventureStage extends StatefulWidget {
  const _AdventureStage({
    required this.characterId,
    required this.color,
    required this.effects,
  });
  final String characterId;
  final int color;
  final bool effects;
  @override
  State<_AdventureStage> createState() => _AdventureStageState();
}

class _AdventureStageState extends State<_AdventureStage>
    with SingleTickerProviderStateMixin {
  late final _hop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  bool _jumping = false;
  bool get _motion =>
      widget.effects && !MediaQuery.disableAnimationsOf(context);

  Future<void> _tryHop() async {
    if (_jumping || !_motion) return;
    setState(() => _jumping = true);
    await _hop.forward(from: 0);
    if (mounted) setState(() => _jumping = false);
  }

  @override
  void dispose() {
    _hop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final character = characterById(widget.characterId);
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stageHeight = (constraints.maxWidth / 1.3).clamp(240.0, 340.0);
          final height =
              stageHeight +
              max(0, MediaQuery.textScalerOf(context).scale(19) - 19) * 4;
          return SizedBox(
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/runtime/home-jungle.png',
                  fit: BoxFit.cover,
                  cacheWidth: 1000,
                  excludeFromSemantics: true,
                ),
                Positioned(
                  left: 16,
                  top: 16,
                  right: 16,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9EC).withValues(alpha: .96),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        child: Text(
                          'Let’s explore with ${character.name}!',
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: constraints.maxWidth * .17,
                  bottom: stageHeight * .10,
                  width: stageHeight * .66,
                  height: stageHeight * .66,
                  child: Semantics(
                    button: _motion,
                    label: 'Try a hop with ${character.name}',
                    excludeSemantics: true,
                    onTap: _motion ? _tryHop : null,
                    child: GestureDetector(
                      onTap: _motion ? _tryHop : null,
                      child: AnimatedBuilder(
                        animation: _hop,
                        builder: (context, _) {
                          final inAir = _motion && _jumping && _hop.value < .85;
                          final landing = _motion && _jumping && !inAir;
                          final lift = inAir
                              ? sin(_hop.value / .85 * pi) * 34
                              : 0.0;
                          return Transform.translate(
                            offset: Offset(0, -lift),
                            child: DinoAvatar(
                              characterId: character.id,
                              color: widget.color,
                              running: true,
                              distance: 3.34,
                              jumping: inAir,
                              landing: landing,
                              effects: widget.effects,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

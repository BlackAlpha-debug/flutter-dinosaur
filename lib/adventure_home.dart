import 'dart:math';
import 'package:flutter/material.dart';
import 'dino_avatar.dart';
import 'dino_catalog.dart';
import 'dino_shop_page.dart';
import 'game_engine.dart';
import 'player_progress.dart';

const _ink = Color(0xFF214E3E);
const _paper = Color(0xFFFFFAF2);

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
  Widget build(BuildContext context) {
    final character = characterById(progress.selectedDino);
    final motion = progress.effects && !MediaQuery.disableAnimationsOf(context);
    return ColoredBox(
      color: _paper,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Semantics(
                    label: 'Gold ${formatGold(progress.coins)}',
                    excludeSemantics: true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEFC7),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.monetization_on_rounded,
                            size: 19,
                            color: Color(0xFF8A651E),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              formatGold(progress.coins),
                              style: const TextStyle(
                                color: Color(0xFF795716),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Little Dino',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _ink,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.6,
                    height: 1.1,
                  ),
                ),
                _CharacterStage(
                  characterId: character.id,
                  color: progress.color,
                  effects: progress.effects,
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1E3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      character.name,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                if (motion) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Tap ${character.name} to hop!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF557564),
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: _ink.withValues(alpha: .16),
                        offset: const Offset(0, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF28694F),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 66),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 26,
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
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tap to jump. Tap again to jump higher!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF557564),
                    fontSize: 12,
                    height: 1.4,
                  ),
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
                const SizedBox(height: 26),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked =
                        constraints.maxWidth < 280 ||
                        MediaQuery.textScalerOf(context).scale(14) > 21;
                    final shortcuts = [
                      _HomeShortcut(
                        label: 'Dino Shop',
                        icon: Icons.storefront_rounded,
                        color: const Color(0xFF8B681F),
                        background: const Color(0xFFFFEFC8),
                        stacked: stacked,
                        onTap: onShop,
                      ),
                      _HomeShortcut(
                        label: 'My Dinosaurs',
                        icon: Icons.pets_rounded,
                        color: const Color(0xFF7862A6),
                        background: const Color(0xFFEDE7F9),
                        stacked: stacked,
                        onTap: onCollection,
                      ),
                      _HomeShortcut(
                        label: 'Weekly Gifts',
                        semanticLabel: progress.giftAvailable
                            ? 'Weekly Gifts · Gift ready'
                            : 'Weekly Gifts',
                        icon: Icons.card_giftcard_rounded,
                        color: const Color(0xFFAC6255),
                        background: const Color(0xFFFFE5DD),
                        ready: progress.giftAvailable,
                        stacked: stacked,
                        onTap: onGifts,
                      ),
                    ];
                    if (stacked) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: shortcuts,
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final shortcut in shortcuts)
                          Expanded(child: shortcut),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  children: [
                    TextButton.icon(
                      onPressed: onSettings,
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: const Text('Settings'),
                    ),
                    TextButton.icon(
                      onPressed: onGrownUps,
                      icon: const Icon(Icons.family_restroom_rounded, size: 18),
                      label: const Text('For grown-ups'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeShortcut extends StatelessWidget {
  const _HomeShortcut({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
    required this.stacked,
    required this.onTap,
    this.semanticLabel,
    this.ready = false,
  });
  final String label;
  final String? semanticLabel;
  final IconData icon;
  final Color color, background;
  final bool ready, stacked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final picture = SizedBox.square(
      dimension: stacked ? 52 : 60,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 29, color: color),
          ),
          if (ready)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8B44A),
                  shape: BoxShape.circle,
                  border: Border.all(color: _paper, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
    final title = Text(
      label,
      textAlign: stacked ? TextAlign.start : TextAlign.center,
      style: const TextStyle(
        color: _ink,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
    return Semantics(
      button: true,
      onTap: onTap,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            child: stacked
                ? Row(
                    children: [
                      picture,
                      const SizedBox(width: 16),
                      Expanded(child: title),
                      const Icon(Icons.chevron_right_rounded, color: _ink),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [picture, const SizedBox(height: 10), title],
                  ),
          ),
        ),
      ),
    );
  }
}

class _CharacterStage extends StatefulWidget {
  const _CharacterStage({
    required this.characterId,
    required this.color,
    required this.effects,
  });
  final String characterId;
  final int color;
  final bool effects;
  @override
  State<_CharacterStage> createState() => _CharacterStageState();
}

class _CharacterStageState extends State<_CharacterStage>
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(238.0, constraints.maxWidth * .76);
        return SizedBox(
          height: size + 44,
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: size * .94,
                    height: size * .94,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0xFFFFF0C9), Color(0xFFF0F3DF)],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 7,
                left: (constraints.maxWidth - size * .5) / 2,
                width: size * .5,
                height: 9,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _ink.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: _ink.withValues(alpha: .08),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: (constraints.maxWidth - size) / 2,
                width: size,
                height: size,
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
                        return Transform.translate(
                          offset: Offset(
                            0,
                            inAir ? -sin(_hop.value / .85 * pi) * 36 : 0,
                          ),
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
    );
  }
}

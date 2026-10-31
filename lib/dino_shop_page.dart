import 'dart:math';
import 'package:flutter/material.dart';
import 'dino_avatar.dart';
import 'dino_catalog.dart';
import 'player_progress.dart';

String formatGold(int value) => value.toString().replaceAllMapped(
  RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
  (match) => '${match[1]},',
);

class DinoShopPage extends StatelessWidget {
  const DinoShopPage({
    super.key,
    required this.progress,
    this.ownedOnly = false,
  });
  final PlayerProgress progress;
  final bool ownedOnly;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(ownedOnly ? 'My Dinosaurs' : 'Dino Shop')),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: progress,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Your gold: ${formatGold(progress.coins)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Earned game coins only. No real-money purchases.\nEvery dinosaur has the same jump and speed.',
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth >= 600
                          ? (constraints.maxWidth - 16) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          for (final dino in dinoCatalog.where(
                            (dino) => !ownedOnly || progress.owns(dino.id),
                          ))
                            SizedBox(
                              width: width,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 145,
                                        child: DinoAvatar(
                                          characterId: dino.id,
                                          effects: false,
                                          color: progress.color,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        dino.name,
                                        style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        dino.species,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        progress.selectedDino == dino.id
                                            ? 'Equipped'
                                            : progress.owns(dino.id)
                                            ? 'Owned'
                                            : '${formatGold(dino.price)} gold',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      OutlinedButton(
                                        onPressed: () =>
                                            Navigator.of(context).push(
                                              MaterialPageRoute<void>(
                                                builder: (_) => DinoPreviewPage(
                                                  progress: progress,
                                                  character: dino,
                                                ),
                                              ),
                                            ),
                                        child: Text('Preview ${dino.name}'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class DinoPreviewPage extends StatefulWidget {
  const DinoPreviewPage({
    super.key,
    required this.progress,
    required this.character,
  });
  final PlayerProgress progress;
  final DinoCharacter character;
  @override
  State<DinoPreviewPage> createState() => _DinoPreviewPageState();
}

class _DinoPreviewPageState extends State<DinoPreviewPage>
    with SingleTickerProviderStateMixin {
  late final _hop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  @override
  void dispose() {
    _hop.dispose();
    super.dispose();
  }

  Future<void> _buy() async {
    final dino = widget.character;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text('Welcome ${dino.name}?'),
        content: Text(
          'Spend ${formatGold(dino.price)} earned gold coins?\n'
          'Your balance is ${formatGold(widget.progress.coins)} gold.\nNo real money is used.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Buy and use'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = widget.progress.purchase(dino.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result == PurchaseResult.purchased
              ? '${dino.name} is ready to play!'
              : result == PurchaseResult.alreadyOwned
              ? 'You already own ${dino.name}.'
              : 'Not enough gold yet.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.character.name)),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: widget.progress,
        builder: (context, _) {
          final dino = widget.character, progress = widget.progress;
          final owned = progress.owns(dino.id),
              equipped = progress.selectedDino == dino.id;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 240,
                      child: AnimatedBuilder(
                        animation: _hop,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(0, -sin(_hop.value * pi) * 25),
                          child: child,
                        ),
                        child: DinoAvatar(
                          characterId: dino.id,
                          color: progress.color,
                          effects: false,
                        ),
                      ),
                    ),
                    Text(
                      dino.species,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(dino.description, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: () {
                        if (!MediaQuery.disableAnimationsOf(context) &&
                            progress.effects)
                          _hop.forward(from: 0);
                      },
                      child: const Text('Try a hop'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your gold: ${formatGold(progress.coins)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (owned)
                      FilledButton(
                        onPressed: equipped
                            ? null
                            : () => progress.selectDino(dino.id),
                        child: Text(equipped ? 'Equipped' : 'Use ${dino.name}'),
                      )
                    else ...[
                      FilledButton(
                        onPressed: progress.coins >= dino.price ? _buy : null,
                        child: Text('Buy for ${formatGold(dino.price)} gold'),
                      ),
                      if (progress.coins < dino.price)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            '${formatGold(dino.price - progress.coins)} more gold to go.\n'
                            'Play whenever you like to earn coins.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Same abilities as every dinosaur. Your purchase stays on this device.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'dino_shop_page.dart';
import 'player_progress.dart';
import 'treasure_chest.dart';

const _forest = Color(0xFF173C35);
const _mint = Color(0xFFE8F2E8);

class WeeklyGiftsPage extends StatelessWidget {
  const WeeklyGiftsPage({super.key, required this.progress});
  final PlayerProgress progress;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Weekly Gifts')),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: progress,
        builder: (context, _) {
          final available = progress.giftAvailable;
          // Keep the completed seventh stop visible until the next visit day.
          final completed = !available && progress.nextGift == 0
              ? 7
              : progress.nextGift;
          final today = available ? progress.nextGift : completed - 1;
          final amount = PlayerProgress.giftRewards[today];
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _Pill(
                          icon: Icons.monetization_on_rounded,
                          label: 'Your gold: ${formatGold(progress.coins)}',
                        ),
                        _Pill(
                          icon: Icons.eco_rounded,
                          label: 'Visit streak: ${progress.visitStreak}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _mint,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFCCDCCB)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            available
                                ? 'A little treasure for you'
                                : 'Treasure collected!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _forest,
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            available
                                ? 'Gift ${today + 1} is ready to open.'
                                : '$amount gold is now in your collection.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          TreasureChest(
                            opened: !available,
                            animate:
                                progress.effects &&
                                !MediaQuery.disableAnimationsOf(context),
                            size: 144,
                          ),
                          Text(
                            '$amount gold',
                            style: const TextStyle(
                              color: _forest,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: _forest,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              onPressed: available ? progress.claimGift : null,
                              icon: Icon(
                                available
                                    ? Icons.redeem_rounded
                                    : Icons.check_circle_rounded,
                              ),
                              label: Text(
                                available
                                    ? 'Claim ${progress.nextGiftAmount} gold'
                                    : 'Gift claimed for today',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            available
                                ? 'One gift per day. Yours whenever you visit.'
                                : 'Next gift: ${progress.nextGiftAmount} gold on a new day.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _forest,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (progress.storageError)
                      TextButton(
                        onPressed: progress.retrySave,
                        child: const Text('Saving unavailable. Tap to retry.'),
                      ),
                    const SizedBox(height: 28),
                    const Text(
                      'Your treasure trail',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('$completed of 7 gifts collected on this trail'),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: completed / 7,
                        minHeight: 8,
                        color: const Color(0xFF387658),
                        backgroundColor: const Color(0xFFE2E8DC),
                        semanticsLabel:
                            'Gift trail, $completed of 7 gifts collected',
                      ),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final singleColumn =
                            constraints.maxWidth <
                            140 * MediaQuery.textScalerOf(context).scale(1) * 2;
                        Widget stop(int index, {bool finale = false}) =>
                            _GiftStop(
                              index: index,
                              collected: index < completed,
                              ready: available && index == today,
                              finale: finale,
                            );
                        if (singleColumn) {
                          return Column(
                            children: [
                              for (var i = 0; i < 7; i++) ...[
                                stop(i, finale: i == 6),
                                if (i < 6) const _TrailLink(center: true),
                              ],
                            ],
                          );
                        }
                        return Column(
                          children: [
                            for (var row = 0; row < 3; row++) ...[
                              IntrinsicHeight(
                                child: Row(
                                  textDirection: row.isEven
                                      ? TextDirection.ltr
                                      : TextDirection.rtl,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(child: stop(row * 2)),
                                    const SizedBox(
                                      width: 12,
                                      child: Center(
                                        child: Icon(
                                          Icons.more_horiz,
                                          size: 12,
                                          color: Color(0xFF94B39B),
                                        ),
                                      ),
                                    ),
                                    Expanded(child: stop(row * 2 + 1)),
                                  ],
                                ),
                              ),
                              _TrailLink(right: row.isEven, center: row == 2),
                            ],
                            stop(6, finale: true),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'After gift 7, a fresh trail begins.\nMiss a day? Your gifts stay right here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(height: 1.6),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Earned game gold only · No ads · No account',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
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

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .7),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: const Color(0xFFE2E8DC)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: _forest),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _GiftStop extends StatelessWidget {
  const _GiftStop({
    required this.index,
    required this.collected,
    required this.ready,
    this.finale = false,
  });
  final int index;
  final bool collected, ready, finale;

  @override
  Widget build(BuildContext context) {
    final status = collected
        ? 'Collected'
        : ready
        ? 'Ready today'
        : 'Upcoming';
    return Semantics(
      container: true,
      label:
          'Gift ${index + 1}, ${PlayerProgress.giftRewards[index]} gold, $status',
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: finale
              ? const Color(0xFFFFEDBB)
              : ready
              ? const Color(0xFFFFF2CF)
              : collected
              ? _mint
              : const Color(0xFFF3F4EB),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: ready ? const Color(0xFFAA761B) : const Color(0xFFD8E2D3),
            width: ready ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              finale ? 'GIFT 7 · THE BIG TREASURE' : 'GIFT ${index + 1}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: .8,
              ),
            ),
            const SizedBox(height: 10),
            if (finale)
              TreasureChest(opened: collected, animate: false, size: 88)
            else
              Icon(
                collected
                    ? Icons.check_circle_rounded
                    : ready
                    ? Icons.redeem_rounded
                    : Icons.monetization_on_rounded,
                size: 34,
                color: collected
                    ? const Color(0xFF387658)
                    : const Color(0xFF91600C),
              ),
            const SizedBox(height: 8),
            Text(
              '${PlayerProgress.giftRewards[index]} gold',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrailLink extends StatelessWidget {
  const _TrailLink({this.right = false, this.center = false});
  final bool right, center;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 26,
    width: double.infinity,
    child: FractionallySizedBox(
      alignment: center
          ? Alignment.center
          : right
          ? const Alignment(.5, 0)
          : const Alignment(-.5, 0),
      widthFactor: .08,
      child: const Center(
        child: Icon(Icons.more_vert, color: Color(0xFF94B39B), size: 24),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'player_progress.dart';
import 'dino_shop_page.dart';

class WeeklyGiftsPage extends StatelessWidget {
  const WeeklyGiftsPage({super.key, required this.progress});
  final PlayerProgress progress;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Weekly Gifts')),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: progress,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.card_giftcard_rounded,
                    size: 64,
                    color: Color(0xFFB8860B),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your gold: ${formatGold(progress.coins)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Seven gifts, one per visit day. After gift 7, a new week of gifts begins.\n'
                    'Missed days never remove your reward progress.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Consecutive visit days: ${progress.visitStreak}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  for (var i = 0; i < PlayerProgress.giftRewards.length; i++)
                    Card(
                      child: ListTile(
                        leading: Icon(
                          i == progress.nextGift
                              ? Icons.redeem
                              : Icons.monetization_on_outlined,
                        ),
                        title: Text('Gift ${i + 1}'),
                        subtitle: Text('${PlayerProgress.giftRewards[i]} gold'),
                        trailing: i == progress.nextGift
                            ? const Icon(Icons.arrow_forward_rounded)
                            : null,
                      ),
                    ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: progress.giftAvailable
                        ? () {
                            final amount = progress.claimGift();
                            if (amount > 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '$amount gold added. Enjoy your adventure!',
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                    child: Text(
                      progress.giftAvailable
                          ? 'Claim ${progress.nextGiftAmount} gold'
                          : 'Gift claimed for today',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Come back whenever you like. No account or ads needed.',
                    textAlign: TextAlign.center,
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

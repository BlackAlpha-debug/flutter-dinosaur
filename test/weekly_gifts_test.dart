import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dinosaur/player_progress.dart';
import 'player_progress_test.dart' show MemoryBackend;

void main() {
  test('one claim per date, repeat after seven days, and persist', () async {
    var now = DateTime(2026, 11, 1, 12);
    final backend = MemoryBackend();
    final progress = PlayerProgress(backend: backend, clock: () => now);
    for (var i = 0; i < 7; i++) {
      expect(progress.claimGift(), PlayerProgress.giftRewards[i]);
      expect(progress.claimGift(), 0);
      now = now.add(const Duration(days: 1));
    }
    expect(progress.coins, 2000);
    expect(progress.nextGift, 0);
    expect(progress.claimGift(), 100);
    expect(progress.visitStreak, 8);
    await progress.flush();
    final again = PlayerProgress(backend: backend, clock: () => now);
    await again.load();
    expect(again.claimGift(), 0);
    expect(again.coins, 2100);
    expect(again.nextGift, 1);
    again.reset();
    expect(again.nextGift, 0);
    expect(again.coins, 0);
  });
  test(
    'missing days preserves reward track; clock rollback cannot duplicate',
    () {
      var now = DateTime(2026, 11, 1);
      final progress = PlayerProgress(clock: () => now);
      progress.claimGift();
      now = now.subtract(const Duration(days: 1));
      expect(progress.claimGift(), 0);
      now = DateTime(2026, 11, 5);
      expect(progress.nextGift, 1);
      expect(progress.visitStreak, 0);
      expect(progress.claimGift(), 150);
      expect(progress.visitStreak, 1);
    },
  );
}

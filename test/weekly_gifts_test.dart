import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dinosaur/weekly_gifts_page.dart';
import 'package:flutter_dinosaur/player_progress.dart';
import 'player_progress_test.dart' show MemoryBackend;

void main() {
  testWidgets('trail keeps the seventh gift completed until the next day', (
    tester,
  ) async {
    var now = DateTime(2026, 11, 1);
    final progress = PlayerProgress(clock: () => now);
    await tester.pumpWidget(
      MaterialApp(home: WeeklyGiftsPage(progress: progress)),
    );
    for (var gift = 0; gift < 7; gift++) {
      if (gift > 0) {
        now = now.add(const Duration(days: 1));
        progress.refreshCalendar();
        await tester.pumpAndSettle();
      }
      final claim = find.text('Claim ${PlayerProgress.giftRewards[gift]} gold');
      await tester.ensureVisible(claim);
      await tester.tap(claim);
      await tester.pumpAndSettle();
      expect(find.text('Treasure collected!'), findsOneWidget);
      expect(
        find.text('${gift + 1} of 7 gifts collected on this trail'),
        findsOneWidget,
      );
      expect(find.text('Gift claimed for today'), findsOneWidget);
    }
    expect(progress.coins, 2000);
    expect(find.text('Next gift: 100 gold on a new day.'), findsOneWidget);
    now = now.add(const Duration(days: 1));
    progress.refreshCalendar();
    await tester.pumpAndSettle();
    expect(find.text('0 of 7 gifts collected on this trail'), findsOneWidget);
    expect(find.text('Claim 100 gold'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    progress.dispose();
  });

  test('opening on consecutive days counts visits even without claiming', () {
    var now = DateTime(2026, 11, 1);
    final progress = PlayerProgress(clock: () => now);
    progress.recordVisit();
    progress.claimGift();
    now = now.add(const Duration(days: 1));
    progress.recordVisit();
    now = now.add(const Duration(days: 1));
    progress.recordVisit();
    expect(progress.visitStreak, 3);
    expect(progress.claimGift(), 150);
    expect(progress.visitStreak, 3);
  });
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

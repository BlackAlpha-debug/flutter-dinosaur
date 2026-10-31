import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dinosaur/dino_shop_page.dart';
import 'package:flutter_dinosaur/player_progress.dart';
import 'package:flutter_dinosaur/weekly_gifts_page.dart';
import 'package:flutter_dinosaur/dino_catalog.dart';

void main() {
  for (final size in [
    const Size(320, 480),
    const Size(640, 320),
    const Size(800, 1280),
  ]) {
    testWidgets('shop, preview and gift pages fit $size with large text', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final progress = PlayerProgress();
      Widget shell(Widget home) => MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: home,
      );
      await tester.pumpWidget(shell(DinoShopPage(progress: progress)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        shell(DinoPreviewPage(progress: progress, character: dinoCatalog.last)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(shell(WeeklyGiftsPage(progress: progress)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Claim 100 gold'));
      await tester.tap(find.text('Claim 100 gold'));
      await tester.pumpAndSettle();
      expect(progress.coins, 100);
      expect(find.text('Gift claimed for today'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await progress.flush();
      progress.dispose();
    });
  }
  testWidgets('preview, cancel, purchase and duplicate protection', (
    tester,
  ) async {
    final progress = PlayerProgress()..addCoins(1200);
    await tester.pumpWidget(
      MaterialApp(home: DinoShopPage(progress: progress)),
    );
    await tester.ensureVisible(find.text('Preview Bramble'));
    await tester.tap(find.text('Preview Bramble'));
    await tester.pumpAndSettle();
    expect(progress.owns('bramble'), false);
    await tester.ensureVisible(find.text('Buy for 1,000 gold'));
    await tester.tap(find.text('Buy for 1,000 gold'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(progress.coins, 1200);
    await tester.tap(find.text('Buy for 1,000 gold'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buy and use'));
    await tester.pumpAndSettle();
    expect(progress.coins, 200);
    expect(progress.selectedDino, 'bramble');
    expect(find.text('Equipped'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await progress.flush();
    progress.dispose();
  });
}

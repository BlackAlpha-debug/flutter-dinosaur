import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dinosaur/dino_shop_page.dart';
import 'package:flutter_dinosaur/player_progress.dart';

void main() {
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

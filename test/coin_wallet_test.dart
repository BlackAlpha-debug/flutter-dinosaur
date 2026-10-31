import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dinosaur/player_progress.dart';
import 'package:flutter_dinosaur/dino_catalog.dart';
import 'player_progress_test.dart' show MemoryBackend;

void main() {
  test('v1 stars migrate once without losing scores or settings', () async {
    final backend = MemoryBackend()
      ..data = '{"version":1,"stars":12,"best_easy":70,"sound":false}';
    final progress = PlayerProgress(backend: backend);
    await progress.load();
    expect(progress.coins, 120);
    expect(progress.sound, false);
    final again = PlayerProgress(backend: backend);
    await again.load();
    expect(again.coins, 120);
    expect(again.stars, 12);
  });
  test(
    'purchase spends once, owns permanently and persists selection',
    () async {
      final backend = MemoryBackend();
      final progress = PlayerProgress(backend: backend);
      expect(progress.purchase('bramble'), PurchaseResult.insufficientCoins);
      expect(progress.selectDino('nova'), false);
      progress.addCoins(1200);
      expect(progress.purchase('bramble'), PurchaseResult.purchased);
      expect(progress.coins, 200);
      expect(progress.purchase('bramble'), PurchaseResult.alreadyOwned);
      expect(progress.coins, 200);
      await progress.flush();
      final again = PlayerProgress(backend: backend);
      await again.load();
      expect(again.owns('bramble'), true);
      expect(again.selectedDino, 'bramble');
      again.reset();
      await again.flush();
      expect(again.coins, 0);
      expect(again.owns('bramble'), false);
      expect(again.owns('sprout'), true);
    },
  );
}

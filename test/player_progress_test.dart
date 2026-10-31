import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dinosaur/game_engine.dart';
import 'package:flutter_dinosaur/player_progress.dart';

class MemoryBackend implements ProgressBackend {
  String? data;
  bool fails = false;
  @override
  Future<String?> read() async => data;
  @override
  Future<void> write(String value) async {
    if (fails) throw StateError('Disk unavailable');
    await Future<void>.delayed(Duration.zero);
    data = value;
  }
}

void main() {
  test(
    'scores, unlocks and settings survive a reload and remain per difficulty',
    () async {
      final backend = MemoryBackend();
      final progress = PlayerProgress(backend: backend);
      progress.record(Difficulty.easy, 50);
      progress.record(Difficulty.easy, 20);
      progress.record(Difficulty.normal, 12);
      progress.addStars(10);
      progress.setColor(1);
      progress.setDifficulty(Difficulty.normal);
      progress.setSound(false);
      progress.setEffects(false);
      await progress.flush();
      final reloaded = PlayerProgress(backend: backend);
      await reloaded.load();
      expect(reloaded.best(Difficulty.easy), 50);
      expect(reloaded.best(Difficulty.normal), 12);
      expect(reloaded.stars, 10);
      expect(reloaded.color, 1);
      expect(reloaded.sound, isFalse);
      expect(reloaded.effects, isFalse);
      expect(reloaded.difficulty, Difficulty.normal);
    },
  );

  test(
    'locked colors cannot be selected and reset persists after queued writes',
    () async {
      final backend = MemoryBackend();
      final progress = PlayerProgress(backend: backend);
      progress.setColor(2);
      expect(progress.color, 0);
      progress.addStars(30);
      progress.setColor(2);
      progress.reset();
      await progress.flush();
      final reloaded = PlayerProgress(backend: backend);
      await reloaded.load();
      expect(reloaded.stars, 0);
      expect(reloaded.color, 0);
      expect(reloaded.best(Difficulty.easy), 0);
    },
  );

  test(
    'failed writes keep in-memory progress and a later retry recovers',
    () async {
      final backend = MemoryBackend()..fails = true;
      final progress = PlayerProgress(backend: backend);
      progress.addStars(2);
      await progress.flush();
      expect(progress.storageError, isTrue);
      expect(progress.stars, 2);
      backend.fails = false;
      progress.retrySave();
      await progress.flush();
      expect(progress.storageError, isFalse);
      expect(backend.data, contains('"stars":2'));
    },
  );

  test('corrupt storage does not prevent playing', () async {
    final backend = MemoryBackend()..data = 'invalid';
    final progress = PlayerProgress(backend: backend);
    await progress.load();
    expect(progress.storageError, isTrue);
    expect(progress.stars, 0);
    expect(progress.difficulty, Difficulty.easy);
  });
}

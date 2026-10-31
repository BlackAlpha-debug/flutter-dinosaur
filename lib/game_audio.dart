import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

abstract class GameAudio {
  Future<void> play(String sound);
  Future<void> stop();
  Future<void> dispose();
}

/// Bundled effects only. No URL sources, microphone, music or network access.
class LocalGameAudio implements GameAudio {
  AudioPlayer? _jump;
  AudioPlayer? _reward;
  Future<void> _pending = Future.value();
  int _generation = 0;
  bool _disposed = false;

  @override
  Future<void> play(String sound) {
    final generation = _generation;
    _pending = _pending.then((_) async {
      if (_disposed || generation != _generation) return;
      try {
        final player = sound == 'jump'
            ? (_jump ??= AudioPlayer())
            : (_reward ??= AudioPlayer());
        await player.play(AssetSource('audio/$sound.wav'), volume: 0.3);
      } catch (error) {
        // Audio is optional; plugin/device failure must not end a run.
        debugPrint('Local sound unavailable: $error');
      }
    });
    return _pending;
  }

  @override
  Future<void> stop() {
    _generation++;
    _pending = _pending.then((_) async {
      if (_disposed) return;
      try {
        await Future.wait([
          if (_jump != null) _jump!.stop(),
          if (_reward != null) _reward!.stop(),
        ]);
      } catch (error) {
        debugPrint('Could not stop optional audio: $error');
      }
    });
    return _pending;
  }

  @override
  Future<void> dispose() async {
    await stop();
    _disposed = true;
    try {
      await Future.wait([
        if (_jump != null) _jump!.dispose(),
        if (_reward != null) _reward!.dispose(),
      ]);
    } catch (error) {
      debugPrint('Could not dispose optional audio: $error');
    }
  }
}

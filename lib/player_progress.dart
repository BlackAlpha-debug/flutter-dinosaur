import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_engine.dart';

abstract class ProgressBackend {
  Future<String?> read();
  Future<void> write(String value);
}

class DeviceProgressBackend implements ProgressBackend {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  static const key = 'little_dino.progress.v1';
  @override
  Future<String?> read() => _preferences.getString(key);
  @override
  Future<void> write(String value) => _preferences.setString(key, value);
}

/// Only noncritical game preferences are stored. Never stores identifiers.
class PlayerProgress extends ChangeNotifier {
  PlayerProgress({this.backend});
  final ProgressBackend? backend;
  final Map<String, int> _best = {};
  Difficulty difficulty = Difficulty.easy;
  int stars = 0;
  int color = 0;
  bool effects = true;
  bool sound = true;
  bool storageError = false;
  Future<void> _pending = Future.value();
  bool _disposed = false;
  static const colorCosts = [0, 10, 25];

  int best(Difficulty mode) => _best[mode.name] ?? 0;
  bool unlocked(int value) =>
      value >= 0 && value < colorCosts.length && stars >= colorCosts[value];

  Future<void> load() async {
    if (backend == null) return;
    try {
      final raw = await backend!.read();
      if (raw == null) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (data['version'] != 1) {
        throw const FormatException('Unknown progress version');
      }
      difficulty = Difficulty.values.firstWhere(
        (d) => d.name == data['difficulty'],
        orElse: () => Difficulty.easy,
      );
      stars = max(0, (data['stars'] as num?)?.toInt() ?? 0);
      effects = data['effects'] as bool? ?? true;
      sound = data['sound'] as bool? ?? true;
      for (final mode in Difficulty.values) {
        _best[mode.name] = max(
          0,
          (data['best_${mode.name}'] as num?)?.toInt() ?? 0,
        );
      }
      final savedColor = (data['color'] as num?)?.toInt() ?? 0;
      color = unlocked(savedColor) ? savedColor : 0;
    } catch (error) {
      storageError = true;
      debugPrint('Could not load local game progress: $error');
    }
  }

  void setDifficulty(Difficulty value) {
    difficulty = value;
    _save();
  }

  void setEffects(bool value) {
    effects = value;
    _save();
  }

  void setSound(bool value) {
    sound = value;
    _save();
  }

  void setColor(int value) {
    if (unlocked(value)) {
      color = value;
      _save();
    }
  }

  void addStars(int value) {
    if (value > 0) {
      stars += value;
      _save();
    }
  }

  void record(Difficulty mode, int score) {
    if (score > best(mode)) {
      _best[mode.name] = score;
      _save();
    }
  }

  void reset() {
    _best.clear();
    stars = 0;
    color = 0;
    difficulty = Difficulty.easy;
    effects = true;
    sound = true;
    _save();
  }

  void retrySave() => _save();
  Future<void> flush() => _pending;

  void _save() {
    final snapshot = jsonEncode({
      'version': 1,
      'difficulty': difficulty.name,
      'stars': stars,
      'color': color,
      'effects': effects,
      'sound': sound,
      for (final mode in Difficulty.values) 'best_${mode.name}': best(mode),
    });
    _pending = _pending.then((_) async {
      try {
        await backend?.write(snapshot);
        storageError = false;
      } catch (error) {
        storageError = true;
        debugPrint('Could not save local game progress: $error');
      }
      if (!_disposed) notifyListeners();
    });
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

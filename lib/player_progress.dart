import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_engine.dart';
import 'dino_catalog.dart';

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
  PlayerProgress({this.backend, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;
  final ProgressBackend? backend;
  final DateTime Function() _clock;
  static const giftRewards = [100, 150, 200, 250, 300, 400, 600];
  int? _lastClaimDay;
  int? _lastVisitDay;
  int _nextGift = 0;
  int _visitStreak = 0;
  int get nextGift => _nextGift;
  int get nextGiftAmount => giftRewards[_nextGift];
  void refreshCalendar() => notifyListeners();
  int get _today {
    final now = _clock();
    return DateTime.utc(now.year, now.month, now.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
  }

  bool get giftAvailable => _lastClaimDay == null || _today > _lastClaimDay!;
  int get visitStreak =>
      _lastVisitDay != null && _today - _lastVisitDay! <= 1 ? _visitStreak : 0;

  bool _recordVisit(int today) {
    if (_lastVisitDay != null && today <= _lastVisitDay!) return false;
    _visitStreak = _lastVisitDay == today - 1 ? _visitStreak + 1 : 1;
    _lastVisitDay = today;
    return true;
  }

  void recordVisit() {
    if (_recordVisit(_today)) _save();
  }

  int claimGift() {
    final today = _today;
    if (_lastClaimDay != null && today <= _lastClaimDay!) return 0;
    final amount = nextGiftAmount;
    _recordVisit(today);
    _lastClaimDay = today;
    _nextGift = (_nextGift + 1) % giftRewards.length;
    _coins += amount;
    _save();
    return amount;
  }

  final Map<String, int> _best = {};
  Difficulty difficulty = Difficulty.easy;
  // Legacy lifetime pickup count preserves previously unlocked Sprout colors.
  int stars = 0;
  int _coins = 0;
  final Set<String> _owned = {'sprout'};
  String _selectedDino = 'sprout';
  int get coins => _coins;
  String get selectedDino => _selectedDino;
  bool owns(String id) => _owned.contains(id);
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
      if (data['version'] != 1 && data['version'] != 2) {
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
      _coins = max(0, (data['coins'] as num?)?.toInt() ?? stars * 10);
      _owned.addAll(
        (data['owned'] as List<dynamic>? ?? []).whereType<String>().where(
          (id) => dinoCatalog.any((dino) => dino.id == id),
        ),
      );
      final selected = data['selectedDino'] as String? ?? 'sprout';
      _selectedDino = owns(selected) ? selected : 'sprout';
      _lastClaimDay = (data['lastClaimDay'] as num?)?.toInt();
      _lastVisitDay = (data['lastVisitDay'] as num?)?.toInt() ?? _lastClaimDay;
      _nextGift = ((data['nextGift'] as num?)?.toInt() ?? 0).clamp(0, 6);
      _visitStreak = max(0, (data['visitStreak'] as num?)?.toInt() ?? 0);
      if (data['version'] == 1) {
        _save();
        await flush();
      }
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
      _coins += value * 10;
      _save();
    }
  }

  void addCoins(int amount) {
    if (amount <= 0) return;
    _coins += amount;
    _save();
  }

  void creditRunPickups(int pickups, int multiplier) {
    if (pickups <= 0 || multiplier < 1 || multiplier > 3) return;
    stars += pickups;
    _coins += pickups * 10 * multiplier;
    _save();
  }

  PurchaseResult purchase(String id) {
    final matches = dinoCatalog.where((dino) => dino.id == id);
    if (matches.isEmpty) return PurchaseResult.unknownCharacter;
    if (owns(id)) return PurchaseResult.alreadyOwned;
    final dino = matches.single;
    if (_coins < dino.price) return PurchaseResult.insufficientCoins;
    _coins -= dino.price;
    _owned.add(id);
    _selectedDino = id;
    _save();
    return PurchaseResult.purchased;
  }

  bool selectDino(String id) {
    if (!owns(id)) return false;
    _selectedDino = id;
    _save();
    return true;
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
    _coins = 0;
    _owned
      ..clear()
      ..add('sprout');
    _selectedDino = 'sprout';
    _lastClaimDay = null;
    _lastVisitDay = null;
    _nextGift = 0;
    _visitStreak = 0;
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
      'version': 2,
      'lastClaimDay': _lastClaimDay,
      'lastVisitDay': _lastVisitDay,
      'nextGift': _nextGift,
      'visitStreak': _visitStreak,
      'coins': _coins,
      'owned': _owned.toList(),
      'selectedDino': _selectedDino,
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

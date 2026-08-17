import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DailyGoalType { quiz, feed, play }

enum HabitatShopItem { plant, teddy, lamp, bookshelf }

enum HabitatShopCategory { all, nature, toys, lighting, furniture }

enum HabitatItemRarity { common, rare, epic }

enum HabitatPurchaseResult {
  purchased,
  alreadyOwned,
  locked,
  insufficientCoins,
  saveFailed,
}

enum HabitatPlacementResult { placed, removed, notOwned, saveFailed }

class DailyGoalsController extends ChangeNotifier {
  DailyGoalsController({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const int dailyCompletionReward = 25;

  static const String _dateKey = 'companion_daily_goals_date';
  static const String _quizKey = 'companion_daily_goal_quiz';
  static const String _feedKey = 'companion_daily_goal_feed';
  static const String _playKey = 'companion_daily_goal_play';
  static const String _streakKey = 'companion_daily_goal_streak';

  static const String _lastCompletedDateKey =
      'companion_daily_goal_last_completed_date';

  static const String _coinsKey = 'companion_coins';

  static const String _lastRewardedDateKey =
      'companion_daily_goal_last_rewarded_date';

  static const String _plantOwnedKey = 'companion_shop_plant_owned';

  static const String _teddyOwnedKey = 'companion_shop_teddy_owned';

  static const String _lampOwnedKey = 'companion_shop_lamp_owned';

  static const String _bookshelfOwnedKey = 'companion_shop_bookshelf_owned';

  static const String _plantPlacedKey = 'companion_shop_plant_placed';

  static const String _teddyPlacedKey = 'companion_shop_teddy_placed';

  static const String _lampPlacedKey = 'companion_shop_lamp_placed';

  static const String _bookshelfPlacedKey = 'companion_shop_bookshelf_placed';

  final SharedPreferencesAsync _preferences;

  bool _quizCompleted = false;
  bool _feedCompleted = false;
  bool _playCompleted = false;

  int _streak = 0;
  int _coins = 0;

  String? _lastCompletedDate;
  String? _lastRewardedDate;

  final Set<HabitatShopItem> _ownedItems = <HabitatShopItem>{};

  final Set<HabitatShopItem> _placedItems = <HabitatShopItem>{};

  final Map<HabitatShopItem, Offset> _itemPositions =
      <HabitatShopItem, Offset>{};

  bool _isInitialized = false;
  bool _isDisposed = false;

  bool get isInitialized => _isInitialized;

  bool get quizCompleted => _quizCompleted;

  bool get feedCompleted => _feedCompleted;

  bool get playCompleted => _playCompleted;

  int get streak => _streak;

  int get coins => _coins;

  int get completedCount {
    var count = 0;

    if (_quizCompleted) {
      count++;
    }

    if (_feedCompleted) {
      count++;
    }

    if (_playCompleted) {
      count++;
    }

    return count;
  }

  int get totalGoals => 3;

  double get progress {
    return completedCount / totalGoals;
  }

  bool get allCompleted {
    return completedCount == totalGoals;
  }

  bool get rewardEarnedToday {
    return _lastRewardedDate == _dateValue(DateTime.now());
  }

  int get ownedItemCount {
    return _ownedItems.length;
  }

  int get placedItemCount {
    return _placedItems.length;
  }

  bool isOwned(HabitatShopItem item) {
    return _ownedItems.contains(item);
  }

  bool isPlaced(HabitatShopItem item) {
    return _placedItems.contains(item);
  }

  bool canAfford(HabitatShopItem item) {
    return _coins >= priceFor(item);
  }

  bool isUnlocked(HabitatShopItem item) {
    if (isOwned(item)) {
      return true;
    }

    final requiredItem = requiredOwnedItemFor(item);

    if (requiredItem == null) {
      return true;
    }

    return isOwned(requiredItem);
  }

  bool canPurchase(HabitatShopItem item) {
    return !isOwned(item) && isUnlocked(item) && canAfford(item);
  }

  HabitatShopItem? requiredOwnedItemFor(HabitatShopItem item) {
    return switch (item) {
      HabitatShopItem.plant => null,
      HabitatShopItem.teddy => HabitatShopItem.plant,
      HabitatShopItem.lamp => HabitatShopItem.teddy,
      HabitatShopItem.bookshelf => HabitatShopItem.lamp,
    };
  }

  HabitatShopCategory categoryFor(HabitatShopItem item) {
    return switch (item) {
      HabitatShopItem.plant => HabitatShopCategory.nature,
      HabitatShopItem.teddy => HabitatShopCategory.toys,
      HabitatShopItem.lamp => HabitatShopCategory.lighting,
      HabitatShopItem.bookshelf => HabitatShopCategory.furniture,
    };
  }

  HabitatItemRarity rarityFor(HabitatShopItem item) {
    return switch (item) {
      HabitatShopItem.plant => HabitatItemRarity.common,
      HabitatShopItem.teddy => HabitatItemRarity.common,
      HabitatShopItem.lamp => HabitatItemRarity.rare,
      HabitatShopItem.bookshelf => HabitatItemRarity.epic,
    };
  }

  int priceFor(HabitatShopItem item) {
    return switch (item) {
      HabitatShopItem.plant => 20,
      HabitatShopItem.teddy => 35,
      HabitatShopItem.lamp => 50,
      HabitatShopItem.bookshelf => 75,
    };
  }

  Offset positionFor(HabitatShopItem item) {
    return _itemPositions[item] ?? defaultPositionFor(item);
  }

  Offset defaultPositionFor(HabitatShopItem item) {
    return switch (item) {
      HabitatShopItem.plant => const Offset(0.02, 1.0),
      HabitatShopItem.teddy => const Offset(0.98, 1.0),
      HabitatShopItem.lamp => const Offset(0.05, 0.10),
      HabitatShopItem.bookshelf => const Offset(0.95, 0.12),
    };
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    final now = DateTime.now();
    final today = _dateValue(now);

    try {
      final storedDate = await _preferences.getString(_dateKey);

      _streak = await _preferences.getInt(_streakKey) ?? 0;

      if (_streak < 0) {
        _streak = 0;
      }

      _coins = await _preferences.getInt(_coinsKey) ?? 0;

      if (_coins < 0) {
        _coins = 0;
      }

      _lastCompletedDate = await _preferences.getString(_lastCompletedDateKey);

      _lastRewardedDate = await _preferences.getString(_lastRewardedDateKey);

      await _loadOwnedItems();

      await _loadPlacedItems();

      await _loadItemPositions();

      if (storedDate == today) {
        _quizCompleted = await _preferences.getBool(_quizKey) ?? false;

        _feedCompleted = await _preferences.getBool(_feedKey) ?? false;

        _playCompleted = await _preferences.getBool(_playKey) ?? false;

        if (allCompleted) {
          _updateStreakIfNeeded(now: now);

          _grantDailyRewardIfNeeded(now: now);
        }
      } else {
        _quizCompleted = false;
        _feedCompleted = false;
        _playCompleted = false;
      }

      await _persist(date: today);
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to load daily goals: '
        '$error\n$stackTrace',
      );
    }

    _isInitialized = true;

    _safeNotifyListeners();
  }

  Future<void> refreshForToday() async {
    if (!_isInitialized) {
      await initialize();
      return;
    }

    await _ensureCurrentDay();
  }

  Future<void> complete(DailyGoalType goal) async {
    if (!_isInitialized) {
      await initialize();
    }

    await _ensureCurrentDay();

    var changed = false;

    switch (goal) {
      case DailyGoalType.quiz:
        if (!_quizCompleted) {
          _quizCompleted = true;
          changed = true;
        }
        break;

      case DailyGoalType.feed:
        if (!_feedCompleted) {
          _feedCompleted = true;
          changed = true;
        }
        break;

      case DailyGoalType.play:
        if (!_playCompleted) {
          _playCompleted = true;
          changed = true;
        }
        break;
    }

    if (!changed) {
      return;
    }

    final now = DateTime.now();
    final today = _dateValue(now);

    if (allCompleted) {
      _updateStreakIfNeeded(now: now);

      _grantDailyRewardIfNeeded(now: now);
    }

    _safeNotifyListeners();

    try {
      await _persist(date: today);
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to save daily goals: '
        '$error\n$stackTrace',
      );
    }
  }

  Future<HabitatPurchaseResult> purchase(HabitatShopItem item) async {
    if (!_isInitialized) {
      await initialize();
    }

    await _ensureCurrentDay();

    if (isOwned(item)) {
      return HabitatPurchaseResult.alreadyOwned;
    }

    if (!isUnlocked(item)) {
      return HabitatPurchaseResult.locked;
    }

    final price = priceFor(item);

    if (_coins < price) {
      return HabitatPurchaseResult.insufficientCoins;
    }

    _coins -= price;

    _ownedItems.add(item);

    _placedItems.add(item);

    _safeNotifyListeners();

    try {
      await _persist(date: _dateValue(DateTime.now()));

      return HabitatPurchaseResult.purchased;
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to purchase habitat item: '
        '$error\n$stackTrace',
      );

      _coins += price;

      _ownedItems.remove(item);

      _placedItems.remove(item);

      _safeNotifyListeners();

      return HabitatPurchaseResult.saveFailed;
    }
  }

  Future<HabitatPlacementResult> togglePlacement(HabitatShopItem item) async {
    if (!_isInitialized) {
      await initialize();
    }

    await _ensureCurrentDay();

    if (!isOwned(item)) {
      return HabitatPlacementResult.notOwned;
    }

    final wasPlaced = isPlaced(item);

    if (wasPlaced) {
      _placedItems.remove(item);
    } else {
      _placedItems.add(item);
    }

    _safeNotifyListeners();

    try {
      await _persist(date: _dateValue(DateTime.now()));

      return wasPlaced
          ? HabitatPlacementResult.removed
          : HabitatPlacementResult.placed;
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to update habitat item placement: '
        '$error\n$stackTrace',
      );

      if (wasPlaced) {
        _placedItems.add(item);
      } else {
        _placedItems.remove(item);
      }

      _safeNotifyListeners();

      return HabitatPlacementResult.saveFailed;
    }
  }

  Future<bool> updateItemPosition(HabitatShopItem item, Offset position) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!isOwned(item)) {
      return false;
    }

    final previousPosition = positionFor(item);

    final normalizedPosition = _normalizePosition(position);

    _itemPositions[item] = normalizedPosition;

    _safeNotifyListeners();

    try {
      await Future.wait<void>([
        _preferences.setDouble(_positionXKey(item), normalizedPosition.dx),
        _preferences.setDouble(_positionYKey(item), normalizedPosition.dy),
      ]);

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to save habitat item position: '
        '$error\n$stackTrace',
      );

      _itemPositions[item] = previousPosition;

      _safeNotifyListeners();

      return false;
    }
  }

  Future<void> resetItemPositions() async {
    if (!_isInitialized) {
      await initialize();
    }

    final previousPositions = Map<HabitatShopItem, Offset>.from(_itemPositions);

    _itemPositions.clear();

    _safeNotifyListeners();

    try {
      final operations = <Future<void>>[];

      for (final item in HabitatShopItem.values) {
        operations.add(_preferences.remove(_positionXKey(item)));

        operations.add(_preferences.remove(_positionYKey(item)));
      }

      await Future.wait<void>(operations);
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to reset habitat item positions: '
        '$error\n$stackTrace',
      );

      _itemPositions
        ..clear()
        ..addAll(previousPositions);

      _safeNotifyListeners();
    }
  }

  Future<void> _loadOwnedItems() async {
    _ownedItems.clear();

    final plantOwned = await _preferences.getBool(_plantOwnedKey) ?? false;

    final teddyOwned = await _preferences.getBool(_teddyOwnedKey) ?? false;

    final lampOwned = await _preferences.getBool(_lampOwnedKey) ?? false;

    final bookshelfOwned =
        await _preferences.getBool(_bookshelfOwnedKey) ?? false;

    if (plantOwned) {
      _ownedItems.add(HabitatShopItem.plant);
    }

    if (teddyOwned) {
      _ownedItems.add(HabitatShopItem.teddy);
    }

    if (lampOwned) {
      _ownedItems.add(HabitatShopItem.lamp);
    }

    if (bookshelfOwned) {
      _ownedItems.add(HabitatShopItem.bookshelf);
    }
  }

  Future<void> _loadPlacedItems() async {
    _placedItems.clear();

    final plantPlaced = await _preferences.getBool(_plantPlacedKey);

    final teddyPlaced = await _preferences.getBool(_teddyPlacedKey);

    final lampPlaced = await _preferences.getBool(_lampPlacedKey);

    final bookshelfPlaced = await _preferences.getBool(_bookshelfPlacedKey);

    if (isOwned(HabitatShopItem.plant) && (plantPlaced ?? true)) {
      _placedItems.add(HabitatShopItem.plant);
    }

    if (isOwned(HabitatShopItem.teddy) && (teddyPlaced ?? true)) {
      _placedItems.add(HabitatShopItem.teddy);
    }

    if (isOwned(HabitatShopItem.lamp) && (lampPlaced ?? true)) {
      _placedItems.add(HabitatShopItem.lamp);
    }

    if (isOwned(HabitatShopItem.bookshelf) && (bookshelfPlaced ?? true)) {
      _placedItems.add(HabitatShopItem.bookshelf);
    }
  }

  Future<void> _loadItemPositions() async {
    _itemPositions.clear();

    for (final item in HabitatShopItem.values) {
      final x = await _preferences.getDouble(_positionXKey(item));

      final y = await _preferences.getDouble(_positionYKey(item));

      if (x == null || y == null) {
        continue;
      }

      _itemPositions[item] = _normalizePosition(Offset(x, y));
    }
  }

  Future<void> _ensureCurrentDay() async {
    final now = DateTime.now();
    final today = _dateValue(now);

    String? storedDate;

    try {
      storedDate = await _preferences.getString(_dateKey);
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to check daily goal date: '
        '$error\n$stackTrace',
      );

      return;
    }

    if (storedDate == today) {
      return;
    }

    _quizCompleted = false;
    _feedCompleted = false;
    _playCompleted = false;

    _safeNotifyListeners();

    try {
      await _persist(date: today);
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to reset daily goals: '
        '$error\n$stackTrace',
      );
    }
  }

  void _updateStreakIfNeeded({required DateTime now}) {
    final today = _dateValue(now);

    if (_lastCompletedDate == today) {
      return;
    }

    final currentDay = DateTime(now.year, now.month, now.day);

    final yesterday = _dateValue(currentDay.subtract(const Duration(days: 1)));

    if (_lastCompletedDate == yesterday) {
      _streak++;
    } else {
      _streak = 1;
    }

    _lastCompletedDate = today;
  }

  void _grantDailyRewardIfNeeded({required DateTime now}) {
    final today = _dateValue(now);

    if (_lastRewardedDate == today) {
      return;
    }

    _coins += dailyCompletionReward;

    _lastRewardedDate = today;
  }

  Future<void> _persist({required String date}) async {
    final operations = <Future<void>>[
      _preferences.setString(_dateKey, date),
      _preferences.setBool(_quizKey, _quizCompleted),
      _preferences.setBool(_feedKey, _feedCompleted),
      _preferences.setBool(_playKey, _playCompleted),
      _preferences.setInt(_streakKey, _streak),
      _preferences.setInt(_coinsKey, _coins),
      _preferences.setBool(_plantOwnedKey, isOwned(HabitatShopItem.plant)),
      _preferences.setBool(_teddyOwnedKey, isOwned(HabitatShopItem.teddy)),
      _preferences.setBool(_lampOwnedKey, isOwned(HabitatShopItem.lamp)),
      _preferences.setBool(
        _bookshelfOwnedKey,
        isOwned(HabitatShopItem.bookshelf),
      ),
      _preferences.setBool(_plantPlacedKey, isPlaced(HabitatShopItem.plant)),
      _preferences.setBool(_teddyPlacedKey, isPlaced(HabitatShopItem.teddy)),
      _preferences.setBool(_lampPlacedKey, isPlaced(HabitatShopItem.lamp)),
      _preferences.setBool(
        _bookshelfPlacedKey,
        isPlaced(HabitatShopItem.bookshelf),
      ),
    ];

    final lastCompletedDate = _lastCompletedDate;

    if (lastCompletedDate == null) {
      operations.add(_preferences.remove(_lastCompletedDateKey));
    } else {
      operations.add(
        _preferences.setString(_lastCompletedDateKey, lastCompletedDate),
      );
    }

    final lastRewardedDate = _lastRewardedDate;

    if (lastRewardedDate == null) {
      operations.add(_preferences.remove(_lastRewardedDateKey));
    } else {
      operations.add(
        _preferences.setString(_lastRewardedDateKey, lastRewardedDate),
      );
    }

    await Future.wait<void>(operations);
  }

  Offset _normalizePosition(Offset position) {
    return Offset(_clampUnit(position.dx), _clampUnit(position.dy));
  }

  double _clampUnit(double value) {
    return value.clamp(0.0, 1.0).toDouble();
  }

  String _positionXKey(HabitatShopItem item) {
    return 'companion_shop_${item.name}_position_x';
  }

  String _positionYKey(HabitatShopItem item) {
    return 'companion_shop_${item.name}_position_y';
  }

  String _dateValue(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');

    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    super.dispose();
  }
}

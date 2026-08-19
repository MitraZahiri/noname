import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DailyGoalType { quiz, feed, play }

enum HabitatShopItem {
  plant,
  cactus,
  teddy,
  ball,
  lamp,
  lantern,
  bookshelf,
  chair,
}

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

  static const Map<int, int> collectionMilestoneRewards = {
    2: 10,
    4: 20,
    6: 35,
    8: 75,
  };

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

  static const String _collectionRewardTierKey =
      'companion_collection_reward_tier';

  final SharedPreferencesAsync _preferences;

  bool _quizCompleted = false;
  bool _feedCompleted = false;
  bool _playCompleted = false;

  int _streak = 0;
  int _coins = 0;

  String? _lastCompletedDate;
  String? _lastRewardedDate;

  int _collectionRewardTier = 0;

  int _lastCollectionRewardAmount = 0;
  int _lastCollectionRewardMilestone = 0;

  final Set<HabitatShopItem> _ownedItems = <HabitatShopItem>{};

  final Set<HabitatShopItem> _placedItems = <HabitatShopItem>{};

  final Map<HabitatShopItem, Offset> _itemPositions =
      <HabitatShopItem, Offset>{};

  final Map<HabitatShopItem, int> _itemLayers = <HabitatShopItem, int>{};
  final Map<HabitatShopItem, double> _itemScales = <HabitatShopItem, double>{};

  final Map<HabitatShopItem, double> _itemRotations =
      <HabitatShopItem, double>{};

  bool _isInitialized = false;
  bool _isDisposed = false;

  bool get isInitialized => _isInitialized;

  bool get quizCompleted => _quizCompleted;

  bool get feedCompleted => _feedCompleted;

  bool get playCompleted => _playCompleted;

  int get streak => _streak;

  int get coins => _coins;

  int get collectionRewardTier => _collectionRewardTier;

  int get lastCollectionRewardAmount => _lastCollectionRewardAmount;

  int get lastCollectionRewardMilestone => _lastCollectionRewardMilestone;

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

  int get totalCollectionItems {
    return HabitatShopItem.values.length;
  }

  double get collectionProgress {
    if (totalCollectionItems == 0) {
      return 0;
    }

    return ownedItemCount / totalCollectionItems;
  }

  bool get collectionCompleted {
    return ownedItemCount >= totalCollectionItems;
  }

  int? get nextCollectionMilestone {
    for (final milestone in collectionMilestoneRewards.keys) {
      if (_collectionRewardTier < milestone) {
        return milestone;
      }
    }

    return null;
  }

  int get itemsUntilNextCollectionReward {
    final milestone = nextCollectionMilestone;

    if (milestone == null) {
      return 0;
    }

    final remaining = milestone - ownedItemCount;

    return remaining < 0 ? 0 : remaining;
  }

  int get nextCollectionRewardAmount {
    final milestone = nextCollectionMilestone;

    if (milestone == null) {
      return 0;
    }

    return collectionMilestoneRewards[milestone] ?? 0;
  }

  bool isCollectionMilestoneClaimed(int milestone) {
    return _collectionRewardTier >= milestone;
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

      HabitatShopItem.cactus => HabitatShopItem.plant,

      HabitatShopItem.teddy => HabitatShopItem.plant,

      HabitatShopItem.ball => HabitatShopItem.teddy,

      HabitatShopItem.lamp => HabitatShopItem.teddy,

      HabitatShopItem.lantern => HabitatShopItem.lamp,

      HabitatShopItem.bookshelf => HabitatShopItem.lamp,

      HabitatShopItem.chair => HabitatShopItem.bookshelf,
    };
  }

  HabitatShopCategory categoryFor(HabitatShopItem item) {
    return switch (item) {
      HabitatShopItem.plant ||
      HabitatShopItem.cactus => HabitatShopCategory.nature,

      HabitatShopItem.teddy || HabitatShopItem.ball => HabitatShopCategory.toys,

      HabitatShopItem.lamp ||
      HabitatShopItem.lantern => HabitatShopCategory.lighting,

      HabitatShopItem.bookshelf ||
      HabitatShopItem.chair => HabitatShopCategory.furniture,
    };
  }

  HabitatItemRarity rarityFor(HabitatShopItem item) {
    return switch (item) {
      HabitatShopItem.plant ||
      HabitatShopItem.cactus ||
      HabitatShopItem.teddy ||
      HabitatShopItem.ball => HabitatItemRarity.common,

      HabitatShopItem.lamp ||
      HabitatShopItem.lantern ||
      HabitatShopItem.chair => HabitatItemRarity.rare,

      HabitatShopItem.bookshelf => HabitatItemRarity.epic,
    };
  }

  int priceFor(HabitatShopItem item) {
    return switch (item) {
      HabitatShopItem.plant => 20,
      HabitatShopItem.cactus => 28,
      HabitatShopItem.teddy => 35,
      HabitatShopItem.ball => 42,
      HabitatShopItem.lamp => 50,
      HabitatShopItem.lantern => 60,
      HabitatShopItem.bookshelf => 75,
      HabitatShopItem.chair => 90,
    };
  }

  Offset positionFor(HabitatShopItem item) {
    return _itemPositions[item] ?? defaultPositionFor(item);
  }

  Offset defaultPositionFor(HabitatShopItem item) {
    return switch (item) {
      HabitatShopItem.plant => const Offset(0.02, 1.00),

      HabitatShopItem.cactus => const Offset(0.20, 0.88),

      HabitatShopItem.teddy => const Offset(0.98, 1.00),

      HabitatShopItem.ball => const Offset(0.80, 0.88),

      HabitatShopItem.lamp => const Offset(0.05, 0.10),

      HabitatShopItem.lantern => const Offset(0.28, 0.08),

      HabitatShopItem.bookshelf => const Offset(0.95, 0.12),

      HabitatShopItem.chair => const Offset(0.78, 0.52),
    };
  }

  int layerFor(HabitatShopItem item) {
    return _itemLayers[item] ?? item.index;
  }

  double scaleFor(HabitatShopItem item) {
    return _itemScales[item] ?? 1.0;
  }

  double rotationFor(HabitatShopItem item) {
    return _itemRotations[item] ?? 0.0;
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

      _collectionRewardTier =
          await _preferences.getInt(_collectionRewardTierKey) ?? 0;

      if (_collectionRewardTier < 0) {
        _collectionRewardTier = 0;
      }

      _lastCompletedDate = await _preferences.getString(_lastCompletedDateKey);

      _lastRewardedDate = await _preferences.getString(_lastRewardedDateKey);

      await _loadOwnedItems();
      await _loadPlacedItems();
      await _loadItemPositions();
      await _loadItemLayers();
      await _loadItemTransforms();

      _grantCollectionMilestoneRewardsIfNeeded(exposeAsLastReward: false);

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

    _lastCollectionRewardAmount = 0;
    _lastCollectionRewardMilestone = 0;

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

    final previousCoins = _coins;
    final previousRewardTier = _collectionRewardTier;

    final previousLayer = _itemLayers[item];

    final newLayer = _nextFrontLayer();

    _coins -= price;

    _ownedItems.add(item);
    _placedItems.add(item);
    _itemLayers[item] = newLayer;

    _grantCollectionMilestoneRewardsIfNeeded();

    _safeNotifyListeners();

    try {
      await _persist(date: _dateValue(DateTime.now()));

      return HabitatPurchaseResult.purchased;
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to purchase habitat item: '
        '$error\n$stackTrace',
      );

      _coins = previousCoins;

      _collectionRewardTier = previousRewardTier;

      _lastCollectionRewardAmount = 0;
      _lastCollectionRewardMilestone = 0;

      _ownedItems.remove(item);
      _placedItems.remove(item);

      if (previousLayer == null) {
        _itemLayers.remove(item);
      } else {
        _itemLayers[item] = previousLayer;
      }

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

  Future<bool> bringItemToFront(HabitatShopItem item) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!isOwned(item)) {
      return false;
    }

    final currentLayer = layerFor(item);

    final highestLayer = _highestOwnedLayer();

    if (currentLayer >= highestLayer) {
      return true;
    }

    final previousStoredLayer = _itemLayers[item];

    final newLayer = highestLayer + 1;

    _itemLayers[item] = newLayer;

    _safeNotifyListeners();

    try {
      await _preferences.setInt(_layerKey(item), newLayer);

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to bring habitat item to front: '
        '$error\n$stackTrace',
      );

      if (previousStoredLayer == null) {
        _itemLayers.remove(item);
      } else {
        _itemLayers[item] = previousStoredLayer;
      }

      _safeNotifyListeners();

      return false;
    }
  }

  Future<bool> sendItemToBack(HabitatShopItem item) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!isOwned(item)) {
      return false;
    }

    final currentLayer = layerFor(item);

    final lowestLayer = _lowestOwnedLayer();

    if (currentLayer <= lowestLayer) {
      return true;
    }

    final previousStoredLayer = _itemLayers[item];

    final newLayer = lowestLayer - 1;

    _itemLayers[item] = newLayer;

    _safeNotifyListeners();

    try {
      await _preferences.setInt(_layerKey(item), newLayer);

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to send habitat item to back: '
        '$error\n$stackTrace',
      );

      if (previousStoredLayer == null) {
        _itemLayers.remove(item);
      } else {
        _itemLayers[item] = previousStoredLayer;
      }

      _safeNotifyListeners();

      return false;
    }
  }

  Future<bool> updateItemScale(HabitatShopItem item, double scale) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!isOwned(item)) {
      return false;
    }

    final previousScale = scaleFor(item);

    final normalizedScale = scale.clamp(0.60, 1.60).toDouble();

    _itemScales[item] = normalizedScale;

    _safeNotifyListeners();

    try {
      await _preferences.setDouble(_scaleKey(item), normalizedScale);

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to save habitat item scale: '
        '$error\n$stackTrace',
      );

      _itemScales[item] = previousScale;

      _safeNotifyListeners();

      return false;
    }
  }

  Future<bool> updateItemRotation(HabitatShopItem item, double rotation) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!isOwned(item)) {
      return false;
    }

    final previousRotation = rotationFor(item);

    var normalizedRotation = rotation % 1.0;

    if (normalizedRotation < 0) {
      normalizedRotation += 1.0;
    }

    _itemRotations[item] = normalizedRotation;

    _safeNotifyListeners();

    try {
      await _preferences.setDouble(_rotationKey(item), normalizedRotation);

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to save habitat item rotation: '
        '$error\n$stackTrace',
      );

      _itemRotations[item] = previousRotation;

      _safeNotifyListeners();

      return false;
    }
  }

  Future<bool> resetItemCustomization(HabitatShopItem item) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!isOwned(item)) {
      return false;
    }

    final previousPosition = positionFor(item);
    final previousScale = scaleFor(item);
    final previousRotation = rotationFor(item);
    final previousLayer = layerFor(item);

    final defaultPosition = defaultPositionFor(item);

    _itemPositions[item] = defaultPosition;
    _itemScales[item] = 1.0;
    _itemRotations[item] = 0.0;
    _itemLayers[item] = item.index;

    _safeNotifyListeners();

    try {
      await Future.wait<void>([
        _preferences.setDouble(_positionXKey(item), defaultPosition.dx),
        _preferences.setDouble(_positionYKey(item), defaultPosition.dy),
        _preferences.setDouble(_scaleKey(item), 1.0),
        _preferences.setDouble(_rotationKey(item), 0.0),
        _preferences.setInt(_layerKey(item), item.index),
      ]);

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to reset habitat item customization: '
        '$error\n$stackTrace',
      );

      _itemPositions[item] = previousPosition;
      _itemScales[item] = previousScale;
      _itemRotations[item] = previousRotation;
      _itemLayers[item] = previousLayer;

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

    for (final item in HabitatShopItem.values) {
      final owned = await _preferences.getBool(_ownedKey(item)) ?? false;

      if (owned) {
        _ownedItems.add(item);
      }
    }
  }

  Future<void> _loadPlacedItems() async {
    _placedItems.clear();

    for (final item in HabitatShopItem.values) {
      if (!isOwned(item)) {
        continue;
      }

      final placed = await _preferences.getBool(_placedKey(item));

      if (placed ?? true) {
        _placedItems.add(item);
      }
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

  Future<void> _loadItemLayers() async {
    _itemLayers.clear();

    for (final item in HabitatShopItem.values) {
      final layer = await _preferences.getInt(_layerKey(item));

      if (layer == null) {
        continue;
      }

      _itemLayers[item] = layer;
    }
  }

  Future<void> _loadItemTransforms() async {
    _itemScales.clear();
    _itemRotations.clear();

    for (final item in HabitatShopItem.values) {
      final scale = await _preferences.getDouble(_scaleKey(item));

      final rotation = await _preferences.getDouble(_rotationKey(item));

      if (scale != null) {
        _itemScales[item] = scale.clamp(0.60, 1.60).toDouble();
      }

      if (rotation != null) {
        var normalizedRotation = rotation % 1.0;

        if (normalizedRotation < 0) {
          normalizedRotation += 1.0;
        }

        _itemRotations[item] = normalizedRotation;
      }
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

  void _grantCollectionMilestoneRewardsIfNeeded({
    bool exposeAsLastReward = true,
  }) {
    var rewardAmount = 0;

    var highestGrantedMilestone = _collectionRewardTier;

    for (final entry in collectionMilestoneRewards.entries) {
      final milestone = entry.key;

      if (ownedItemCount < milestone) {
        continue;
      }

      if (_collectionRewardTier >= milestone) {
        continue;
      }

      rewardAmount += entry.value;

      highestGrantedMilestone = milestone;
    }

    if (rewardAmount <= 0) {
      if (exposeAsLastReward) {
        _lastCollectionRewardAmount = 0;
        _lastCollectionRewardMilestone = 0;
      }

      return;
    }

    _coins += rewardAmount;

    _collectionRewardTier = highestGrantedMilestone;

    if (exposeAsLastReward) {
      _lastCollectionRewardAmount = rewardAmount;

      _lastCollectionRewardMilestone = highestGrantedMilestone;
    }
  }

  int _nextFrontLayer() {
    if (_ownedItems.isEmpty) {
      return 0;
    }

    return _highestOwnedLayer() + 1;
  }

  int _highestOwnedLayer() {
    if (_ownedItems.isEmpty) {
      return 0;
    }

    var highest = layerFor(_ownedItems.first);

    for (final item in _ownedItems) {
      final layer = layerFor(item);

      if (layer > highest) {
        highest = layer;
      }
    }

    return highest;
  }

  int _lowestOwnedLayer() {
    if (_ownedItems.isEmpty) {
      return 0;
    }

    var lowest = layerFor(_ownedItems.first);

    for (final item in _ownedItems) {
      final layer = layerFor(item);

      if (layer < lowest) {
        lowest = layer;
      }
    }

    return lowest;
  }

  Future<void> _persist({required String date}) async {
    final operations = <Future<void>>[
      _preferences.setString(_dateKey, date),
      _preferences.setBool(_quizKey, _quizCompleted),
      _preferences.setBool(_feedKey, _feedCompleted),
      _preferences.setBool(_playKey, _playCompleted),
      _preferences.setInt(_streakKey, _streak),
      _preferences.setInt(_coinsKey, _coins),
      _preferences.setInt(_collectionRewardTierKey, _collectionRewardTier),
    ];

    for (final item in HabitatShopItem.values) {
      operations.add(_preferences.setBool(_ownedKey(item), isOwned(item)));
      operations.add(_preferences.setBool(_placedKey(item), isPlaced(item)));
      operations.add(_preferences.setInt(_layerKey(item), layerFor(item)));
      operations.add(_preferences.setDouble(_scaleKey(item), scaleFor(item)));
      operations.add(
        _preferences.setDouble(_rotationKey(item), rotationFor(item)),
      );
    }

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

  String _ownedKey(HabitatShopItem item) {
    return 'companion_shop_${item.name}_owned';
  }

  String _placedKey(HabitatShopItem item) {
    return 'companion_shop_${item.name}_placed';
  }

  String _positionXKey(HabitatShopItem item) {
    return 'companion_shop_${item.name}_position_x';
  }

  String _positionYKey(HabitatShopItem item) {
    return 'companion_shop_${item.name}_position_y';
  }

  String _layerKey(HabitatShopItem item) {
    return 'companion_shop_${item.name}_layer';
  }

  String _scaleKey(HabitatShopItem item) {
    return 'companion_shop_${item.name}_scale';
  }

  String _rotationKey(HabitatShopItem item) {
    return 'companion_shop_${item.name}_rotation';
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

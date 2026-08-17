import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DailyGoalType { quiz, feed, play }

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

  final SharedPreferencesAsync _preferences;

  bool _quizCompleted = false;
  bool _feedCompleted = false;
  bool _playCompleted = false;

  int _streak = 0;
  int _coins = 0;

  String? _lastCompletedDate;
  String? _lastRewardedDate;

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

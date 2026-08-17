import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DailyGoalType { quiz, feed, play }

class DailyGoalsController extends ChangeNotifier {
  DailyGoalsController({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _dateKey = 'companion_daily_goals_date';

  static const String _quizKey = 'companion_daily_goal_quiz';

  static const String _feedKey = 'companion_daily_goal_feed';

  static const String _playKey = 'companion_daily_goal_play';

  final SharedPreferencesAsync _preferences;

  bool _quizCompleted = false;
  bool _feedCompleted = false;
  bool _playCompleted = false;

  bool _isInitialized = false;
  bool _isDisposed = false;

  bool get isInitialized => _isInitialized;

  bool get quizCompleted => _quizCompleted;

  bool get feedCompleted => _feedCompleted;

  bool get playCompleted => _playCompleted;

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

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    final now = DateTime.now();
    final today = _dateValue(now);

    try {
      final storedDate = await _preferences.getString(_dateKey);

      if (storedDate != today) {
        _quizCompleted = false;
        _feedCompleted = false;
        _playCompleted = false;

        await _persist(date: today);
      } else {
        _quizCompleted = await _preferences.getBool(_quizKey) ?? false;

        _feedCompleted = await _preferences.getBool(_feedKey) ?? false;

        _playCompleted = await _preferences.getBool(_playKey) ?? false;
      }
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
    await _ensureCurrentDay();
  }

  Future<void> complete(DailyGoalType goal) async {
    await _ensureCurrentDay();

    var changed = false;

    switch (goal) {
      case DailyGoalType.quiz:
        if (!_quizCompleted) {
          _quizCompleted = true;
          changed = true;
        }

      case DailyGoalType.feed:
        if (!_feedCompleted) {
          _feedCompleted = true;
          changed = true;
        }

      case DailyGoalType.play:
        if (!_playCompleted) {
          _playCompleted = true;
          changed = true;
        }
    }

    if (!changed) {
      return;
    }

    _safeNotifyListeners();

    try {
      await _persist(date: _dateValue(DateTime.now()));
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to save daily goals: '
        '$error\n$stackTrace',
      );
    }
  }

  Future<void> _ensureCurrentDay() async {
    final today = _dateValue(DateTime.now());

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

  Future<void> _persist({required String date}) async {
    await Future.wait<void>([
      _preferences.setString(_dateKey, date),
      _preferences.setBool(_quizKey, _quizCompleted),
      _preferences.setBool(_feedKey, _feedCompleted),
      _preferences.setBool(_playKey, _playCompleted),
    ]);
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

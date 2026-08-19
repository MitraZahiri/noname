import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LearningGameType { quickQuiz, trueFalse, memoryMatch }

class LearningGameProgressController extends ChangeNotifier {
  LearningGameProgressController({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  final Map<LearningGameType, int> _bestScores = <LearningGameType, int>{};

  bool _isInitialized = false;
  bool _isDisposed = false;

  bool get isInitialized => _isInitialized;

  int bestScoreFor(LearningGameType game) {
    return _bestScores[game] ?? 0;
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      for (final game in LearningGameType.values) {
        final score = await _preferences.getInt(_bestScoreKey(game)) ?? 0;

        _bestScores[game] = score < 0 ? 0 : score;
      }
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to load learning game progress: '
        '$error\n$stackTrace',
      );
    }

    _isInitialized = true;
    _safeNotifyListeners();
  }

  Future<bool> submitScore(LearningGameType game, int score) async {
    if (!_isInitialized) {
      await initialize();
    }

    final normalizedScore = score < 0 ? 0 : score;
    final previousBest = bestScoreFor(game);

    if (normalizedScore <= previousBest) {
      return false;
    }

    _bestScores[game] = normalizedScore;
    _safeNotifyListeners();

    try {
      await _preferences.setInt(_bestScoreKey(game), normalizedScore);

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to save learning game score: '
        '$error\n$stackTrace',
      );

      _bestScores[game] = previousBest;
      _safeNotifyListeners();

      return false;
    }
  }

  String _bestScoreKey(LearningGameType game) {
    return 'learning_game_${game.name}_best_score';
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

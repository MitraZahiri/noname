import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/quiz_progress.dart';
import '../../domain/repositories/quiz_progress_repository.dart';

class SharedPreferencesQuizProgressRepository
    implements QuizProgressRepository {
  SharedPreferencesQuizProgressRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const String _totalAnsweredKey = 'quiz_progress_total_answered';

  static const String _correctAnswersKey = 'quiz_progress_correct_answers';

  static const String _currentStreakKey = 'quiz_progress_current_streak';

  static const String _bestStreakKey = 'quiz_progress_best_streak';

  static const String _scoreKey = 'quiz_progress_score';

  @override
  Future<QuizProgress> load() async {
    final storedTotal = await _preferences.getInt(_totalAnsweredKey) ?? 0;

    final storedCorrect = await _preferences.getInt(_correctAnswersKey) ?? 0;

    final storedCurrentStreak =
        await _preferences.getInt(_currentStreakKey) ?? 0;

    final storedBestStreak = await _preferences.getInt(_bestStreakKey) ?? 0;

    final storedScore = await _preferences.getInt(_scoreKey) ?? 0;

    final totalAnswered = storedTotal < 0 ? 0 : storedTotal;

    final correctAnswers = storedCorrect.clamp(0, totalAnswered).toInt();

    final currentStreak = storedCurrentStreak.clamp(0, correctAnswers).toInt();

    final bestStreak =
        storedBestStreak < currentStreak ? currentStreak : storedBestStreak;

    final score = storedScore < 0 ? 0 : storedScore;

    return QuizProgress(
      totalAnswered: totalAnswered,
      correctAnswers: correctAnswers,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      score: score,
    );
  }

  @override
  Future<void> save(QuizProgress progress) async {
    await Future.wait<void>([
      _preferences.setInt(_totalAnsweredKey, progress.totalAnswered),
      _preferences.setInt(_correctAnswersKey, progress.correctAnswers),
      _preferences.setInt(_currentStreakKey, progress.currentStreak),
      _preferences.setInt(_bestStreakKey, progress.bestStreak),
      _preferences.setInt(_scoreKey, progress.score),
    ]);
  }

  @override
  Future<void> clear() async {
    await Future.wait<void>([
      _preferences.remove(_totalAnsweredKey),
      _preferences.remove(_correctAnswersKey),
      _preferences.remove(_currentStreakKey),
      _preferences.remove(_bestStreakKey),
      _preferences.remove(_scoreKey),
    ]);
  }
}

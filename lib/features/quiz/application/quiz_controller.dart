import 'package:flutter/foundation.dart';

import '../domain/entities/quiz_category.dart';
import '../domain/entities/quiz_difficulty.dart';
import '../domain/entities/quiz_progress.dart';
import '../domain/entities/quiz_question.dart';
import '../domain/repositories/quiz_progress_repository.dart';
import '../domain/repositories/quiz_repository.dart';
import '../domain/entities/quiz_achievement.dart';

class QuizController extends ChangeNotifier {
  QuizController({
    required QuizRepository repository,
    required QuizProgressRepository progressRepository,
  }) : _repository = repository,
       _progressRepository = progressRepository;

  final QuizRepository _repository;

  final QuizProgressRepository _progressRepository;

  QuizQuestion? _activeQuestion;

  QuizCategory? _preferredCategory;

  QuizDifficulty _difficulty = QuizDifficulty.easy;

  QuizProgress _progress = const QuizProgress.empty();

  QuizAchievementType? _latestUnlockedAchievement;

  String? _answeredQuestionId;

  bool _isInitialized = false;

  QuizQuestion? get activeQuestion => _activeQuestion;

  QuizCategory? get preferredCategory => _preferredCategory;

  QuizDifficulty get difficulty => _difficulty;

  QuizProgress get progress => _progress;

  QuizAchievementType? get latestUnlockedAchievement =>
      _latestUnlockedAchievement;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _progress = await _progressRepository.load();

    _isInitialized = true;

    notifyListeners();
  }

  QuizQuestion prepareNextQuestion({required String localeCode}) {
    final question = _repository.getNextQuestion(
      localeCode: localeCode,
      category: _preferredCategory,
      difficulty: _difficulty,
    );

    _activeQuestion = question;
    _answeredQuestionId = null;

    notifyListeners();

    return question;
  }

  void selectCategory(QuizCategory? category) {
    if (_preferredCategory == category) {
      return;
    }

    _preferredCategory = category;
    notifyListeners();
  }

  void selectDifficulty(QuizDifficulty difficulty) {
    if (_difficulty == difficulty) {
      return;
    }

    _difficulty = difficulty;
    notifyListeners();
  }

  Future<void> recordAnswer({required int selectedIndex}) async {
    final question = _activeQuestion;

    if (question == null) {
      return;
    }

    if (_answeredQuestionId == question.id) {
      return;
    }

    if (selectedIndex < 0 || selectedIndex >= question.options.length) {
      return;
    }

    final isCorrect = question.isCorrect(selectedIndex);

    _answeredQuestionId = question.id;

    _repository.recordAnswer(
      questionId: question.id,
      selectedIndex: selectedIndex,
      isCorrect: isCorrect,
    );

    final previousProgress = _progress;

    _progress = _progress.recordAnswer(isCorrect: isCorrect);

    _latestUnlockedAchievement = _findNewAchievement(
      previousProgress: previousProgress,
      currentProgress: _progress,
    );

    notifyListeners();

    try {
      await _progressRepository.save(_progress);
    } catch (error, stackTrace) {
      debugPrint(
        'Quiz progress could not be saved: '
        '$error\n$stackTrace',
      );
    }
  }

  QuizAchievementType? _findNewAchievement({
    required QuizProgress previousProgress,
    required QuizProgress currentProgress,
  }) {
    final previousUnlocked =
        QuizAchievement.fromProgress(previousProgress)
            .where((achievement) => achievement.isUnlocked)
            .map((achievement) => achievement.type)
            .toSet();

    final currentAchievements = QuizAchievement.fromProgress(currentProgress);

    for (final achievement in currentAchievements) {
      if (achievement.isUnlocked &&
          !previousUnlocked.contains(achievement.type)) {
        return achievement.type;
      }
    }

    return null;
  }

  void clearLatestAchievement() {
    if (_latestUnlockedAchievement == null) {
      return;
    }

    _latestUnlockedAchievement = null;
    notifyListeners();

    _latestUnlockedAchievement = null;
  }

  Future<void> resetProgress() async {
    _progress = const QuizProgress.empty();

    _answeredQuestionId = null;

    notifyListeners();

    try {
      await _progressRepository.clear();
    } catch (error, stackTrace) {
      debugPrint(
        'Quiz progress could not be cleared: '
        '$error\n$stackTrace',
      );
    }
  }
}

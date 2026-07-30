import 'package:flutter/foundation.dart';

import '../domain/entities/quiz_category.dart';
import '../domain/entities/quiz_difficulty.dart';
import '../domain/entities/quiz_progress.dart';
import '../domain/entities/quiz_question.dart';
import '../domain/repositories/quiz_repository.dart';

class QuizController extends ChangeNotifier {
  QuizController({required QuizRepository repository})
    : _repository = repository;

  final QuizRepository _repository;

  QuizQuestion? _activeQuestion;
  QuizCategory? _preferredCategory;
  QuizDifficulty _difficulty = QuizDifficulty.easy;
  QuizProgress _progress = const QuizProgress.empty();

  String? _answeredQuestionId;

  QuizQuestion? get activeQuestion => _activeQuestion;
  QuizCategory? get preferredCategory => _preferredCategory;
  QuizDifficulty get difficulty => _difficulty;
  QuizProgress get progress => _progress;

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

  void recordAnswer({required int selectedIndex}) {
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

    _progress = _progress.recordAnswer(isCorrect: isCorrect);

    notifyListeners();
  }

  void resetProgress() {
    _progress = const QuizProgress.empty();
    _answeredQuestionId = null;

    notifyListeners();
  }
}

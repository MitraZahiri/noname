import 'package:flutter/foundation.dart';

import '../domain/entities/quiz_category.dart';
import '../domain/entities/quiz_difficulty.dart';
import '../domain/entities/quiz_question.dart';
import '../domain/repositories/quiz_repository.dart';

class QuizController extends ChangeNotifier {
  QuizController({required QuizRepository repository})
    : _repository = repository;

  final QuizRepository _repository;

  QuizQuestion? _activeQuestion;
  QuizCategory? _preferredCategory;
  QuizDifficulty _difficulty = QuizDifficulty.easy;

  QuizQuestion? get activeQuestion => _activeQuestion;
  QuizCategory? get preferredCategory => _preferredCategory;
  QuizDifficulty get difficulty => _difficulty;

  QuizQuestion prepareNextQuestion({required String localeCode}) {
    final question = _repository.getNextQuestion(
      localeCode: localeCode,
      category: _preferredCategory,
      difficulty: _difficulty,
    );

    _activeQuestion = question;
    notifyListeners();

    return question;
  }

  void selectCategory(QuizCategory? category) {
    _preferredCategory = category;
    notifyListeners();
  }

  void selectDifficulty(QuizDifficulty difficulty) {
    _difficulty = difficulty;
    notifyListeners();
  }

  void recordAnswer({required int selectedIndex}) {
    final question = _activeQuestion;

    if (question == null) {
      return;
    }

    _repository.recordAnswer(
      questionId: question.id,
      selectedIndex: selectedIndex,
      isCorrect: question.isCorrect(selectedIndex),
    );
  }
}

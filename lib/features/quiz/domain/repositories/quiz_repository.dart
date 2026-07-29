import '../entities/quiz_category.dart';
import '../entities/quiz_difficulty.dart';
import '../entities/quiz_question.dart';

abstract interface class QuizRepository {
  QuizQuestion getNextQuestion({
    required String localeCode,
    QuizCategory? category,
    QuizDifficulty? difficulty,
  });

  void recordAnswer({
    required String questionId,
    required int selectedIndex,
    required bool isCorrect,
  });
}

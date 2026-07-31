import 'quiz_category.dart';
import 'quiz_difficulty.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.localeCode,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.category,
    required this.difficulty,
    required this.explanation,
  }) : assert(options.length == 3),
       assert(correctIndex >= 0 && correctIndex < options.length);

  final String id;
  final String localeCode;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final QuizCategory category;
  final QuizDifficulty difficulty;
  final String explanation;

  bool isCorrect(int selectedIndex) {
    return selectedIndex == correctIndex;
  }

  Map<String, Object> toPlatformMap() {
    return {
      'id': id,
      'localeCode': localeCode,
      'prompt': prompt,
      'options': options,
      'correctIndex': correctIndex,
      'category': category.name,
      'difficulty': difficulty.name,
      'explanation': explanation,
    };
  }
}

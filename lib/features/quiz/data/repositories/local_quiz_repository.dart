import 'dart:math';

import '../../domain/entities/quiz_category.dart';
import '../../domain/entities/quiz_difficulty.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../sources/quiz_seed_data.dart';

class LocalQuizRepository implements QuizRepository {
  LocalQuizRepository({Random? random}) : _random = random ?? Random();

  final Random _random;

  final Set<String> _recentQuestionIds = <String>{};

  @override
  QuizQuestion getNextQuestion({
    required String localeCode,
    QuizCategory? category,
    QuizDifficulty? difficulty,
  }) {
    final normalizedLocale = localeCode.toLowerCase().split('-').first;

    var candidates =
        QuizSeedData.questions.where((question) {
          final localeMatches = question.localeCode == normalizedLocale;
          final categoryMatches =
              category == null || question.category == category;
          final difficultyMatches =
              difficulty == null || question.difficulty == difficulty;

          return localeMatches && categoryMatches && difficultyMatches;
        }).toList();

    if (candidates.isEmpty && normalizedLocale != 'en') {
      candidates =
          QuizSeedData.questions.where((question) {
            return question.localeCode == 'en' &&
                (category == null || question.category == category) &&
                (difficulty == null || question.difficulty == difficulty);
          }).toList();
    }

    if (candidates.isEmpty) {
      throw StateError('No matching quiz questions are available.');
    }

    final unseenQuestions =
        candidates
            .where((question) => !_recentQuestionIds.contains(question.id))
            .toList();

    final selectableQuestions =
        unseenQuestions.isNotEmpty ? unseenQuestions : candidates;

    if (unseenQuestions.isEmpty) {
      _recentQuestionIds.clear();
    }

    final selected =
        selectableQuestions[_random.nextInt(selectableQuestions.length)];

    _recentQuestionIds.add(selected.id);

    return selected;
  }

  @override
  void recordAnswer({
    required String questionId,
    required int selectedIndex,
    required bool isCorrect,
  }) {
    // Sonraki aşamada doğru/yanlış sayıları yerel veritabanına yazılacak.
  }
}

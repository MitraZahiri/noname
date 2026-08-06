import 'dart:math';

import '../../domain/entities/quiz_category.dart';
import '../../domain/entities/quiz_difficulty.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../sources/quiz_seed_data.dart';

class LocalQuizRepository implements QuizRepository {
  LocalQuizRepository({Random? random}) : _random = random ?? Random();

  final Random _random;

  final Set<String> _usedQuestionIds = <String>{};

  String? _lastQuestionId;

  @override
  QuizQuestion getNextQuestion({
    required String localeCode,
    QuizCategory? category,
    QuizDifficulty? difficulty,
  }) {
    final normalizedLocale = localeCode.toLowerCase().split('-').first;

    var candidates = _findQuestions(
      localeCode: normalizedLocale,
      category: category,
      difficulty: difficulty,
    );

    if (candidates.isEmpty && normalizedLocale != 'en') {
      candidates = _findQuestions(
        localeCode: 'en',
        category: category,
        difficulty: difficulty,
      );
    }

    if (candidates.isEmpty) {
      throw StateError('No matching quiz questions are available.');
    }

    var selectableQuestions =
        candidates.where((question) {
          final unused = !_usedQuestionIds.contains(question.id);

          final isNotLastQuestion =
              candidates.length == 1 || question.id != _lastQuestionId;

          return unused && isNotLastQuestion;
        }).toList();

    if (selectableQuestions.isEmpty) {
      _usedQuestionIds.removeAll(candidates.map((question) => question.id));

      final questionsExceptLast =
          candidates.where((question) {
            return question.id != _lastQuestionId;
          }).toList();

      selectableQuestions =
          questionsExceptLast.isNotEmpty ? questionsExceptLast : candidates;
    }

    final selected =
        selectableQuestions[_random.nextInt(selectableQuestions.length)];

    _usedQuestionIds.add(selected.id);
    _lastQuestionId = selected.id;

    return selected;
  }

  List<QuizQuestion> _findQuestions({
    required String localeCode,
    required QuizCategory? category,
    required QuizDifficulty? difficulty,
  }) {
    return QuizSeedData.questions.where((question) {
      final localeMatches = question.localeCode == localeCode;

      final categoryMatches = category == null || question.category == category;

      final difficultyMatches =
          difficulty == null || question.difficulty == difficulty;

      return localeMatches && categoryMatches && difficultyMatches;
    }).toList();
  }

  @override
  void recordAnswer({
    required String questionId,
    required int selectedIndex,
    required bool isCorrect,
  }) {
    // İlerleme bilgileri QuizProgressRepository tarafından kaydediliyor.
  }
}

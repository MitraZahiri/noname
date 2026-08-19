import 'dart:math';

import 'package:flutter/material.dart';

import '../../../quiz/application/quiz_controller.dart';
import '../../application/daily_goals_controller.dart';
import '../../application/learning_game_progress_controller.dart';
import 'memory_match_game_page.dart';

class LearningGamesPage extends StatefulWidget {
  const LearningGamesPage({
    required this.quizController,
    required this.dailyGoalsController,
    required this.progressController,
    required this.companionName,
    required this.isTurkish,
    required this.onQuickQuiz,
    super.key,
  });

  final QuizController quizController;
  final DailyGoalsController dailyGoalsController;
  final LearningGameProgressController progressController;
  final String companionName;
  final bool isTurkish;
  final Future<void> Function() onQuickQuiz;

  @override
  State<LearningGamesPage> createState() => _LearningGamesPageState();
}

class _LearningGamesPageState extends State<LearningGamesPage> {
  final Random _random = Random();

  Future<void> _openTrueFalseGame() async {
    final localeCode = widget.isTurkish ? 'tr' : 'en';

    var question = widget.quizController.prepareNextQuestion(
      localeCode: localeCode,
    );

    late int statementOptionIndex;
    late bool statementIsTrue;

    void prepareStatement() {
      final wrongIndexes = <int>[
        for (var index = 0; index < question.options.length; index++)
          if (index != question.correctIndex) index,
      ];

      if (wrongIndexes.isEmpty || _random.nextBool()) {
        statementIsTrue = true;
        statementOptionIndex = question.correctIndex;
      } else {
        statementIsTrue = false;
        statementOptionIndex =
            wrongIndexes[_random.nextInt(wrongIndexes.length)];
      }
    }

    prepareStatement();

    var answered = false;
    var roundCorrect = false;
    var knowledgeReward = 0;
    var gameScore = 0;
    var combo = 0;

    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> answer(bool answerValue) async {
              if (answered) {
                return;
              }

              final isCorrect = answerValue == statementIsTrue;

              final nextCombo = isCorrect ? combo + 1 : 0;

              final scoreGain = isCorrect ? 10 + ((nextCombo - 1) * 2) : 0;

              setSheetState(() {
                answered = true;
                roundCorrect = isCorrect;
                knowledgeReward = isCorrect ? 10 : 2;

                combo = nextCombo;
                gameScore += scoreGain;
              });

              final wrongIndexes = <int>[
                for (var index = 0; index < question.options.length; index++)
                  if (index != question.correctIndex) index,
              ];

              final int recordedIndex;

              if (isCorrect) {
                recordedIndex = question.correctIndex;
              } else if (!statementIsTrue) {
                recordedIndex = statementOptionIndex;
              } else if (wrongIndexes.isNotEmpty) {
                recordedIndex = wrongIndexes.first;
              } else {
                recordedIndex = question.correctIndex;
              }

              await widget.quizController.recordAnswer(
                selectedIndex: recordedIndex,
              );

              await widget.dailyGoalsController.complete(DailyGoalType.quiz);

              await widget.progressController.submitScore(
                LearningGameType.trueFalse,
                gameScore,
              );
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.rule_rounded, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.isTurkish
                                ? 'Doğru mu, Yanlış mı?'
                                : 'True or False?',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.stars_rounded, size: 17),
                          label: Text(
                            widget.isTurkish
                                ? 'Skor $gameScore'
                                : 'Score $gameScore',
                          ),
                        ),
                        Chip(
                          avatar: const Icon(
                            Icons.local_fire_department_rounded,
                            size: 17,
                          ),
                          label: Text('Combo x$combo'),
                        ),
                        AnimatedBuilder(
                          animation: widget.progressController,
                          builder: (context, _) {
                            final bestScore = widget.progressController
                                .bestScoreFor(LearningGameType.trueFalse);

                            return Chip(
                              avatar: const Icon(
                                Icons.emoji_events_rounded,
                                size: 17,
                              ),
                              label: Text(
                                widget.isTurkish
                                    ? 'Rekor $bestScore'
                                    : 'Best $bestScore',
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text(
                      question.prompt,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        '"${question.options[statementOptionIndex]}"',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed:
                                answered
                                    ? null
                                    : () {
                                      answer(true);
                                    },
                            icon: const Icon(Icons.check_circle_rounded),
                            label: Text(widget.isTurkish ? 'Doğru' : 'True'),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed:
                                answered
                                    ? null
                                    : () {
                                      answer(false);
                                    },
                            icon: const Icon(Icons.cancel_rounded),
                            label: Text(widget.isTurkish ? 'Yanlış' : 'False'),
                          ),
                        ),
                      ],
                    ),

                    if (answered) ...[
                      const SizedBox(height: 18),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              roundCorrect
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer
                                  : Theme.of(
                                    context,
                                  ).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roundCorrect
                                  ? (widget.isTurkish
                                      ? 'Doğru! 🎉'
                                      : 'Correct! 🎉')
                                  : (widget.isTurkish
                                      ? 'Bu kez olmadı 📚'
                                      : 'Not this time 📚'),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              widget.isTurkish
                                  ? '+$knowledgeReward Bilgi'
                                  : '+$knowledgeReward Knowledge',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),

                            if (roundCorrect) ...[
                              const SizedBox(height: 4),
                              Text(
                                combo > 1
                                    ? (widget.isTurkish
                                        ? '🔥 $combo doğru seri!'
                                        : '🔥 $combo answer streak!')
                                    : (widget.isTurkish
                                        ? '+10 skor'
                                        : '+10 score'),
                              ),
                            ],

                            const SizedBox(height: 10),

                            Text(question.explanation),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      FilledButton.icon(
                        onPressed: () {
                          setSheetState(() {
                            question = widget.quizController
                                .prepareNextQuestion(localeCode: localeCode);

                            answered = false;
                            roundCorrect = false;
                            knowledgeReward = 0;

                            prepareStatement();
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(
                          widget.isTurkish ? 'Yeni soru' : 'Next question',
                        ),
                      ),

                      const SizedBox(height: 8),

                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: Text(widget.isTurkish ? 'Bitir' : 'Finish'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openMemoryGame() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) {
          return MemoryMatchGamePage(
            dailyGoalsController: widget.dailyGoalsController,
            progressController: widget.progressController,
            isTurkish: widget.isTurkish,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isTurkish ? 'Bilgi Oyunları' : 'Learning Games'),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          widget.dailyGoalsController,
          widget.progressController,
        ]),
        builder: (context, _) {
          final quickQuizBest = widget.progressController.bestScoreFor(
            LearningGameType.quickQuiz,
          );

          final trueFalseBest = widget.progressController.bestScoreFor(
            LearningGameType.trueFalse,
          );

          final memoryBest = widget.progressController.bestScoreFor(
            LearningGameType.memoryMatch,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primaryContainer,
                      colors.secondaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Text('🎮', style: TextStyle(fontSize: 44)),

                    const SizedBox(height: 8),

                    Text(
                      widget.isTurkish
                          ? '${widget.companionName} ile oynayarak öğren!'
                          : 'Learn by playing with ${widget.companionName}!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      widget.dailyGoalsController.quizCompleted
                          ? (widget.isTurkish
                              ? 'Bugünkü öğrenme görevi tamamlandı ✅'
                              : 'Today\'s learning goal is complete ✅')
                          : (widget.isTurkish
                              ? 'Bugün en az bir bilgi oyunu oyna.'
                              : 'Play at least one learning game today.'),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events_rounded, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            widget.isTurkish
                                ? 'Toplam Rekor ${quickQuizBest + trueFalseBest + memoryBest}'
                                : 'Total Best ${quickQuizBest + trueFalseBest + memoryBest}',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _LearningGameCard(
                icon: Icons.quiz_rounded,
                title: widget.isTurkish ? 'Hızlı Quiz' : 'Quick Quiz',
                subtitle:
                    widget.isTurkish
                        ? 'Soruyu oku ve doğru cevabı seç.'
                        : 'Read the question and choose the answer.',
                bestScore: quickQuizBest,
                isTurkish: widget.isTurkish,
                onTap: () async {
                  await widget.onQuickQuiz();
                },
              ),

              const SizedBox(height: 12),

              _LearningGameCard(
                icon: Icons.rule_rounded,
                title: widget.isTurkish ? 'Doğru / Yanlış' : 'True / False',
                subtitle:
                    widget.isTurkish
                        ? 'Verilen bilginin doğru olup olmadığını bul.'
                        : 'Decide whether the statement is correct.',
                bestScore: trueFalseBest,
                isTurkish: widget.isTurkish,
                onTap: _openTrueFalseGame,
              ),

              const SizedBox(height: 12),

              _LearningGameCard(
                icon: Icons.psychology_rounded,
                title: widget.isTurkish ? 'Hafıza Eşleştirme' : 'Memory Match',
                subtitle:
                    widget.isTurkish
                        ? 'Bilgi kartlarını doğru eşleriyle buluştur.'
                        : 'Match each knowledge card with its pair.',
                bestScore: memoryBest,
                isTurkish: widget.isTurkish,
                onTap: _openMemoryGame,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LearningGameCard extends StatelessWidget {
  const _LearningGameCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bestScore,
    required this.isTurkish,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int bestScore;
  final bool isTurkish;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, size: 30, color: colors.onPrimaryContainer),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events_rounded,
                          size: 16,
                          color: colors.primary,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          isTurkish ? 'Rekor $bestScore' : 'Best $bestScore',
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

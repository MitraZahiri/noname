import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../application/daily_goals_controller.dart';
import '../../application/learning_game_progress_controller.dart';

class MathSprintGamePage extends StatefulWidget {
  const MathSprintGamePage({
    required this.dailyGoalsController,
    required this.progressController,
    required this.isTurkish,
    super.key,
  });

  final DailyGoalsController dailyGoalsController;
  final LearningGameProgressController progressController;
  final bool isTurkish;

  @override
  State<MathSprintGamePage> createState() => _MathSprintGamePageState();
}

class _MathSprintGamePageState extends State<MathSprintGamePage> {
  static const int _gameDurationSeconds = 30;

  final Random _random = Random();

  Timer? _timer;

  int _secondsLeft = _gameDurationSeconds;
  int _score = 0;
  int _combo = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;

  late _MathQuestion _question;

  bool _gameFinished = false;

  @override
  void initState() {
    super.initState();

    _question = _createQuestion();

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsLeft <= 1) {
        timer.cancel();

        setState(() {
          _secondsLeft = 0;
        });

        unawaited(_finishGame());

        return;
      }

      setState(() {
        _secondsLeft--;
      });
    });
  }

  _MathQuestion _createQuestion() {
    final type = _random.nextInt(3);

    switch (type) {
      case 0:
        final first = _random.nextInt(40) + 1;
        final second = _random.nextInt(40) + 1;

        return _MathQuestion(text: '$first + $second', answer: first + second);

      case 1:
        final first = _random.nextInt(40) + 10;
        final second = _random.nextInt(first);

        return _MathQuestion(text: '$first - $second', answer: first - second);

      default:
        final first = _random.nextInt(9) + 2;
        final second = _random.nextInt(9) + 2;

        return _MathQuestion(text: '$first × $second', answer: first * second);
    }
  }

  List<int> _answerOptions() {
    final answers = <int>{_question.answer};

    while (answers.length < 4) {
      final offset = _random.nextInt(15) - 7;

      if (offset == 0) {
        continue;
      }

      final candidate = _question.answer + offset;

      if (candidate >= 0) {
        answers.add(candidate);
      }
    }

    final result = answers.toList();

    result.shuffle(_random);

    return result;
  }

  Future<void> _answer(int selectedAnswer) async {
    if (_gameFinished || _secondsLeft <= 0) {
      return;
    }

    final correct = selectedAnswer == _question.answer;

    setState(() {
      if (correct) {
        _combo++;

        final scoreGain = 10 + ((_combo - 1) * 2);

        _score += scoreGain;
        _correctAnswers++;
      } else {
        _combo = 0;
        _wrongAnswers++;
      }

      _question = _createQuestion();
    });

    await widget.progressController.submitScore(
      LearningGameType.mathSprint,
      _score,
    );
  }

  Future<void> _finishGame() async {
    if (_gameFinished) {
      return;
    }

    _gameFinished = true;

    await widget.progressController.submitScore(
      LearningGameType.mathSprint,
      _score,
    );

    if (_correctAnswers > 0) {
      await widget.dailyGoalsController.complete(DailyGoalType.quiz);
    }

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _restartGame() {
    _timer?.cancel();

    setState(() {
      _secondsLeft = _gameDurationSeconds;
      _score = 0;
      _combo = 0;
      _correctAnswers = 0;
      _wrongAnswers = 0;
      _gameFinished = false;
      _question = _createQuestion();
    });

    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final answers = _answerOptions();

    final bestScore = widget.progressController.bestScoreFor(
      LearningGameType.mathSprint,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isTurkish ? 'Matematik Sprint' : 'Math Sprint'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.progressController,
          builder: (context, _) {
            if (_gameFinished) {
              return _MathSprintResult(
                score: _score,
                bestScore: bestScore,
                correctAnswers: _correctAnswers,
                wrongAnswers: _wrongAnswers,
                isTurkish: widget.isTurkish,
                onRestart: _restartGame,
              );
            }

            return Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _MathInfoCard(
                          icon: Icons.timer_rounded,
                          text: '${_secondsLeft}s',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MathInfoCard(
                          icon: Icons.stars_rounded,
                          text:
                              widget.isTurkish
                                  ? 'Skor $_score'
                                  : 'Score $_score',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MathInfoCard(
                          icon: Icons.emoji_events_rounded,
                          text:
                              widget.isTurkish
                                  ? 'Rekor $bestScore'
                                  : 'Best $bestScore',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _combo > 1
                              ? colors.tertiaryContainer
                              : colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 19,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Combo x$_combo',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Text(
                    widget.isTurkish ? 'İşlemi çöz' : 'Solve the problem',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Text(
                      _question.text,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: answers.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.0,
                        ),
                    itemBuilder: (context, index) {
                      final answer = answers[index];

                      return FilledButton.tonal(
                        onPressed: () {
                          unawaited(_answer(answer));
                        },
                        child: Text(
                          '$answer',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  Text(
                    widget.isTurkish
                        ? 'Doğru: $_correctAnswers • Yanlış: $_wrongAnswers'
                        : 'Correct: $_correctAnswers • Wrong: $_wrongAnswers',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MathSprintResult extends StatelessWidget {
  const _MathSprintResult({
    required this.score,
    required this.bestScore,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.isTurkish,
    required this.onRestart,
  });

  final int score;
  final int bestScore;
  final int correctAnswers;
  final int wrongAnswers;
  final bool isTurkish;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 72)),

            const SizedBox(height: 18),

            Text(
              isTurkish ? 'Süre doldu!' : 'Time is up!',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Text(isTurkish ? 'Skor' : 'Score'),

            Text(
              '$score',
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 18),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                Chip(
                  avatar: const Icon(Icons.emoji_events_rounded),
                  label: Text(
                    isTurkish ? 'Rekor $bestScore' : 'Best $bestScore',
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.check_circle_rounded),
                  label: Text('$correctAnswers'),
                ),
                Chip(
                  avatar: const Icon(Icons.cancel_rounded),
                  label: Text('$wrongAnswers'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.replay_rounded),
              label: Text(isTurkish ? 'Tekrar oyna' : 'Play again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MathInfoCard extends StatelessWidget {
  const _MathInfoCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 3),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _MathQuestion {
  const _MathQuestion({required this.text, required this.answer});

  final String text;
  final int answer;
}

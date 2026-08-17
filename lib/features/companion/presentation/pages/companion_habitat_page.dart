import 'package:flutter/material.dart';

import '../../../quiz/application/quiz_controller.dart';
import '../../application/companion_controller.dart';
import '../../application/daily_goals_controller.dart';
import '../../domain/entities/companion_state.dart';
import '../widgets/companion_mascot.dart';

enum _HabitatAction { none, feeding, playing, resting }

class CompanionHabitatPage extends StatefulWidget {
  const CompanionHabitatPage({
    required this.controller,
    required this.quizController,
    super.key,
  });

  final CompanionController controller;
  final QuizController quizController;

  @override
  State<CompanionHabitatPage> createState() => _CompanionHabitatPageState();
}

class _CompanionHabitatPageState extends State<CompanionHabitatPage> {
  _HabitatAction _action = _HabitatAction.none;

  late final DailyGoalsController _dailyGoalsController;

  @override
  void initState() {
    super.initState();

    _dailyGoalsController = DailyGoalsController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.controller.refreshForElapsedTime();

      await _dailyGoalsController.initialize();
    });
  }

  @override
  void dispose() {
    _dailyGoalsController.dispose();
    super.dispose();
  }

  Future<void> _performAction(
    _HabitatAction action,
    Future<void> Function() operation,
  ) async {
    if (_action != _HabitatAction.none) {
      return;
    }

    setState(() {
      _action = action;
    });

    try {
      await operation();

      switch (action) {
        case _HabitatAction.feeding:
          await _dailyGoalsController.complete(DailyGoalType.feed);

        case _HabitatAction.playing:
          await _dailyGoalsController.complete(DailyGoalType.play);

        case _HabitatAction.resting:
        case _HabitatAction.none:
          break;
      }

      await Future<void>.delayed(const Duration(milliseconds: 850));
    } finally {
      if (mounted) {
        setState(() {
          _action = _HabitatAction.none;
        });
      }
    }
  }

  Future<void> _openLearningQuiz() async {
    final localeCode = Localizations.localeOf(context).languageCode;

    final isTurkish = localeCode == 'tr';

    var question = widget.quizController.prepareNextQuestion(
      localeCode: localeCode,
    );

    int? selectedIndex;
    bool answered = false;
    int knowledgeReward = 0;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isCorrect =
                answered && selectedIndex == question.correctIndex;

            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  20 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school_rounded, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isTurkish
                                ? '${widget.controller.state.name} ile öğren'
                                : 'Learn with ${widget.controller.state.name}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
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

                    const SizedBox(height: 18),

                    for (
                      var index = 0;
                      index < question.options.length;
                      index++
                    ) ...[
                      _QuizOptionButton(
                        text: question.options[index],
                        index: index,
                        selectedIndex: selectedIndex,
                        correctIndex: question.correctIndex,
                        answered: answered,
                        onPressed: () async {
                          if (answered) {
                            return;
                          }

                          final selectedIsCorrect =
                              index == question.correctIndex;

                          setSheetState(() {
                            selectedIndex = index;

                            answered = true;

                            knowledgeReward = selectedIsCorrect ? 10 : 2;
                          });

                          await widget.quizController.recordAnswer(
                            selectedIndex: index,
                          );

                          await _dailyGoalsController.complete(
                            DailyGoalType.quiz,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                    ],

                    if (answered) ...[
                      const SizedBox(height: 8),

                      _KnowledgeRewardBanner(
                        amount: knowledgeReward,
                        isCorrect: isCorrect,
                        isTurkish: isTurkish,
                      ),

                      const SizedBox(height: 12),

                      _QuizResultCard(
                        isCorrect: isCorrect,
                        explanation: question.explanation,
                        isTurkish: isTurkish,
                      ),

                      const SizedBox(height: 16),

                      FilledButton.icon(
                        onPressed: () {
                          setSheetState(() {
                            question = widget.quizController
                                .prepareNextQuestion(localeCode: localeCode);

                            selectedIndex = null;

                            answered = false;

                            knowledgeReward = 0;
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(
                          isTurkish ? 'Bir soru daha' : 'Another question',
                        ),
                      ),

                      const SizedBox(height: 10),

                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: Text(isTurkish ? 'Bitir' : 'Finish'),
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return AnimatedBuilder(
          animation: _dailyGoalsController,
          builder: (context, _) {
            final state = widget.controller.state;

            final isTurkish =
                Localizations.localeOf(context).languageCode == 'tr';

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  isTurkish
                      ? '${state.name} Habitatı'
                      : '${state.name}\'s Habitat',
                ),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: _HabitatRoom(
                        controller: widget.controller,
                        state: state,
                        action: _action,
                        isTurkish: isTurkish,
                        onAction: _performAction,
                        onLearn: _openLearningQuiz,
                      ),
                    ),

                    _DailyGoalsCard(
                      controller: _dailyGoalsController,
                      companionName: state.name,
                      isTurkish: isTurkish,
                    ),

                    _GrowthProgress(state: state, isTurkish: isTurkish),

                    _StatsPanel(state: state, isTurkish: isTurkish),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _HabitatRoom extends StatelessWidget {
  const _HabitatRoom({
    required this.controller,
    required this.state,
    required this.action,
    required this.isTurkish,
    required this.onAction,
    required this.onLearn,
  });

  final CompanionController controller;
  final CompanionState state;
  final _HabitatAction action;
  final bool isTurkish;

  final Future<void> Function(
    _HabitatAction action,
    Future<void> Function() operation,
  )
  onAction;

  final Future<void> Function() onLearn;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors.primaryContainer, colors.secondaryContainer],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 24,
                left: 24,
                child: FilledButton.tonalIcon(
                  onPressed:
                      action == _HabitatAction.none
                          ? () async {
                            await onLearn();
                          }
                          : null,
                  icon: const Icon(Icons.school_rounded, size: 20),
                  label: Text(isTurkish ? 'Öğren' : 'Learn'),
                ),
              ),

              Positioned(
                top: 24,
                right: 24,
                child: _StageBadge(stage: state.stage, isTurkish: isTurkish),
              ),

              Positioned(
                top: 82,
                left: 24,
                right: 24,
                child: Center(
                  child: _CompanionSpeechBubble(
                    need: state.primaryNeed,
                    name: state.name,
                    isTurkish: isTurkish,
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: constraints.maxHeight * 0.24,
                child: ColoredBox(color: colors.surfaceContainerHighest),
              ),

              Center(
                child: _CompanionCharacter(
                  state: state,
                  action: action,
                  onPet: controller.pet,
                ),
              ),

              Positioned(
                left: 18,
                bottom: 28,
                child: _RoomAction(
                  icon: Icons.restaurant_rounded,
                  label: isTurkish ? 'Besle' : 'Feed',
                  enabled: action == _HabitatAction.none,
                  onTap: () async {
                    await onAction(_HabitatAction.feeding, controller.feed);
                  },
                ),
              ),

              Positioned(
                bottom: 28,
                left: 0,
                right: 0,
                child: Center(
                  child: _RoomAction(
                    icon: Icons.toys_rounded,
                    label: isTurkish ? 'Oyna' : 'Play',
                    enabled: action == _HabitatAction.none,
                    onTap: () async {
                      await onAction(_HabitatAction.playing, controller.play);
                    },
                  ),
                ),
              ),

              Positioned(
                right: 18,
                bottom: 28,
                child: _RoomAction(
                  icon: Icons.bed_rounded,
                  label: isTurkish ? 'Uyu' : 'Sleep',
                  enabled: action == _HabitatAction.none,
                  onTap: () async {
                    await onAction(_HabitatAction.resting, controller.rest);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DailyGoalsCard extends StatelessWidget {
  const _DailyGoalsCard({
    required this.controller,
    required this.companionName,
    required this.isTurkish,
  });

  final DailyGoalsController controller;
  final String companionName;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  controller.allCompleted
                      ? Icons.emoji_events_rounded
                      : Icons.flag_rounded,
                  size: 20,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    controller.allCompleted
                        ? (isTurkish
                            ? 'Günlük görevler tamamlandı! 🏆'
                            : 'Daily goals complete! 🏆')
                        : (isTurkish ? 'Günlük Görevler' : 'Daily Goals'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                _CoinBadge(coins: controller.coins),

                const SizedBox(width: 8),

                if (controller.streak > 0)
                  _StreakBadge(streak: controller.streak),
              ],
            ),

            const SizedBox(height: 10),

            if (!controller.isInitialized)
              const LinearProgressIndicator()
            else ...[
              _DailyGoalRow(
                completed: controller.quizCompleted,
                icon: Icons.school_rounded,
                text: isTurkish ? '1 soru cevapla' : 'Answer 1 question',
              ),

              _DailyGoalRow(
                completed: controller.feedCompleted,
                icon: Icons.restaurant_rounded,
                text:
                    isTurkish
                        ? '$companionName\'yu besle'
                        : 'Feed $companionName',
              ),

              _DailyGoalRow(
                completed: controller.playCompleted,
                icon: Icons.toys_rounded,
                text:
                    isTurkish
                        ? '$companionName ile oyna'
                        : 'Play with $companionName',
              ),

              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: controller.progress,
                  minHeight: 7,
                ),
              ),

              const SizedBox(height: 8),

              if (controller.allCompleted && controller.rewardEarnedToday)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isTurkish
                              ? '+${DailyGoalsController.dailyCompletionReward} coin kazandın!'
                              : '+${DailyGoalsController.dailyCompletionReward} coins earned!',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  isTurkish
                      ? 'Tüm görevleri tamamla ve '
                          '${DailyGoalsController.dailyCompletionReward} 🪙 kazan.'
                      : 'Complete all goals and earn '
                          '${DailyGoalsController.dailyCompletionReward} 🪙.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),

              if (controller.allCompleted && controller.streak > 0) ...[
                const SizedBox(height: 7),

                Text(
                  isTurkish
                      ? '🔥 ${controller.streak} günlük seri! Yarın da devam et.'
                      : '🔥 ${controller.streak} day streak! Come back tomorrow.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _CoinBadge extends StatelessWidget {
  const _CoinBadge({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪙', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 4),
          Text(
            '$coins',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _DailyGoalRow extends StatelessWidget {
  const _DailyGoalRow({
    required this.completed,
    required this.icon,
    required this.text,
  });

  final bool completed;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            completed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: completed ? colors.primary : colors.onSurfaceVariant,
          ),

          const SizedBox(width: 8),

          Icon(icon, size: 17),

          const SizedBox(width: 6),

          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                decoration: completed ? TextDecoration.lineThrough : null,
                color: completed ? colors.onSurfaceVariant : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanionSpeechBubble extends StatelessWidget {
  const _CompanionSpeechBubble({
    required this.need,
    required this.name,
    required this.isTurkish,
  });

  final CompanionNeed need;
  final String name;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    final text = switch (need) {
      CompanionNeed.food =>
        isTurkish
            ? 'Acıktım! Bir şeyler yiyebilir miyim? 🍎'
            : 'I am hungry! Can I have something to eat? 🍎',

      CompanionNeed.happiness =>
        isTurkish
            ? 'Biraz benimle oynar mısın? 🎮'
            : 'Will you play with me for a while? 🎮',

      CompanionNeed.rest =>
        isTurkish
            ? 'Uykum geldi... Biraz dinlenmeliyim. 💤'
            : 'I am sleepy... I should get some rest. 💤',

      CompanionNeed.learning =>
        isTurkish
            ? 'Yeni bir şey öğrenmek istiyorum! 📚'
            : 'I want to learn something new! 📚',

      CompanionNeed.none =>
        isTurkish
            ? '$name bugün kendini harika hissediyor! 💜'
            : '$name feels great today! 💜',
    };

    final colors = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      constraints: const BoxConstraints(maxWidth: 310),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _CompanionCharacter extends StatelessWidget {
  const _CompanionCharacter({
    required this.state,
    required this.action,
    required this.onPet,
  });

  final CompanionState state;
  final _HabitatAction action;

  final Future<void> Function() onPet;

  @override
  Widget build(BuildContext context) {
    final scale = switch (action) {
      _HabitatAction.feeding => 1.10,
      _HabitatAction.playing => 1.08,
      _HabitatAction.resting => 0.90,
      _HabitatAction.none => 1.0,
    };

    final turns = switch (action) {
      _HabitatAction.playing => 0.035,
      _ => 0.0,
    };

    final pose = switch (action) {
      _HabitatAction.feeding => CompanionMascotPose.feeding,
      _HabitatAction.playing => CompanionMascotPose.playing,
      _HabitatAction.resting => CompanionMascotPose.resting,
      _HabitatAction.none => CompanionMascotPose.idle,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: AnimatedRotation(
            turns: turns,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CompanionMascot(
                  mood: state.mood,
                  pose: pose,
                  width: 180,
                  onTap: onPet,
                ),

                if (action == _HabitatAction.feeding)
                  const Positioned(
                    top: 30,
                    right: -4,
                    child: Text('🍎', style: TextStyle(fontSize: 34)),
                  ),

                if (action == _HabitatAction.playing)
                  const Positioned(
                    top: 20,
                    right: -5,
                    child: Text('✨', style: TextStyle(fontSize: 34)),
                  ),

                if (action == _HabitatAction.resting)
                  const Positioned(
                    top: 10,
                    right: -8,
                    child: Text('💤', style: TextStyle(fontSize: 36)),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          state.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _RoomAction extends StatelessWidget {
  const _RoomAction({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 38),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageBadge extends StatelessWidget {
  const _StageBadge({required this.stage, required this.isTurkish});

  final CompanionStage stage;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.auto_awesome_rounded, size: 17),
      label: Text(switch (stage) {
        CompanionStage.baby => isTurkish ? 'Bebek' : 'Baby',

        CompanionStage.child => isTurkish ? 'Çocuk' : 'Child',

        CompanionStage.explorer => isTurkish ? 'Kaşif' : 'Explorer',

        CompanionStage.scholar => isTurkish ? 'Bilgin' : 'Scholar',
      }),
    );
  }
}

class _GrowthProgress extends StatelessWidget {
  const _GrowthProgress({required this.state, required this.isTurkish});

  final CompanionState state;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final nextKnowledge = state.nextStageKnowledge;

    final currentStage = _stageText(state.stage, isTurkish: isTurkish);

    final nextStage = _nextStageText(state.stage, isTurkish: isTurkish);

    final remainingKnowledge =
        nextKnowledge == null
            ? 0
            : (nextKnowledge - state.knowledge).clamp(0, nextKnowledge).toInt();

    return Material(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 20),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    isTurkish ? 'Gelişim' : 'Growth',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  nextStage == null
                      ? currentStage
                      : '$currentStage → $nextStage',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: state.stageProgress,
                minHeight: 8,
              ),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Text(
                  isTurkish
                      ? 'Bilgi: ${state.knowledge}'
                      : 'Knowledge: ${state.knowledge}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),

                const Spacer(),

                Text(
                  nextKnowledge == null
                      ? (isTurkish ? 'En yüksek aşama 🎓' : 'Highest stage 🎓')
                      : (isTurkish
                          ? '$remainingKnowledge bilgi kaldı'
                          : '$remainingKnowledge knowledge left'),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _stageText(CompanionStage stage, {required bool isTurkish}) {
    return switch (stage) {
      CompanionStage.baby => isTurkish ? 'Bebek' : 'Baby',

      CompanionStage.child => isTurkish ? 'Çocuk' : 'Child',

      CompanionStage.explorer => isTurkish ? 'Kaşif' : 'Explorer',

      CompanionStage.scholar => isTurkish ? 'Bilgin' : 'Scholar',
    };
  }

  String? _nextStageText(CompanionStage stage, {required bool isTurkish}) {
    return switch (stage) {
      CompanionStage.baby => isTurkish ? 'Çocuk' : 'Child',

      CompanionStage.child => isTurkish ? 'Kaşif' : 'Explorer',

      CompanionStage.explorer => isTurkish ? 'Bilgin' : 'Scholar',

      CompanionStage.scholar => null,
    };
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({required this.state, required this.isTurkish});

  final CompanionState state;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _Stat(
                icon: Icons.restaurant_rounded,
                value: state.satiety,
                label: isTurkish ? 'Tokluk' : 'Food',
              ),
              _Stat(
                icon: Icons.favorite_rounded,
                value: state.happiness,
                label: isTurkish ? 'Mutluluk' : 'Happy',
              ),
              _Stat(
                icon: Icons.bolt_rounded,
                value: state.energy,
                label: isTurkish ? 'Enerji' : 'Energy',
              ),
              _Stat(
                icon: Icons.school_rounded,
                value: state.knowledge,
                label: isTurkish ? 'Bilgi' : 'Knowledge',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),

          const SizedBox(height: 2),

          Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),

          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _KnowledgeRewardBanner extends StatelessWidget {
  const _KnowledgeRewardBanner({
    required this.amount,
    required this.isCorrect,
    required this.isTurkish,
  });

  final int amount;
  final bool isCorrect;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.school_rounded),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              isTurkish ? '+$amount Bilgi' : '+$amount Knowledge',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          Text(isCorrect ? '✨' : '📚', style: const TextStyle(fontSize: 22)),
        ],
      ),
    );
  }
}

class _QuizOptionButton extends StatelessWidget {
  const _QuizOptionButton({
    required this.text,
    required this.index,
    required this.selectedIndex,
    required this.correctIndex,
    required this.answered,
    required this.onPressed,
  });

  final String text;
  final int index;
  final int? selectedIndex;
  final int correctIndex;
  final bool answered;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isSelected = selectedIndex == index;

    final isCorrect = index == correctIndex;

    Color? backgroundColor;
    Color? foregroundColor;

    if (answered) {
      if (isCorrect) {
        backgroundColor = colors.primaryContainer;

        foregroundColor = colors.onPrimaryContainer;
      } else if (isSelected) {
        backgroundColor = colors.errorContainer;

        foregroundColor = colors.onErrorContainer;
      }
    }

    return FilledButton(
      onPressed: answered ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor:
            backgroundColor ?? colors.surfaceContainerHighest,
        disabledForegroundColor: foregroundColor ?? colors.onSurfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text)),

          if (answered && isCorrect) const Icon(Icons.check_circle_rounded),

          if (answered && isSelected && !isCorrect)
            const Icon(Icons.cancel_rounded),
        ],
      ),
    );
  }
}

class _QuizResultCard extends StatelessWidget {
  const _QuizResultCard({
    required this.isCorrect,
    required this.explanation,
    required this.isTurkish,
  });

  final bool isCorrect;
  final String explanation;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? colors.primaryContainer : colors.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.celebration_rounded : Icons.lightbulb_rounded,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  isCorrect
                      ? (isTurkish ? 'Doğru! 🎉' : 'Correct! 🎉')
                      : (isTurkish
                          ? 'Bir şey öğrendik! 📚'
                          : 'We learned something! 📚'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(explanation),
        ],
      ),
    );
  }
}

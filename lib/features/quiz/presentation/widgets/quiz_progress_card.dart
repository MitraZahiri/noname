import 'package:flutter/material.dart';

import '../../application/quiz_controller.dart';

class QuizProgressCard extends StatelessWidget {
  const QuizProgressCard({
    required this.controller,
    super.key,
  });

  final QuizController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final progress = controller.progress;

        final isTurkish =
            Localizations.localeOf(context).languageCode == 'tr';

        final title =
            isTurkish ? 'Bilgi ilerlemen' : 'Your trivia progress';

        final levelLabel =
            isTurkish ? 'Seviye' : 'Level';

        final nextLevelText = isTurkish
            ? 'Sonraki seviyeye ${progress.xpToNextLevel} XP'
            : '${progress.xpToNextLevel} XP to the next level';

        return Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.emoji_events_outlined,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$levelLabel ${progress.level}',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${progress.score}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 5),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'XP',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${progress.xpInCurrentLevel}'
                      '/${progress.xpInCurrentLevel + progress.xpToNextLevel}',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress.levelProgress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 7),
                Text(
                  nextLevelText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _ProgressItem(
                        icon: Icons.check_circle_outline,
                        label: isTurkish ? 'Doğru' : 'Correct',
                        value: '${progress.correctAnswers}',
                      ),
                    ),
                    Expanded(
                      child: _ProgressItem(
                        icon: Icons.cancel_outlined,
                        label: isTurkish ? 'Yanlış' : 'Wrong',
                        value: '${progress.wrongAnswers}',
                      ),
                    ),
                    Expanded(
                      child: _ProgressItem(
                        icon: Icons.percent,
                        label: isTurkish ? 'Başarı' : 'Accuracy',
                        value: '${progress.accuracyPercentage}%',
                      ),
                    ),
                    Expanded(
                      child: _ProgressItem(
                        icon: Icons.local_fire_department_outlined,
                        label: isTurkish ? 'En iyi seri' : 'Best streak',
                        value: '${progress.bestStreak}',
                      ),
                    ),
                  ],
                ),
                if (progress.totalAnswered == 0) ...[
                  const SizedBox(height: 18),
                  Text(
                    isTurkish
                        ? 'İlk sorunu cevaplayarak XP kazanmaya başla.'
                        : 'Answer your first question to start earning XP.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (progress.totalAnswered > 0) ...[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        _confirmReset(
                          context,
                          isTurkish: isTurkish,
                        );
                      },
                      icon: const Icon(
                        Icons.restart_alt,
                        size: 19,
                      ),
                      label: Text(
                        isTurkish
                            ? 'İlerlemeyi sıfırla'
                            : 'Reset progress',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmReset(
    BuildContext context, {
    required bool isTurkish,
  }) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isTurkish
                ? 'İlerleme sıfırlansın mı?'
                : 'Reset progress?',
          ),
          content: Text(
            isTurkish
                ? 'Puan, doğru cevap ve seri bilgilerin silinecek.'
                : 'Your score, answers, and streak data will be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(
                isTurkish ? 'Vazgeç' : 'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(
                isTurkish ? 'Sıfırla' : 'Reset',
              ),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      await controller.resetProgress();
    }
  }
}



class _ProgressItem extends StatelessWidget {
  const _ProgressItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Column(
        children: [
          Icon(
            icon,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

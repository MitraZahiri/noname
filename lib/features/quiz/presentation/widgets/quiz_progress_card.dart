import 'package:flutter/material.dart';

import '../../application/quiz_controller.dart';

class QuizProgressCard extends StatelessWidget {
  const QuizProgressCard({required this.controller, super.key});

  final QuizController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final progress = controller.progress;
        final isTurkish = Localizations.localeOf(context).languageCode == 'tr';

        final title = isTurkish ? 'Bilgi ilerlemen' : 'Your trivia progress';

        final scoreLabel = isTurkish ? 'Puan' : 'Score';

        final answeredLabel = isTurkish ? 'Cevaplanan' : 'Answered';

        final accuracyLabel = isTurkish ? 'Başarı' : 'Accuracy';

        final streakLabel = isTurkish ? 'Seri' : 'Streak';

        final emptyMessage =
            isTurkish
                ? 'İlk sorunu cevaplayarak puan kazanmaya başla.'
                : 'Answer your first question to start earning points.';

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
                    const Icon(Icons.emoji_events_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '${progress.score} XP',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                LinearProgressIndicator(
                  value: progress.accuracy,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _ProgressItem(
                        icon: Icons.star_outline,
                        label: scoreLabel,
                        value: '${progress.score}',
                      ),
                    ),
                    Expanded(
                      child: _ProgressItem(
                        icon: Icons.quiz_outlined,
                        label: answeredLabel,
                        value: '${progress.totalAnswered}',
                      ),
                    ),
                    Expanded(
                      child: _ProgressItem(
                        icon: Icons.percent,
                        label: accuracyLabel,
                        value: '${progress.accuracyPercentage}%',
                      ),
                    ),
                    Expanded(
                      child: _ProgressItem(
                        icon: Icons.local_fire_department_outlined,
                        label: streakLabel,
                        value: '${progress.currentStreak}',
                      ),
                    ),
                  ],
                ),
                if (progress.totalAnswered == 0) ...[
                  const SizedBox(height: 16),
                  Text(
                    emptyMessage,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
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
          Icon(icon, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

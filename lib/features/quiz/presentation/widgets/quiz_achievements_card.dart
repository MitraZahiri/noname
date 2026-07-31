import 'package:flutter/material.dart';

import '../../application/quiz_controller.dart';
import '../../domain/entities/quiz_achievement.dart';

class QuizAchievementsCard extends StatelessWidget {
  const QuizAchievementsCard({required this.controller, super.key});

  final QuizController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isTurkish = Localizations.localeOf(context).languageCode == 'tr';

        final achievements = QuizAchievement.fromProgress(controller.progress);

        final unlockedCount =
            achievements.where((achievement) => achievement.isUnlocked).length;

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_outlined, size: 27),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isTurkish ? 'Başarı rozetlerin' : 'Your achievements',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '$unlockedCount/${achievements.length}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ...achievements.map(
                  (achievement) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AchievementTile(
                      achievement: achievement,
                      isTurkish: isTurkish,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement, required this.isTurkish});

  final QuizAchievement achievement;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    final content = _contentFor(achievement.type, isTurkish: isTurkish);

    final colorScheme = Theme.of(context).colorScheme;

    final unlocked = achievement.isUnlocked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            unlocked
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              unlocked
                  ? colorScheme.primary.withValues(alpha: 0.35)
                  : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                unlocked ? colorScheme.primary : colorScheme.outlineVariant,
            foregroundColor:
                unlocked ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            child: Icon(unlocked ? content.icon : Icons.lock_outline),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  content.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (!unlocked) ...[
                  const SizedBox(height: 9),
                  LinearProgressIndicator(
                    value: achievement.progress,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${achievement.currentValue}'
                    '/${achievement.targetValue}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ],
            ),
          ),
          if (unlocked)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.check_circle),
            ),
        ],
      ),
    );
  }

  _AchievementContent _contentFor(
    QuizAchievementType type, {
    required bool isTurkish,
  }) {
    return switch (type) {
      QuizAchievementType.firstAnswer => _AchievementContent(
        title: isTurkish ? 'İlk Adım' : 'First Step',
        description:
            isTurkish
                ? 'İlk bilgi sorunu cevapla.'
                : 'Answer your first trivia question.',
        icon: Icons.flag_outlined,
      ),
      QuizAchievementType.curiousMind => _AchievementContent(
        title: isTurkish ? 'Meraklı Zihin' : 'Curious Mind',
        description:
            isTurkish
                ? '5 soruyu doğru cevapla.'
                : 'Answer 5 questions correctly.',
        icon: Icons.psychology_outlined,
      ),
      QuizAchievementType.onFire => _AchievementContent(
        title: isTurkish ? 'Alev Aldın' : 'On Fire',
        description:
            isTurkish
                ? '3 doğru cevaplık seri yap.'
                : 'Build a 3-answer streak.',
        icon: Icons.local_fire_department,
      ),
      QuizAchievementType.knowledgeHunter => _AchievementContent(
        title: isTurkish ? 'Bilgi Avcısı' : 'Knowledge Hunter',
        description:
            isTurkish ? 'Toplam 100 XP kazan.' : 'Earn a total of 100 XP.',
        icon: Icons.travel_explore,
      ),
      QuizAchievementType.triviaMaster => _AchievementContent(
        title: isTurkish ? 'Usta Bilgin' : 'Trivia Master',
        description:
            isTurkish
                ? '25 soruyu doğru cevapla.'
                : 'Answer 25 questions correctly.',
        icon: Icons.military_tech_outlined,
      ),
    };
  }
}

class _AchievementContent {
  const _AchievementContent({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

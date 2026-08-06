import 'package:flutter/material.dart';

import '../../application/quiz_controller.dart';
import '../../domain/entities/quiz_difficulty.dart';

class QuizDifficultySelectorCard extends StatelessWidget {
  const QuizDifficultySelectorCard({required this.controller, super.key});

  final QuizController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isTurkish = Localizations.localeOf(context).languageCode == 'tr';

        const difficulties = <QuizDifficulty>[
          QuizDifficulty.easy,
          QuizDifficulty.medium,
        ];

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed_rounded, size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isTurkish ? 'Soru zorluğu' : 'Question difficulty',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  isTurkish
                      ? 'Soruların zorluk seviyesini belirle.'
                      : 'Choose the difficulty level of the questions.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children:
                      difficulties.map((difficulty) {
                        final selected = controller.difficulty == difficulty;

                        return ChoiceChip(
                          selected: selected,
                          avatar: Icon(_iconFor(difficulty), size: 18),
                          label: Text(
                            _labelFor(difficulty, isTurkish: isTurkish),
                          ),
                          onSelected: (_) {
                            controller.selectDifficulty(difficulty);
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 17),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        isTurkish
                            ? 'Seçim bir sonraki sorudan itibaren uygulanır.'
                            : 'The selection applies to the next question.',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _labelFor(QuizDifficulty difficulty, {required bool isTurkish}) {
    return switch (difficulty) {
      QuizDifficulty.easy => isTurkish ? 'Kolay' : 'Easy',
      QuizDifficulty.medium => isTurkish ? 'Orta' : 'Medium',
      QuizDifficulty.hard => isTurkish ? 'Zor' : 'Hard',
    };
  }

  IconData _iconFor(QuizDifficulty difficulty) {
    return switch (difficulty) {
      QuizDifficulty.easy => Icons.sentiment_satisfied_alt,
      QuizDifficulty.medium => Icons.psychology_alt_outlined,
      QuizDifficulty.hard => Icons.local_fire_department_outlined,
    };
  }
}

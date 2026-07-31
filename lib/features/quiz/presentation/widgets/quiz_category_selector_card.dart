import 'package:flutter/material.dart';

import '../../application/quiz_controller.dart';
import '../../domain/entities/quiz_category.dart';

class QuizCategorySelectorCard extends StatelessWidget {
  const QuizCategorySelectorCard({
    required this.controller,
    super.key,
  });

  final QuizController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isTurkish =
            Localizations.localeOf(context).languageCode == 'tr';

        final categories = <QuizCategory?>[
          null,
          QuizCategory.geography,
          QuizCategory.science,
          QuizCategory.animals,
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
                    const Icon(
                      Icons.category_outlined,
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isTurkish
                            ? 'Soru kategorisi'
                            : 'Question category',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  isTurkish
                      ? 'Maskotun soracağı bilgi alanını seç.'
                      : 'Choose the topic your mascot will ask about.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: categories.map((category) {
                    final selected =
                        controller.preferredCategory == category;

                    return ChoiceChip(
                      selected: selected,
                      avatar: Icon(
                        _iconFor(category),
                        size: 18,
                      ),
                      label: Text(
                        _labelFor(
                          category,
                          isTurkish: isTurkish,
                        ),
                      ),
                      onSelected: (_) {
                        controller.selectCategory(category);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 17,
                    ),
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

  String _labelFor(
    QuizCategory? category, {
    required bool isTurkish,
  }) {
    return switch (category) {
      null => isTurkish ? 'Tümü' : 'All',
      QuizCategory.geography =>
        isTurkish ? 'Coğrafya' : 'Geography',
      QuizCategory.science =>
        isTurkish ? 'Bilim' : 'Science',
      QuizCategory.animals =>
        isTurkish ? 'Hayvanlar' : 'Animals',
      QuizCategory.history =>
        isTurkish ? 'Tarih' : 'History',
      QuizCategory.culture =>
        isTurkish ? 'Kültür' : 'Culture',
      QuizCategory.technology =>
        isTurkish ? 'Teknoloji' : 'Technology',
    };
  }

  IconData _iconFor(
    QuizCategory? category,
  ) {
    return switch (category) {
      null => Icons.apps,
      QuizCategory.geography => Icons.public,
      QuizCategory.science => Icons.science_outlined,
      QuizCategory.animals => Icons.pets_outlined,
      QuizCategory.history => Icons.history_edu_outlined,
      QuizCategory.culture => Icons.museum_outlined,
      QuizCategory.technology => Icons.memory_outlined,
    };
  }
}

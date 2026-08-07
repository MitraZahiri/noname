import 'package:flutter/material.dart';

import '../../application/companion_controller.dart';
import '../../domain/entities/companion_state.dart';

class CompanionHabitatCard extends StatelessWidget {
  const CompanionHabitatCard({required this.controller, super.key});

  final CompanionController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;
        final isTurkish = Localizations.localeOf(context).languageCode == 'tr';

        return Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _HabitatScene(state: state, isTurkish: isTurkish),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _HabitatHeader(state: state, isTurkish: isTurkish),
                    const SizedBox(height: 20),
                    _CompanionStats(state: state, isTurkish: isTurkish),
                    const SizedBox(height: 20),
                    _CompanionActions(
                      controller: controller,
                      isTurkish: isTurkish,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HabitatScene extends StatelessWidget {
  const _HabitatScene({required this.state, required this.isTurkish});

  final CompanionState state;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 230,
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
            top: 18,
            right: 22,
            child: Icon(
              Icons.wb_sunny_rounded,
              size: 42,
              color: colors.tertiary,
            ),
          ),
          Positioned(
            top: 30,
            left: 24,
            child: Icon(
              Icons.cloud_rounded,
              size: 48,
              color: colors.surface.withValues(alpha: 0.8),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 58,
            child: ColoredBox(color: colors.surfaceContainerHighest),
          ),
          Positioned(
            left: 24,
            bottom: 25,
            child: Column(
              children: [
                Icon(Icons.bed_rounded, size: 44, color: colors.primary),
                Text(
                  isTurkish ? 'Yatak' : 'Bed',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          Positioned(
            right: 24,
            bottom: 25,
            child: Column(
              children: [
                Icon(
                  Icons.sports_esports_rounded,
                  size: 40,
                  color: colors.secondary,
                ),
                Text(
                  isTurkish ? 'Oyuncak' : 'Toy',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 126,
              height: 126,
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _moodEmoji(state.mood),
                  style: const TextStyle(fontSize: 68),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _moodEmoji(CompanionMood mood) {
    return switch (mood) {
      CompanionMood.happy => '😊',
      CompanionMood.curious => '🤓',
      CompanionMood.hungry => '😋',
      CompanionMood.sleepy => '😴',
      CompanionMood.sad => '🥺',
    };
  }
}

class _HabitatHeader extends StatelessWidget {
  const _HabitatHeader({required this.state, required this.isTurkish});

  final CompanionState state;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        const Icon(Icons.home_rounded, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isTurkish ? 'Arkadaşının habitatı' : 'Your companion habitat',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 3),
              Text(
                _moodLabel(state.mood, isTurkish: isTurkish),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _stageLabel(state.stage, isTurkish: isTurkish),
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  String _moodLabel(CompanionMood mood, {required bool isTurkish}) {
    return switch (mood) {
      CompanionMood.happy =>
        isTurkish ? 'Mutlu ve neşeli' : 'Happy and cheerful',
      CompanionMood.curious =>
        isTurkish ? 'Yeni bilgiler öğrenmek istiyor' : 'Ready to learn',
      CompanionMood.hungry => isTurkish ? 'Biraz acıkmış' : 'Feeling hungry',
      CompanionMood.sleepy =>
        isTurkish ? 'Dinlenmeye ihtiyacı var' : 'Needs some rest',
      CompanionMood.sad =>
        isTurkish ? 'Biraz ilgi bekliyor' : 'Needs some attention',
    };
  }

  String _stageLabel(CompanionStage stage, {required bool isTurkish}) {
    return switch (stage) {
      CompanionStage.baby => isTurkish ? 'Bebek' : 'Baby',
      CompanionStage.child => isTurkish ? 'Çocuk' : 'Child',
      CompanionStage.explorer => isTurkish ? 'Kaşif' : 'Explorer',
      CompanionStage.scholar => isTurkish ? 'Bilgin' : 'Scholar',
    };
  }
}

class _CompanionStats extends StatelessWidget {
  const _CompanionStats({required this.state, required this.isTurkish});

  final CompanionState state;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatBar(
          icon: Icons.restaurant_rounded,
          label: isTurkish ? 'Tokluk' : 'Satiety',
          value: state.satiety,
        ),
        const SizedBox(height: 12),
        _StatBar(
          icon: Icons.favorite_rounded,
          label: isTurkish ? 'Mutluluk' : 'Happiness',
          value: state.happiness,
        ),
        const SizedBox(height: 12),
        _StatBar(
          icon: Icons.bolt_rounded,
          label: isTurkish ? 'Enerji' : 'Energy',
          value: state.energy,
        ),
        const SizedBox(height: 12),
        _StatBar(
          icon: Icons.school_rounded,
          label: isTurkish ? 'Bilgi' : 'Knowledge',
          value: state.knowledge.clamp(0, 100).toInt(),
        ),
      ],
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0, 100).toInt();

    return Row(
      children: [
        Icon(icon, size: 21),
        const SizedBox(width: 9),
        SizedBox(
          width: 78,
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: safeValue / 100,
            minHeight: 9,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 34,
          child: Text(
            '$safeValue',
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _CompanionActions extends StatelessWidget {
  const _CompanionActions({required this.controller, required this.isTurkish});

  final CompanionController controller;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: controller.feed,
            icon: const Icon(Icons.restaurant_rounded),
            label: Text(isTurkish ? 'Besle' : 'Feed'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: controller.play,
            icon: const Icon(Icons.toys_rounded),
            label: Text(isTurkish ? 'Oyna' : 'Play'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: controller.rest,
            icon: const Icon(Icons.bedtime_rounded),
            label: Text(isTurkish ? 'Dinlen' : 'Rest'),
          ),
        ),
      ],
    );
  }
}

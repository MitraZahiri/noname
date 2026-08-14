import 'package:flutter/material.dart';

import '../../application/companion_controller.dart';
import '../../domain/entities/companion_state.dart';

enum _HabitatAction { none, feeding, playing, resting }

class CompanionHabitatPage extends StatefulWidget {
  const CompanionHabitatPage({required this.controller, super.key});

  final CompanionController controller;

  @override
  State<CompanionHabitatPage> createState() => _CompanionHabitatPageState();
}

class _CompanionHabitatPageState extends State<CompanionHabitatPage> {
  _HabitatAction _action = _HabitatAction.none;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.refreshForElapsedTime();
    });
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

      await Future<void>.delayed(const Duration(milliseconds: 850));
    } finally {
      if (mounted) {
        setState(() {
          _action = _HabitatAction.none;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;
        final isTurkish = Localizations.localeOf(context).languageCode == 'tr';

        return Scaffold(
          appBar: AppBar(
            title: Text(
              isTurkish ? '${state.name} Habitatı' : '${state.name}\'s Habitat',
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
                  ),
                ),
                _StatsPanel(state: state, isTurkish: isTurkish),
              ],
            ),
          ),
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
                child: Chip(
                  label: Text(_moodText(state.mood, isTurkish: isTurkish)),
                ),
              ),

              Positioned(
                top: 24,
                right: 24,
                child: _StageBadge(stage: state.stage, isTurkish: isTurkish),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: constraints.maxHeight * 0.24,
                child: ColoredBox(color: colors.surfaceContainerHighest),
              ),

              Center(child: _CompanionCharacter(state: state, action: action)),

              Positioned(
                left: 18,
                bottom: 28,
                child: _RoomAction(
                  icon: Icons.restaurant_rounded,
                  label: isTurkish ? 'Besle' : 'Feed',
                  enabled: action == _HabitatAction.none,
                  onTap: () {
                    onAction(_HabitatAction.feeding, controller.feed);
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
                    onTap: () {
                      onAction(_HabitatAction.playing, controller.play);
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
                  onTap: () {
                    onAction(_HabitatAction.resting, controller.rest);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _moodText(CompanionMood mood, {required bool isTurkish}) {
    return switch (mood) {
      CompanionMood.happy => isTurkish ? 'Mutlu 😊' : 'Happy 😊',
      CompanionMood.curious => isTurkish ? 'Meraklı 🤓' : 'Curious 🤓',
      CompanionMood.hungry => isTurkish ? 'Acıktı 😋' : 'Hungry 😋',
      CompanionMood.sleepy => isTurkish ? 'Uykulu 😴' : 'Sleepy 😴',
      CompanionMood.sad => isTurkish ? 'Biraz üzgün 🥺' : 'A little sad 🥺',
    };
  }
}

class _CompanionCharacter extends StatelessWidget {
  const _CompanionCharacter({required this.state, required this.action});

  final CompanionState state;
  final _HabitatAction action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final scale = switch (action) {
      _HabitatAction.feeding => 1.12,
      _HabitatAction.playing => 1.08,
      _HabitatAction.resting => 0.88,
      _HabitatAction.none => 1.0,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: AnimatedRotation(
            turns: action == _HabitatAction.playing ? 0.04 : 0,
            duration: const Duration(milliseconds: 250),
            child: Container(
              width: 165,
              height: 165,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(_emoji(), style: const TextStyle(fontSize: 88)),
                  if (action == _HabitatAction.feeding)
                    const Positioned(
                      top: 4,
                      right: 4,
                      child: Text('🍎', style: TextStyle(fontSize: 32)),
                    ),
                  if (action == _HabitatAction.playing)
                    const Positioned(
                      top: 4,
                      right: 4,
                      child: Text('✨', style: TextStyle(fontSize: 32)),
                    ),
                  if (action == _HabitatAction.resting)
                    const Positioned(
                      top: 4,
                      right: 4,
                      child: Text('💤', style: TextStyle(fontSize: 32)),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          state.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _emoji() {
    return switch (action) {
      _HabitatAction.feeding => '😋',
      _HabitatAction.playing => '😄',
      _HabitatAction.resting => '😴',
      _HabitatAction.none => switch (state.mood) {
        CompanionMood.happy => '😊',
        CompanionMood.curious => '🤓',
        CompanionMood.hungry => '😋',
        CompanionMood.sleepy => '😴',
        CompanionMood.sad => '🥺',
      },
    };
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

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({required this.state, required this.isTurkish});

  final CompanionState state;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
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

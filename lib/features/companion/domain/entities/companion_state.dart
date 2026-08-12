enum CompanionMood { happy, curious, hungry, sleepy, sad }

enum CompanionStage { baby, child, explorer, scholar }

class CompanionState {
  const CompanionState({
    required this.name,
    required this.satiety,
    required this.happiness,
    required this.energy,
    required this.knowledge,
    required this.totalInteractions,
    required this.lastUpdatedAt,
  });

  factory CompanionState.initial() {
    return CompanionState(
      name: 'Mimo',
      satiety: 80,
      happiness: 80,
      energy: 80,
      knowledge: 0,
      totalInteractions: 0,
      lastUpdatedAt: DateTime.now(),
    );
  }

  final int satiety;
  final int happiness;
  final int energy;
  final int knowledge;
  final int totalInteractions;
  final DateTime lastUpdatedAt;
  final String name;

  CompanionMood get mood {
    if (satiety <= 25) {
      return CompanionMood.hungry;
    }

    if (energy <= 25) {
      return CompanionMood.sleepy;
    }

    if (happiness <= 25) {
      return CompanionMood.sad;
    }

    if (knowledge >= 60) {
      return CompanionMood.curious;
    }

    return CompanionMood.happy;
  }

  CompanionStage get stage {
    if (knowledge >= 500) {
      return CompanionStage.scholar;
    }

    if (knowledge >= 200) {
      return CompanionStage.explorer;
    }

    if (knowledge >= 50) {
      return CompanionStage.child;
    }

    return CompanionStage.baby;
  }

  CompanionState recordQuizAnswer({required bool isCorrect}) {
    return copyWith(
      happiness: _clamp(happiness + (isCorrect ? 5 : 1)),
      knowledge: knowledge + (isCorrect ? 10 : 2),
      energy: _clamp(energy - 2),
      totalInteractions: totalInteractions + 1,
      lastUpdatedAt: DateTime.now(),
    );
  }

  CompanionState feed() {
    return copyWith(
      satiety: _clamp(satiety + 25),
      happiness: _clamp(happiness + 3),
      totalInteractions: totalInteractions + 1,
      lastUpdatedAt: DateTime.now(),
    );
  }

  CompanionState play() {
    return copyWith(
      happiness: _clamp(happiness + 20),
      energy: _clamp(energy - 10),
      satiety: _clamp(satiety - 5),
      totalInteractions: totalInteractions + 1,
      lastUpdatedAt: DateTime.now(),
    );
  }

  CompanionState rest() {
    return copyWith(
      energy: _clamp(energy + 30),
      satiety: _clamp(satiety - 5),
      totalInteractions: totalInteractions + 1,
      lastUpdatedAt: DateTime.now(),
    );
  }

  CompanionState applyTimeDecay({required DateTime now}) {
    final elapsedHours = now.difference(lastUpdatedAt).inMinutes ~/ 60;

    if (elapsedHours <= 0) {
      return this;
    }

    return copyWith(
      satiety: _clamp(satiety - elapsedHours * 4),
      happiness: _clamp(happiness - elapsedHours * 2),
      energy: _clamp(energy - elapsedHours * 3),
      lastUpdatedAt: now,
    );
  }

  CompanionState copyWith({
    String? name,
    int? satiety,
    int? happiness,
    int? energy,
    int? knowledge,
    int? totalInteractions,
    DateTime? lastUpdatedAt,
  }) {
    return CompanionState(
      name: name ?? this.name,
      satiety: satiety ?? this.satiety,
      happiness: happiness ?? this.happiness,
      energy: energy ?? this.energy,
      knowledge: knowledge ?? this.knowledge,
      totalInteractions: totalInteractions ?? this.totalInteractions,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  static int _clamp(int value) {
    return value.clamp(0, 100).toInt();
  }
}

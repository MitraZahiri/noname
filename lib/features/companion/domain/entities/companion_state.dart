enum CompanionMood { happy, curious, hungry, sleepy, sad }

enum CompanionStage { baby, child, explorer, scholar }

enum CompanionNeed { none, food, happiness, rest, learning }

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

  final String name;
  final int satiety;
  final int happiness;
  final int energy;
  final int knowledge;
  final int totalInteractions;
  final DateTime lastUpdatedAt;

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

  CompanionNeed get primaryNeed {
    if (satiety <= 35) {
      return CompanionNeed.food;
    }

    if (energy <= 35) {
      return CompanionNeed.rest;
    }

    if (happiness <= 40) {
      return CompanionNeed.happiness;
    }

    if (knowledge < 50) {
      return CompanionNeed.learning;
    }

    return CompanionNeed.none;
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

  int get stageStartKnowledge {
    return switch (stage) {
      CompanionStage.baby => 0,
      CompanionStage.child => 50,
      CompanionStage.explorer => 200,
      CompanionStage.scholar => 500,
    };
  }

  int? get nextStageKnowledge {
    return switch (stage) {
      CompanionStage.baby => 50,
      CompanionStage.child => 200,
      CompanionStage.explorer => 500,
      CompanionStage.scholar => null,
    };
  }

  double get stageProgress {
    final nextKnowledge = nextStageKnowledge;

    if (nextKnowledge == null) {
      return 1.0;
    }

    final startKnowledge = stageStartKnowledge;

    final requiredKnowledge = nextKnowledge - startKnowledge;

    if (requiredKnowledge <= 0) {
      return 1.0;
    }

    final earnedKnowledge = knowledge - startKnowledge;

    return (earnedKnowledge / requiredKnowledge).clamp(0.0, 1.0);
  }

  CompanionState rename(String newName) {
    final trimmedName = newName.trim();

    if (trimmedName.isEmpty) {
      return this;
    }

    if (trimmedName == name) {
      return this;
    }

    return copyWith(name: trimmedName, lastUpdatedAt: DateTime.now());
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

  CompanionState pet() {
    return copyWith(
      happiness: _clamp(happiness + 5),
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

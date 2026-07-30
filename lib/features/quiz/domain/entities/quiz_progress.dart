class QuizProgress {
  const QuizProgress({
    required this.totalAnswered,
    required this.correctAnswers,
    required this.currentStreak,
    required this.bestStreak,
    required this.score,
  });

  const QuizProgress.empty()
    : totalAnswered = 0,
      correctAnswers = 0,
      currentStreak = 0,
      bestStreak = 0,
      score = 0;

  final int totalAnswered;
  final int correctAnswers;
  final int currentStreak;
  final int bestStreak;
  final int score;

  int get wrongAnswers {
    return totalAnswered - correctAnswers;
  }

  double get accuracy {
    if (totalAnswered == 0) {
      return 0;
    }

    return correctAnswers / totalAnswered;
  }

  int get accuracyPercentage {
    return (accuracy * 100).round();
  }

  QuizProgress recordAnswer({required bool isCorrect}) {
    if (!isCorrect) {
      return QuizProgress(
        totalAnswered: totalAnswered + 1,
        correctAnswers: correctAnswers,
        currentStreak: 0,
        bestStreak: bestStreak,
        score: score,
      );
    }

    final nextStreak = currentStreak + 1;

    final nextBestStreak = nextStreak > bestStreak ? nextStreak : bestStreak;

    final bonusLevel = nextStreak > 6 ? 5 : nextStreak - 1;
    final earnedPoints = 10 + bonusLevel * 2;

    return QuizProgress(
      totalAnswered: totalAnswered + 1,
      correctAnswers: correctAnswers + 1,
      currentStreak: nextStreak,
      bestStreak: nextBestStreak,
      score: score + earnedPoints,
    );
  }
}

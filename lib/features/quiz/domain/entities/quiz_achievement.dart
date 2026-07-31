import 'quiz_progress.dart';

enum QuizAchievementType {
  firstAnswer,
  curiousMind,
  onFire,
  knowledgeHunter,
  triviaMaster,
}

class QuizAchievement {
  const QuizAchievement({
    required this.type,
    required this.isUnlocked,
    required this.currentValue,
    required this.targetValue,
  });

  final QuizAchievementType type;
  final bool isUnlocked;
  final int currentValue;
  final int targetValue;

  double get progress {
    if (targetValue <= 0) {
      return 1;
    }

    return (currentValue / targetValue).clamp(0, 1);
  }

  static List<QuizAchievement> fromProgress(QuizProgress progress) {
    return [
      QuizAchievement(
        type: QuizAchievementType.firstAnswer,
        isUnlocked: progress.totalAnswered >= 1,
        currentValue: progress.totalAnswered,
        targetValue: 1,
      ),
      QuizAchievement(
        type: QuizAchievementType.curiousMind,
        isUnlocked: progress.correctAnswers >= 5,
        currentValue: progress.correctAnswers,
        targetValue: 5,
      ),
      QuizAchievement(
        type: QuizAchievementType.onFire,
        isUnlocked: progress.bestStreak >= 3,
        currentValue: progress.bestStreak,
        targetValue: 3,
      ),
      QuizAchievement(
        type: QuizAchievementType.knowledgeHunter,
        isUnlocked: progress.score >= 100,
        currentValue: progress.score,
        targetValue: 100,
      ),
      QuizAchievement(
        type: QuizAchievementType.triviaMaster,
        isUnlocked: progress.correctAnswers >= 25,
        currentValue: progress.correctAnswers,
        targetValue: 25,
      ),
    ];
  }
}

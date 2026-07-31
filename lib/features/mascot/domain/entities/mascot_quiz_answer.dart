class MascotQuizAnswer {
  const MascotQuizAnswer({
    required this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
  });

  final String questionId;
  final int selectedIndex;
  final bool isCorrect;

  factory MascotQuizAnswer.fromPlatformMap(Map<Object?, Object?> map) {
    final questionId = map['questionId'];
    final selectedIndex = map['selectedIndex'];
    final isCorrect = map['isCorrect'];

    if (questionId is! String) {
      throw const FormatException(
        'Quiz answer questionId is missing or invalid.',
      );
    }

    if (selectedIndex is! int) {
      throw const FormatException(
        'Quiz answer selectedIndex is missing or invalid.',
      );
    }

    if (isCorrect is! bool) {
      throw const FormatException(
        'Quiz answer isCorrect is missing or invalid.',
      );
    }

    return MascotQuizAnswer(
      questionId: questionId,
      selectedIndex: selectedIndex,
      isCorrect: isCorrect,
    );
  }
}

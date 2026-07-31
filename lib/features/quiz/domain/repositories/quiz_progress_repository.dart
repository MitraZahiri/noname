import '../entities/quiz_progress.dart';

abstract interface class QuizProgressRepository {
  Future<QuizProgress> load();

  Future<void> save(QuizProgress progress);

  Future<void> clear();
}

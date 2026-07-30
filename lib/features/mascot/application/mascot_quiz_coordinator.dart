import 'dart:async';

import '../../quiz/application/quiz_controller.dart';
import '../domain/entities/mascot_quiz_answer.dart';
import '../data/services/mascot_overlay_platform_service.dart';
import 'mascot_controller.dart';

class MascotQuizCoordinator {
  MascotQuizCoordinator({
    required QuizController quizController,
    required MascotController mascotController,
    required MascotOverlayPlatformService platformService,
  }) : _quizController = quizController,
       _mascotController = mascotController,
       _platformService = platformService;

  final QuizController _quizController;
  final MascotController _mascotController;
  final MascotOverlayPlatformService _platformService;

  StreamSubscription<MascotQuizAnswer>? _answerSubscription;

  String _localeCode = 'en';

  void initialize() {
    _answerSubscription ??= _platformService.quizAnswers.listen(
      _handleQuizAnswer,
    );
  }

  Future<void> startMascot({required String localeCode}) async {
    _localeCode = localeCode;

    await _sendNextQuestion();
    await _mascotController.startMascot();
  }

  Future<void> showMascotNow({required String localeCode}) async {
    _localeCode = localeCode;

    await _sendNextQuestion();
    await _mascotController.showMascotNow();
  }

  Future<void> _handleQuizAnswer(MascotQuizAnswer answer) async {
    final activeQuestion = _quizController.activeQuestion;

    if (activeQuestion == null) {
      return;
    }

    if (activeQuestion.id != answer.questionId) {
      return;
    }

    _quizController.recordAnswer(selectedIndex: answer.selectedIndex);

    await _sendNextQuestion();
  }

  Future<void> _sendNextQuestion() async {
    final question = _quizController.prepareNextQuestion(
      localeCode: _localeCode,
    );

    await _platformService.setQuizQuestion(question.toPlatformMap());
  }

  Future<void> dispose() async {
    await _answerSubscription?.cancel();
    _answerSubscription = null;
  }
}

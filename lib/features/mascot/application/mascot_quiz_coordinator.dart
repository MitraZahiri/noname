import 'dart:async';

import '../../quiz/application/quiz_controller.dart';
import '../data/services/mascot_overlay_platform_service.dart';
import '../domain/entities/mascot_quiz_answer.dart';
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

  StreamSubscription<void>? _nextQuestionSubscription;

  StreamSubscription<void>? _mascotDismissedSubscription;

  String _localeCode = 'en';

  void initialize() {
    _answerSubscription ??= _platformService.quizAnswers.listen(
      _handleQuizAnswer,
    );

    _nextQuestionSubscription ??= _platformService.nextQuestionRequests.listen((
      _,
    ) async {
      await _sendNextQuestion();
    });

    _mascotDismissedSubscription ??= _platformService.mascotDismissed.listen((
      _,
    ) async {
      await _mascotController.stopMascot();
    });
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

    // Yeni soru burada gönderilmiyor.
    // Kullanıcı "Evet" derse gönderilecek.
  }

  Future<void> _sendNextQuestion() async {
    final question = _quizController.prepareNextQuestion(
      localeCode: _localeCode,
    );

    await _platformService.setQuizQuestion(question.toPlatformMap());
  }

  Future<void> dispose() async {
    await _answerSubscription?.cancel();
    await _nextQuestionSubscription?.cancel();
    await _mascotDismissedSubscription?.cancel();

    _answerSubscription = null;
    _nextQuestionSubscription = null;
    _mascotDismissedSubscription = null;
  }
}

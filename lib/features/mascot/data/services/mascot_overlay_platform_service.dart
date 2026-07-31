import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/mascot_quiz_answer.dart';

class MascotOverlayPlatformService {
  MascotOverlayPlatformService() {
    _channel.setMethodCallHandler(_handleNativeMethodCall);
  }

  static const MethodChannel _channel = MethodChannel('noname/overlay');

  final StreamController<MascotQuizAnswer> _quizAnswersController =
      StreamController<MascotQuizAnswer>.broadcast();

  final StreamController<void> _nextQuestionRequestsController =
      StreamController<void>.broadcast();

  final StreamController<void> _mascotDismissedController =
      StreamController<void>.broadcast();

  Stream<MascotQuizAnswer> get quizAnswers {
    return _quizAnswersController.stream;
  }

  Stream<void> get nextQuestionRequests {
    return _nextQuestionRequestsController.stream;
  }

  Stream<void> get mascotDismissed {
    return _mascotDismissedController.stream;
  }

  bool get isSupported {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  Future<bool> hasPermission() async {
    if (!isSupported) {
      return false;
    }

    return await _channel.invokeMethod<bool>('hasOverlayPermission') ?? false;
  }

  Future<void> requestPermission() async {
    if (!isSupported) {
      return;
    }

    await _channel.invokeMethod<void>('requestOverlayPermission');
  }

  Future<bool> setQuizQuestion(Map<String, Object> question) async {
    if (!isSupported) {
      return false;
    }

    return await _channel.invokeMethod<bool>('setQuizQuestion', question) ??
        false;
  }

  Future<bool> startMascot() async {
    if (!isSupported) {
      return false;
    }

    return await _channel.invokeMethod<bool>('startMascotOverlay') ?? false;
  }

  Future<bool> stopMascot() async {
    if (!isSupported) {
      return false;
    }

    return await _channel.invokeMethod<bool>('stopMascotOverlay') ?? false;
  }

  Future<bool> showMascot() async {
    if (!isSupported) {
      return false;
    }

    return await _channel.invokeMethod<bool>('showMascotOverlay') ?? false;
  }

  Future<bool> isMascotRunning() async {
    if (!isSupported) {
      return false;
    }

    return await _channel.invokeMethod<bool>('isMascotOverlayRunning') ?? false;
  }

  Future<Object?> _handleNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'quizAnswered':
        final arguments = call.arguments;

        if (arguments is Map) {
          final answer = MascotQuizAnswer.fromPlatformMap(
            Map<Object?, Object?>.from(arguments),
          );

          _quizAnswersController.add(answer);
        }

        return null;

      case 'nextQuestionRequested':
        _nextQuestionRequestsController.add(null);

        return null;

      case 'mascotDismissed':
        _mascotDismissedController.add(null);

        return null;

      default:
        throw MissingPluginException('Unknown native method: ${call.method}');
    }
  }

  Future<void> dispose() async {
    _channel.setMethodCallHandler(null);

    await _quizAnswersController.close();
    await _nextQuestionRequestsController.close();
    await _mascotDismissedController.close();
  }
}

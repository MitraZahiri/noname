import 'package:flutter/foundation.dart';

import '../domain/entities/companion_state.dart';
import '../domain/repositories/companion_repository.dart';

class CompanionController extends ChangeNotifier {
  CompanionController({
    required CompanionRepository repository,
    CompanionState? initialState,
  }) : _repository = repository,
       _state =
           initialState ?? CompanionState.initial();

  final CompanionRepository _repository;

  CompanionState _state;

  bool _isInitialized = false;

  CompanionState get state => _state;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      final storedState =
          await _repository.load();

      _state =
          (storedState ?? _state).applyTimeDecay(
            now: DateTime.now(),
          );
    } catch (error, stackTrace) {
      debugPrint(
        'Companion state could not be loaded: '
        '$error\n$stackTrace',
      );
    }

    _isInitialized = true;
    notifyListeners();

    await _saveState();
  }

  Future<void> feed() async {
    await _applyState(
      _state.feed(),
    );
  }

  Future<void> play() async {
    await _applyState(
      _state.play(),
    );
  }

  Future<void> rest() async {
    await _applyState(
      _state.rest(),
    );
  }

  Future<void> recordQuizAnswer({
    required bool isCorrect,
  }) async {
    await _applyState(
      _state.recordQuizAnswer(
        isCorrect: isCorrect,
      ),
    );
  }

  Future<void> refreshForElapsedTime() async {
    final updatedState =
        _state.applyTimeDecay(
          now: DateTime.now(),
        );

    if (identical(updatedState, _state)) {
      return;
    }

    await _applyState(updatedState);
  }

  Future<void> reset() async {
    _state = CompanionState.initial();
    notifyListeners();

    try {
      await _repository.clear();
    } catch (error, stackTrace) {
      debugPrint(
        'Companion state could not be cleared: '
        '$error\n$stackTrace',
      );
    }
  }

  Future<void> _applyState(
    CompanionState nextState,
  ) async {
    _state = nextState;
    notifyListeners();

    await _saveState();
  }

  Future<void> _saveState() async {
    try {
      await _repository.save(_state);
    } catch (error, stackTrace) {
      debugPrint(
        'Companion state could not be saved: '
        '$error\n$stackTrace',
      );
    }
  }
}

import 'package:flutter/foundation.dart';

import '../domain/entities/companion_state.dart';
import '../domain/repositories/companion_repository.dart';

class CompanionController extends ChangeNotifier {
  CompanionController({required CompanionRepository repository})
    : _repository = repository;

  final CompanionRepository _repository;

  CompanionState _state = CompanionState.initial();

  bool _isInitialized = false;

  CompanionState get state => _state;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    final storedState = await _repository.load();

    final initialState = storedState ?? CompanionState.initial();

    _state = initialState.applyTimeDecay(now: DateTime.now());

    _isInitialized = true;

    notifyListeners();

    await _saveState();
  }

  Future<void> rename(String name) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty || trimmedName == _state.name) {
      return;
    }

    await _applyState(_state.rename(trimmedName));
  }

  Future<void> recordQuizAnswer({required bool isCorrect}) async {
    await _applyState(_state.recordQuizAnswer(isCorrect: isCorrect));
  }

  Future<void> feed() async {
    await _applyState(_state.feed());
  }

  Future<void> play() async {
    await _applyState(_state.play());
  }

  Future<void> rest() async {
    await _applyState(_state.rest());
  }

  Future<void> pet() async {
    await _applyState(_state.pet());
  }

  Future<void> refreshForElapsedTime() async {
    final updatedState = _state.applyTimeDecay(now: DateTime.now());

    if (identical(updatedState, _state)) {
      return;
    }

    await _applyState(updatedState);
  }

  Future<void> reset() async {
    await _repository.clear();

    _state = CompanionState.initial();

    notifyListeners();

    await _saveState();
  }

  Future<void> _applyState(CompanionState newState) async {
    _state = newState;

    notifyListeners();

    await _saveState();
  }

  Future<void> _saveState() async {
    try {
      await _repository.save(_state);
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to save companion state: '
        '$error\n$stackTrace',
      );
    }
  }
}

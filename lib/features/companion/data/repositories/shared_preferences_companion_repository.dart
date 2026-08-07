import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/companion_state.dart';
import '../../domain/repositories/companion_repository.dart';

class SharedPreferencesCompanionRepository
    implements CompanionRepository {
  SharedPreferencesCompanionRepository({
    SharedPreferencesAsync? preferences,
  }) : _preferences =
           preferences ?? SharedPreferencesAsync();

  static const String _satietyKey =
      'companion_satiety';

  static const String _happinessKey =
      'companion_happiness';

  static const String _energyKey =
      'companion_energy';

  static const String _knowledgeKey =
      'companion_knowledge';

  static const String _interactionsKey =
      'companion_total_interactions';

  static const String _lastUpdatedAtKey =
      'companion_last_updated_at';

  final SharedPreferencesAsync _preferences;

  @override
  Future<CompanionState?> load() async {
    final satiety =
        await _preferences.getInt(_satietyKey);

    if (satiety == null) {
      return null;
    }

    final happiness =
        await _preferences.getInt(_happinessKey);

    final energy =
        await _preferences.getInt(_energyKey);

    final knowledge =
        await _preferences.getInt(_knowledgeKey);

    final interactions =
        await _preferences.getInt(_interactionsKey);

    final lastUpdatedAtMilliseconds =
        await _preferences.getInt(
          _lastUpdatedAtKey,
        );

    return CompanionState(
      satiety: _percent(satiety),
      happiness: _percent(happiness ?? 80),
      energy: _percent(energy ?? 80),
      knowledge: max(0, knowledge ?? 0),
      totalInteractions:
          max(0, interactions ?? 0),
      lastUpdatedAt:
          lastUpdatedAtMilliseconds == null
              ? DateTime.now()
              : DateTime.fromMillisecondsSinceEpoch(
                lastUpdatedAtMilliseconds,
              ),
    );
  }

  @override
  Future<void> save(
    CompanionState state,
  ) async {
    await Future.wait<void>([
      _preferences.setInt(
        _satietyKey,
        state.satiety,
      ),
      _preferences.setInt(
        _happinessKey,
        state.happiness,
      ),
      _preferences.setInt(
        _energyKey,
        state.energy,
      ),
      _preferences.setInt(
        _knowledgeKey,
        state.knowledge,
      ),
      _preferences.setInt(
        _interactionsKey,
        state.totalInteractions,
      ),
      _preferences.setInt(
        _lastUpdatedAtKey,
        state.lastUpdatedAt
            .millisecondsSinceEpoch,
      ),
    ]);
  }

  @override
  Future<void> clear() async {
    await Future.wait<void>([
      _preferences.remove(_satietyKey),
      _preferences.remove(_happinessKey),
      _preferences.remove(_energyKey),
      _preferences.remove(_knowledgeKey),
      _preferences.remove(_interactionsKey),
      _preferences.remove(_lastUpdatedAtKey),
    ]);
  }

  int _percent(int value) {
    return value.clamp(0, 100).toInt();
  }
}

import '../entities/companion_state.dart';

abstract interface class CompanionRepository {
  Future<CompanionState?> load();

  Future<void> save(
    CompanionState state,
  );

  Future<void> clear();
}

import '../../../core/utils/random_generator.dart';
import '../../location/entities/location.dart';
import '../entities/scenario.dart';

/// Service for determining when scenarios trigger.
class ScenarioTriggerService {
  final RandomGenerator _random;

  ScenarioTriggerService({required RandomGenerator random}) : _random = random;

  /// Roll for a scenario trigger.
  ///
  /// Returns the first scenario that passes its probability roll, or null
  /// if no scenario triggers. Filters by location, heat, and cooldown.
  ///
  /// - [location]: Current location type
  /// - [heat]: Current global heat level
  /// - [playerDrugCount]: Number of drugs the player is carrying
  /// - [recentlyTriggered]: Set of scenario IDs in cooldown (3-turn minimum)
  Scenario? rollForScenario({
    required LocationType location,
    required int heat,
    required int playerDrugCount,
    required Set<String> recentlyTriggered,
  }) {
    // Get all scenarios that can trigger at this location
    final candidates = DefaultScenarios.all
        .where((scenario) =>
            scenario.canTriggerAt(location) &&
            scenario.minHeatToTrigger <= heat &&
            !recentlyTriggered.contains(scenario.id))
        .toList();

    if (candidates.isEmpty) return null;

    // Roll for each candidate in order
    for (final scenario in candidates) {
      // Calculate effective probability based on heat
      final baseProbability = scenario.baseProbability;
      final heatMultiplier = 1 + (heat / 100) * 0.5;
      final effectiveProbability = baseProbability * heatMultiplier;

      // Cap at 1.0
      final cappedProbability = effectiveProbability > 1.0 ? 1.0 : effectiveProbability;

      // Roll the dice
      if (_random.nextDouble() < cappedProbability) {
        return scenario;
      }
    }

    return null;
  }
}

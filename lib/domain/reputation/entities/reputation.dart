import 'package:equatable/equatable.dart';

import '../../agency/entities/agency.dart';

/// Player's global reputation and heat tracking.
class PlayerReputation extends Equatable {
  /// Global reputation score (0-100).
  /// Increases: Successful deals, beating cops, expanding territory.
  /// Decreases: Losses in combat, getting caught, backing down.
  final int reputation;

  /// Global heat level (0-100).
  /// Increases: Police encounters, large deals, killed cops.
  /// Decreases: Laying low, paying fixer, time passing.
  final int globalHeat;

  /// Wanted level per agency (0-100).
  final Map<AgencyType, int> agencyWantedLevels;

  const PlayerReputation({
    this.reputation = 0,
    this.globalHeat = 0,
    this.agencyWantedLevels = const {},
  });

  /// Get wanted level for a specific agency.
  int getWantedLevel(AgencyType agency) =>
      agencyWantedLevels[agency] ?? 0;

  /// Whether the player is wanted by Interpol (global hunt).
  bool get isWantedByInterpol =>
      getWantedLevel(AgencyType.interpol) > 50;

  /// Get the highest wanted level across all agencies.
  int get maxWantedLevel => agencyWantedLevels.isEmpty
      ? 0
      : agencyWantedLevels.values.reduce((a, b) => a > b ? a : b);

  PlayerReputation copyWith({
    int? reputation,
    int? globalHeat,
    Map<AgencyType, int>? agencyWantedLevels,
  }) {
    return PlayerReputation(
      reputation: reputation ?? this.reputation,
      globalHeat: globalHeat ?? this.globalHeat,
      agencyWantedLevels: agencyWantedLevels ?? this.agencyWantedLevels,
    );
  }

  /// Increase reputation, clamped to 0-100.
  PlayerReputation addReputation(int amount) {
    return copyWith(reputation: (reputation + amount).clamp(0, 100));
  }

  /// Increase global heat, clamped to 0-100.
  PlayerReputation addHeat(int amount) {
    return copyWith(globalHeat: (globalHeat + amount).clamp(0, 100));
  }

  /// Increase wanted level for a specific agency, clamped to 0-100.
  PlayerReputation addWantedLevel(AgencyType agency, int amount) {
    final updated = Map<AgencyType, int>.from(agencyWantedLevels);
    final current = updated[agency] ?? 0;
    updated[agency] = (current + amount).clamp(0, 100);
    return copyWith(agencyWantedLevels: updated);
  }

  /// Apply per-turn heat decay.
  PlayerReputation applyHeatDecay({int decayAmount = 2}) {
    final newHeat = (globalHeat - decayAmount).clamp(0, 100);

    // Decay agency wanted levels too (slower)
    final updatedWanted = Map<AgencyType, int>.from(agencyWantedLevels);
    for (final entry in updatedWanted.entries) {
      updatedWanted[entry.key] = (entry.value - 1).clamp(0, 100);
    }
    // Remove zero entries
    updatedWanted.removeWhere((_, v) => v == 0);

    return copyWith(
      globalHeat: newHeat,
      agencyWantedLevels: updatedWanted,
    );
  }

  @override
  List<Object?> get props => [reputation, globalHeat, agencyWantedLevels];

  @override
  String toString() =>
      'PlayerReputation(rep: $reputation, heat: $globalHeat, wanted: $agencyWantedLevels)';
}

part of 'game_state_cubit.dart';

/// Overall game state accessible by all cubits in the widget tree.
///
/// This is the single source of truth for cross-cutting game state
/// that multiple cubits need to read/react to.
class GameStateState extends Equatable {
  /// Player reputation, heat, and wanted levels.
  final PlayerReputation reputation;

  /// Supply/demand state across all locations.
  final MarketSupplyState marketSupply;

  /// NPC relationship states, keyed by NPC id.
  final Map<String, NpcRelationship> npcRelationships;

  /// Currently active scenario (if any).
  final Scenario? activeScenario;

  /// Active contracts/missions.
  final List<Contract> activeContracts;

  /// World alerts/notifications.
  final List<String> alerts;

  /// Set of scenario IDs in cooldown (cannot trigger for N turns).
  final Set<String> recentlyTriggeredScenarios;

  const GameStateState({
    this.reputation = const PlayerReputation(),
    this.marketSupply = const MarketSupplyState(),
    this.npcRelationships = const {},
    this.activeScenario,
    this.activeContracts = const [],
    this.alerts = const [],
    this.recentlyTriggeredScenarios = const {},
  });

  GameStateState copyWith({
    PlayerReputation? reputation,
    MarketSupplyState? marketSupply,
    Map<String, NpcRelationship>? npcRelationships,
    Scenario? activeScenario,
    bool clearActiveScenario = false,
    List<Contract>? activeContracts,
    List<String>? alerts,
    Set<String>? recentlyTriggeredScenarios,
  }) {
    return GameStateState(
      reputation: reputation ?? this.reputation,
      marketSupply: marketSupply ?? this.marketSupply,
      npcRelationships: npcRelationships ?? this.npcRelationships,
      activeScenario:
          clearActiveScenario ? null : (activeScenario ?? this.activeScenario),
      activeContracts: activeContracts ?? this.activeContracts,
      alerts: alerts ?? this.alerts,
      recentlyTriggeredScenarios:
          recentlyTriggeredScenarios ?? this.recentlyTriggeredScenarios,
    );
  }

  @override
  List<Object?> get props => [
        reputation,
        marketSupply,
        npcRelationships,
        activeScenario,
        activeContracts,
        alerts,
        recentlyTriggeredScenarios,
      ];
}

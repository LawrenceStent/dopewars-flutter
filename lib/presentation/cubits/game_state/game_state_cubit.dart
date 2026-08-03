import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/agency/entities/agency.dart';
import '../../../domain/contract/entities/contract.dart';
import '../../../domain/location/entities/location.dart';
import '../../../domain/location/entities/supply_demand.dart';
import '../../../domain/npc/entities/npc.dart';
import '../../../domain/reputation/entities/reputation.dart';
import '../../../domain/scenario/entities/scenario.dart';
import '../../../domain/trading/entities/drug.dart';

part 'game_state_state.dart';

/// Top-level cubit that owns the overall game state.
///
/// All cubits lower in the widget tree can access this state.
/// This is the single source of truth for:
/// - Player reputation & heat
/// - Market supply/demand
/// - NPC relationships
/// - Active scenarios & contracts
/// - World state (market events, agency alerts)
class GameStateCubit extends Cubit<GameStateState> {
  GameStateCubit() : super(const GameStateState());

  /// Initialize state for a new game.
  void initializeGame() {
    emit(const GameStateState());
  }

  // --- Reputation & Heat ---

  void addReputation(int amount) {
    emit(state.copyWith(
      reputation: state.reputation.addReputation(amount),
    ));
  }

  void addHeat(int amount) {
    emit(state.copyWith(
      reputation: state.reputation.addHeat(amount),
    ));
  }

  void reduceHeat(int amount) {
    emit(state.copyWith(
      reputation: state.reputation.addHeat(-amount),
    ));
  }

  void addWantedLevel(AgencyType agency, int amount) {
    emit(state.copyWith(
      reputation: state.reputation.addWantedLevel(agency, amount),
    ));
  }

  // --- Supply & Demand ---

  void onDrugBought(LocationType location, DrugType drug, int quantity) {
    emit(state.copyWith(
      marketSupply: state.marketSupply.onBuy(location, drug, quantity),
    ));
  }

  void onDrugSold(LocationType location, DrugType drug, int quantity) {
    emit(state.copyWith(
      marketSupply: state.marketSupply.onSell(location, drug, quantity),
    ));
  }

  // --- NPC Relationships ---

  void updateNpcRelationship(String npcId, NpcRelationship relationship) {
    final updated = Map<String, NpcRelationship>.from(state.npcRelationships);
    updated[npcId] = relationship;
    emit(state.copyWith(npcRelationships: updated));
  }

  // --- Turn Processing ---

  /// Called at the end of each turn. Applies decay, recovery, etc.
  void processTurnEnd() {
    emit(state.copyWith(
      reputation: state.reputation.applyHeatDecay(),
      marketSupply: state.marketSupply.applyRecovery(),
    ));
  }

  // --- Active Scenario ---

  void setActiveScenario(Scenario? scenario) {
    emit(state.copyWith(activeScenario: scenario));
  }

  void clearActiveScenario() {
    emit(state.copyWith(clearActiveScenario: true));
  }

  /// Mark a scenario as recently triggered (adds to cooldown set).
  /// The cooldown duration is tracked externally via turn counting.
  void markScenarioTriggered(String scenarioId, int cooldownTurns) {
    final updated = Set<String>.from(state.recentlyTriggeredScenarios);
    updated.add(scenarioId);
    emit(state.copyWith(recentlyTriggeredScenarios: updated));
  }

  // --- Contracts ---

  void addContract(Contract contract) {
    emit(state.copyWith(
      activeContracts: [...state.activeContracts, contract],
    ));
  }

  void updateContract(Contract updated) {
    final contracts = state.activeContracts
        .map((c) => c.id == updated.id ? updated : c)
        .toList();
    emit(state.copyWith(activeContracts: contracts));
  }

  void removeContract(String contractId) {
    emit(state.copyWith(
      activeContracts:
          state.activeContracts.where((c) => c.id != contractId).toList(),
    ));
  }

  // --- World Alerts ---

  void addAlert(String alert) {
    emit(state.copyWith(alerts: [...state.alerts, alert]));
  }

  void clearAlerts() {
    emit(state.copyWith(alerts: []));
  }
}

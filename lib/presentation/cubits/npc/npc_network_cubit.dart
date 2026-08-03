import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/location/entities/location.dart';
import '../../../domain/npc/entities/npc.dart';
import '../../../domain/npc/repositories/npc_repository.dart';

part 'npc_network_state.dart';

/// Manages NPC trading relationships and network.
///
/// Responsible for:
/// - Tracking NPC relationships (reputation, supply, availability)
/// - Applying turn-end effects (decay, cooldowns)
/// - Calculating NPC prices with reputation bonuses
/// - Recording trades and updating relationships
/// - Determining bust chances and consequences
///
/// This cubit is separate from [GameStateCubit] to isolate NPC-specific
/// logic and allow independent testing.
class NpcNetworkCubit extends Cubit<NpcNetworkState> {
  final NpcRepository _npcRepository;

  NpcNetworkCubit({required NpcRepository npcRepository})
      : _npcRepository = npcRepository,
        super(const NpcNetworkState());

  /// Initialize network from persisted game data.
  ///
  /// Called when loading a saved game.
  void loadFromGameSession(Map<String, NpcRelationship> relationships) {
    emit(state.copyWith(relationships: Map.from(relationships)));
  }

  /// Initialize empty network for new game.
  void initializeForNewGame() {
    emit(const NpcNetworkState(relationships: {}));
  }

  /// Get or create relationship with an NPC (first encounter).
  NpcRelationship getOrCreateRelationship(String npcId) {
    if (state.relationships.containsKey(npcId)) {
      return state.relationships[npcId]!;
    }

    final rel = _npcRepository.getOrCreateRelationship(npcId, state.relationships);
    _updateRelationship(npcId, rel);
    return rel;
  }

  /// Record a successful trade with an NPC.
  ///
  /// Updates reputation, supply usage, and trade history.
  void recordTrade({
    required String npcId,
    required int tradeValue,
    required int currentTurn,
    required int quantityTraded,
  }) {
    final current = getOrCreateRelationship(npcId);
    final npc = _npcRepository.getNpcById(npcId);
    if (npc == null) return;

    // Record trade in relationship
    var updated = current.recordTrade(tradeValue, currentTurn);

    // Use supply if supplier
    if (npc.role == NpcRole.supplier) {
      updated = updated.useSupply(quantityTraded);
    }

    // Small reputation boost for trading
    updated = updated.addReputation(5);

    _updateRelationship(npcId, updated);
  }

  /// Apply turn-end effects to all NPC relationships.
  ///
  /// Called at the end of each turn to:
  /// - Decay supply for suppliers
  /// - Decrement unavailability timers
  /// - Decay reputation for inactive NPCs
  void applyTurnEffects() {
    emit(state.copyWith(isLocked: true));

    try {
      final updated = _npcRepository.applyTurnEffects(state.relationships);
      emit(state.copyWith(
        relationships: updated,
        isLocked: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to apply NPC turn effects: $e',
        isLocked: false,
      ));
    }
  }

  /// Mark NPC as busted (arrested during trade).
  ///
  /// NPC becomes unavailable for N turns and reputation takes a hit.
  void markNpcBusted(String npcId, int unavailableTurns) {
    final current = state.relationships[npcId];
    if (current == null) return;

    final busted = _npcRepository.markNpcBusted(current, unavailableTurns);
    _updateRelationship(npcId, busted);
  }

  /// Calculate the price for buying/selling with an NPC.
  ///
  /// Returns null if NPC not found or relationship not initialized.
  double? calculatePrice(
    double basePrice,
    String npcId,
  ) {
    final npc = _npcRepository.getNpcById(npcId);
    final rel = state.relationships[npcId];

    if (npc == null || rel == null) return null;

    return _npcRepository.calculateNpcPrice(basePrice, npc, rel);
  }

  /// Check if NPC can be traded with right now.
  bool canTradeWithNpc(String npcId) {
    final rel = state.relationships[npcId];
    if (rel == null) return false;
    return _npcRepository.canTrade(rel);
  }

  /// Get reason why NPC cannot be traded with (if applicable).
  String? getUnavailableReason(String npcId) {
    final rel = state.relationships[npcId];
    if (rel == null) return 'Not yet encountered';
    return _npcRepository.getUnavailableReason(rel);
  }

  /// Get all NPCs available at a location.
  ///
  /// Filters by:
  /// - Location
  /// - Current tradeable status (not busted)
  List<Npc> getNpcsAtLocation(
    LocationType location, {
    bool onlyTradeable = false,
  }) {
    final npcs = _npcRepository.getNpcsAtLocation(location);

    if (!onlyTradeable) return npcs;

    return npcs
        .where((npc) => canTradeWithNpc(npc.id) || !state.hasMetNpc(npc.id))
        .toList();
  }

  /// Get relationship status as human-readable string.
  ///
  /// Returns: "Stranger", "Regular", "Friend", or "Trusted"
  String getRelationshipStatus(String npcId) {
    final rel = state.relationships[npcId];
    if (rel == null) return 'Unknown';
    return _npcRepository.getRelationshipStatus(rel);
  }

  /// Get trust level as star count (0-5).
  int getTrustLevel(String npcId) {
    final rel = state.relationships[npcId];
    if (rel == null) return 0;
    return _npcRepository.getTrustLevel(rel);
  }

  /// Internal helper to update a relationship and emit new state.
  void _updateRelationship(String npcId, NpcRelationship relationship) {
    final updated = Map<String, NpcRelationship>.from(state.relationships);
    updated[npcId] = relationship;
    emit(state.copyWith(relationships: updated, error: null));
  }
}

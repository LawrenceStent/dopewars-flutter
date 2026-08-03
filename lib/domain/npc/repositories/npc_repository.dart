import '../../location/entities/location.dart';
import '../entities/npc.dart';

/// Repository for managing NPC data and relationships.
///
/// Provides methods to:
/// - Get NPC templates
/// - Query NPC relationships
/// - Update NPC relationships
class NpcRepository {
  const NpcRepository();

  /// Get all available NPCs.
  List<Npc> getAllNpcs() {
    return DefaultNpcs.all;
  }

  /// Get NPC by ID.
  Npc? getNpcById(String id) {
    return DefaultNpcs.byId(id);
  }

  /// Get all NPCs at a specific location.
  List<Npc> getNpcsAtLocation(LocationType location) {
    return DefaultNpcs.atLocation(location);
  }

  /// Initialize relationship for new NPC (first encounter).
  NpcRelationship initializeRelationship(String npcId, Npc npc) {
    return NpcRelationship(
      npcId: npcId,
      currentSupply: npc.initialSupplyPerTurn,
      reputation: 0,
      isActive: true,
    );
  }

  /// Get or create a relationship for an NPC.
  NpcRelationship getOrCreateRelationship(
    String npcId,
    Map<String, NpcRelationship> existing,
  ) {
    if (existing.containsKey(npcId)) {
      return existing[npcId]!;
    }

    final npc = getNpcById(npcId);
    if (npc == null) {
      throw Exception('NPC not found: $npcId');
    }

    return initializeRelationship(npcId, npc);
  }

  /// Check if NPC can be traded with.
  bool canTrade(NpcRelationship relationship) {
    return relationship.canTrade;
  }

  /// Get reason why NPC cannot be traded with (if applicable).
  String? getUnavailableReason(NpcRelationship relationship) {
    if (relationship.turnsUnavailable > 0) {
      return 'Not available for ${relationship.turnsUnavailable} more turns';
    }
    if (!relationship.isActive) {
      return 'Not available (busted)';
    }
    return null;
  }

  /// Calculate price with NPC reputation bonus applied.
  ///
  /// Formula: basePrice * npcMultiplier * (1 - reputationBonus)
  /// Reputation bonus increases with relationship level.
  double calculateNpcPrice(
    double basePrice,
    Npc npc,
    NpcRelationship relationship,
  ) {
    // Base price with NPC multiplier
    var price = basePrice * npc.basePriceModifier;

    // Apply reputation bonus (better prices with higher reputation)
    // Max -30% discount for suppliers at reputation 100
    final reputationBonusPercent = (relationship.reputation / 100) * 0.3;
    price *= (1 - reputationBonusPercent);

    return price;
  }

  /// Apply turn-end effects to all NPC relationships.
  ///
  /// Called after each turn to:
  /// - Decay supply
  /// - Decrement unavailability timers
  /// - Decay reputation for inactive NPCs
  Map<String, NpcRelationship> applyTurnEffects(
    Map<String, NpcRelationship> relationships,
  ) {
    final updated = <String, NpcRelationship>{};

    for (final entry in relationships.entries) {
      var rel = entry.value;
      final npc = getNpcById(entry.key);

      // Decay supply if it's a supplier (only if template exists)
      if (npc != null && npc.role == NpcRole.supplier && npc.initialSupplyPerTurn > 0) {
        rel = rel.applySupplyDecay(npc.initialSupplyPerTurn);
      }

      // Decrement unavailability timer (always)
      rel = rel.decrementUnavailability();

      // Decay reputation if not trading (1 point per 5 turns of inactivity)
      if (rel.lastTradeTurn > 0 && (rel.lastTradeTurn % 5) == 0) {
        rel = rel.addReputation(-1);
      }

      updated[entry.key] = rel;
    }

    return updated;
  }

  /// Mark NPC as busted (arrested/disappeared).
  /// They'll be unavailable for N turns.
  NpcRelationship markNpcBusted(
    NpcRelationship relationship,
    int unavailableTurns,
  ) {
    return relationship.markBusted(unavailableTurns);
  }

  /// Get relationship status as human-readable string.
  String getRelationshipStatus(NpcRelationship relationship) {
    if (relationship.reputation >= 81) {
      return 'Trusted';
    } else if (relationship.reputation >= 51) {
      return 'Friend';
    } else if (relationship.reputation >= 21) {
      return 'Regular';
    } else {
      return 'Stranger';
    }
  }

  /// Calculate trust level (0-5 stars).
  int getTrustLevel(NpcRelationship relationship) {
    return (relationship.reputation / 20).floor().clamp(0, 5);
  }

  /// Calculate fixer service cost.
  ///
  /// Base: $750/heat point, discounted by reputation bonus.
  /// Cooldown: Once per 3 turns (tracks via lastServiceTurn).
  double calculateFixerCost(int heatPoints, NpcRelationship relationship) {
    const basePerPoint = 750.0;
    var cost = basePerPoint * heatPoints;

    // Apply reputation bonus (same as trading discount)
    final reputationBonusPercent = (relationship.reputation / 100) * 0.3;
    cost *= (1 - reputationBonusPercent);

    return cost;
  }

  /// Calculate doctor service cost.
  ///
  /// Base: $300/health point, discounted by reputation bonus.
  double calculateDoctorCost(int healthPoints, NpcRelationship relationship) {
    const basePerPoint = 300.0;
    var cost = basePerPoint * healthPoints;

    // Apply reputation bonus
    final reputationBonusPercent = (relationship.reputation / 100) * 0.3;
    cost *= (1 - reputationBonusPercent);

    return cost;
  }

  /// Calculate lawyer service cost.
  ///
  /// Base: $7500, discounted by reputation bonus.
  /// One-time use per game.
  double calculateLawyerCost(NpcRelationship relationship) {
    const baseCost = 7500.0;
    var cost = baseCost;

    // Apply reputation bonus
    final reputationBonusPercent = (relationship.reputation / 100) * 0.3;
    cost *= (1 - reputationBonusPercent);

    return cost;
  }

  /// Check if fixer service can be used (cooldown check).
  ///
  /// Returns false if last service use was within 3 turns.
  bool canUseFixerService(NpcRelationship relationship, int currentTurn) {
    if (relationship.lastTradeTurn <= 0) {
      return true; // Never used before
    }
    // 3-turn cooldown
    return (currentTurn - relationship.lastTradeTurn) >= 3;
  }

  /// Check if lawyer has already been used.
  ///
  /// Lawyer is one-time per game: returns true if already used.
  bool lawyerAlreadyUsed(NpcRelationship relationship) {
    return relationship.tradeCount > 0;
  }
}

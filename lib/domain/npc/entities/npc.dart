import 'package:equatable/equatable.dart';

import '../../location/entities/location.dart';

/// Role an NPC plays in the game.
enum NpcRole {
  supplier,
  buyer,
  fixer,
  lawyer,
  doctor,
}

/// An NPC trader/contact in the game world.
class Npc extends Equatable {
  final String id;
  final String name;
  final NpcRole role;
  final LocationType homeLocation;

  /// Maximum units this NPC can buy/sell per turn.
  final int maxQuantityPerTurn;

  /// Price modifier for this NPC (1.0 = standard, 0.8 = 20% discount).
  final double basePriceModifier;

  /// How much this NPC's prices shift based on trade history.
  /// Higher = prices change faster when you trade with them a lot.
  final double priceMemoryFactor;

  /// Description/flavour text.
  final String description;

  /// Set of NPC IDs that this NPC is rivals with.
  /// Building rep with one decreases rep with their rivals.
  final Set<String> rivalIds;

  /// How likely this NPC is to get arrested/disappear (0.0 - 1.0 per turn).
  final double bustChance;

  /// Initial supply per turn (for suppliers only).
  final int initialSupplyPerTurn;

  const Npc({
    required this.id,
    required this.name,
    required this.role,
    required this.homeLocation,
    required this.maxQuantityPerTurn,
    this.basePriceModifier = 1.0,
    this.priceMemoryFactor = 0.1,
    this.description = '',
    this.rivalIds = const {},
    this.bustChance = 0.0,
    this.initialSupplyPerTurn = 0,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        role,
        homeLocation,
        maxQuantityPerTurn,
        basePriceModifier,
        priceMemoryFactor,
        description,
        rivalIds,
        bustChance,
        initialSupplyPerTurn,
      ];

  @override
  String toString() => 'Npc($name, $role)';
}

/// Tracks the player's relationship with an NPC.
class NpcRelationship extends Equatable {
  final String npcId;

  /// Reputation with this NPC (0-100).
  final int reputation;

  /// Number of trades completed with this NPC.
  final int tradeCount;

  /// Total value of trades with this NPC (in cents).
  final int totalTradeValue;

  /// Turn of last trade (for price memory decay).
  final int lastTradeTurn;

  /// Whether the NPC is currently active (not arrested/missing).
  final bool isActive;

  /// Current supply available from this NPC (for suppliers).
  /// Decays by 20% per turn until restocked.
  final int currentSupply;

  /// Turn counter for supply decay (resets when NPC restocks).
  final int turnsSinceRestock;

  /// Turns remaining if NPC is unavailable (busted/arrested).
  final int turnsUnavailable;

  const NpcRelationship({
    required this.npcId,
    this.reputation = 0,
    this.tradeCount = 0,
    this.totalTradeValue = 0,
    this.lastTradeTurn = 0,
    this.isActive = true,
    this.currentSupply = 0,
    this.turnsSinceRestock = 0,
    this.turnsUnavailable = 0,
  });

  NpcRelationship copyWith({
    int? reputation,
    int? tradeCount,
    int? totalTradeValue,
    int? lastTradeTurn,
    bool? isActive,
    int? currentSupply,
    int? turnsSinceRestock,
    int? turnsUnavailable,
  }) {
    return NpcRelationship(
      npcId: npcId,
      reputation: reputation ?? this.reputation,
      tradeCount: tradeCount ?? this.tradeCount,
      totalTradeValue: totalTradeValue ?? this.totalTradeValue,
      lastTradeTurn: lastTradeTurn ?? this.lastTradeTurn,
      isActive: isActive ?? this.isActive,
      currentSupply: currentSupply ?? this.currentSupply,
      turnsSinceRestock: turnsSinceRestock ?? this.turnsSinceRestock,
      turnsUnavailable: turnsUnavailable ?? this.turnsUnavailable,
    );
  }

  /// Add reputation, clamped to 0-100.
  NpcRelationship addReputation(int amount) {
    return copyWith(reputation: (reputation + amount).clamp(0, 100));
  }

  /// Record a trade.
  NpcRelationship recordTrade(int value, int currentTurn) {
    return copyWith(
      tradeCount: tradeCount + 1,
      totalTradeValue: totalTradeValue + value,
      lastTradeTurn: currentTurn,
    );
  }

  /// Reduce supply by amount purchased.
  NpcRelationship useSupply(int amount) {
    return copyWith(currentSupply: (currentSupply - amount).clamp(0, currentSupply));
  }

  /// Apply supply decay (20% per turn).
  NpcRelationship applySupplyDecay(int npcInitialSupply) {
    if (currentSupply <= 0) {
      // Restock if supply depleted
      return copyWith(
        currentSupply: npcInitialSupply,
        turnsSinceRestock: 0,
      );
    }
    // Decay by 20%
    final decayed = (currentSupply * 0.8).toInt();
    return copyWith(
      currentSupply: decayed,
      turnsSinceRestock: turnsSinceRestock + 1,
    );
  }

  /// Handle NPC being busted (unavailable for N turns).
  NpcRelationship markBusted(int unavailableTurns) {
    return copyWith(
      isActive: false,
      turnsUnavailable: unavailableTurns,
      reputation: (reputation - 20).clamp(0, 100), // Reputation hit
    );
  }

  /// Decrement unavailability timer (called each turn).
  NpcRelationship decrementUnavailability() {
    if (turnsUnavailable <= 0) {
      return this;
    }
    final newUnavailable = turnsUnavailable - 1;
    final nowActive = newUnavailable <= 0;
    return copyWith(
      turnsUnavailable: newUnavailable,
      isActive: nowActive,
    );
  }

  /// Check if NPC can trade (not arrested/unavailable).
  bool get canTrade => isActive && turnsUnavailable <= 0;

  @override
  List<Object?> get props => [
        npcId,
        reputation,
        tradeCount,
        totalTradeValue,
        lastTradeTurn,
        isActive,
        currentSupply,
        turnsSinceRestock,
        turnsUnavailable,
      ];
}

/// Default NPCs for Phase 2A MVP.
/// 6 starter NPCs covering all roles.
/// See docs/design/npc-system-spec.md for full system design.
class DefaultNpcs {
  DefaultNpcs._();

  static const List<Npc> all = [
    // Supplier 1: Street Chemist (Lagos) - Cheap, High Risk
    Npc(
      id: 'chemist_lagos',
      name: 'Street Chemist',
      role: NpcRole.supplier,
      homeLocation: LocationType.lagos,
      maxQuantityPerTurn: 40,
      initialSupplyPerTurn: 40,
      basePriceModifier: 0.85, // -15% markup
      priceMemoryFactor: 0.15,
      description: 'Black market chemist in Lagos. Cheap but sketchy.',
      bustChance: 0.08, // Higher risk
    ),

    // Supplier 2: Cartel Supplier (Mexico City) - Mid Price, Mid Risk
    Npc(
      id: 'cartel_mexico',
      name: 'Miguel',
      role: NpcRole.supplier,
      homeLocation: LocationType.mexicoCity,
      maxQuantityPerTurn: 50,
      initialSupplyPerTurn: 50,
      basePriceModifier: 0.90, // -10% markup
      priceMemoryFactor: 0.12,
      description: 'Cartel-connected supplier. Reliable middleman.',
      bustChance: 0.05,
    ),

    // Buyer 1: Club Owner (New York) - Premium Buyer
    Npc(
      id: 'club_owner_ny',
      name: 'Club Owner',
      role: NpcRole.buyer,
      homeLocation: LocationType.newYork,
      maxQuantityPerTurn: 30,
      basePriceModifier: 1.20, // +20% markup
      priceMemoryFactor: 0.10,
      description: 'Nightclub owner in NYC. Always buying premium goods.',
      bustChance: 0.03,
    ),

    // Fixer: Heat Reduction Specialist (Rio)
    Npc(
      id: 'fixer_rio',
      name: 'Fixer',
      role: NpcRole.fixer,
      homeLocation: LocationType.rioDeJaneiro,
      maxQuantityPerTurn: 0,
      basePriceModifier: 1.0,
      description: 'Rio connection. Pays bribes to reduce heat. Expensive but effective.',
      bustChance: 0.08, // Risky to use repeatedly
    ),

    // Lawyer: One-Time Get-Out-of-Jail Card (Cape Town)
    Npc(
      id: 'lawyer_capetown',
      name: 'Lawyer',
      role: NpcRole.lawyer,
      homeLocation: LocationType.capeTown,
      maxQuantityPerTurn: 0,
      basePriceModifier: 1.0,
      description: 'Street lawyer. Can save you from one arrest. One-time use, expensive.',
      bustChance: 0.0, // Safe to use
    ),

    // Doctor: Health Restoration (Tokyo)
    Npc(
      id: 'doctor_tokyo',
      name: 'Dr. Tanaka',
      role: NpcRole.doctor,
      homeLocation: LocationType.tokyo,
      maxQuantityPerTurn: 0,
      basePriceModifier: 1.0,
      description: 'Tokyo clinic. Heals wounds for a price. No questions asked.',
      bustChance: 0.02,
    ),
  ];

  /// Get NPC by ID.
  static Npc? byId(String id) {
    try {
      return all.firstWhere((npc) => npc.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get NPCs at a specific location.
  static List<Npc> atLocation(LocationType location) {
    return all.where((npc) => npc.homeLocation == location).toList();
  }

  /// Total NPCs available.
  static int get count => all.length;
}

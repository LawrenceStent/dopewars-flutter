import 'package:equatable/equatable.dart';

import '../../location/entities/location.dart';

/// Type of contract/mission.
enum ContractType {
  transport,     // Move drugs from A to B
  elimination,   // Defeat a rival dealer
  relationship,  // Build NPC relationships
  stealth,       // Avoid police for N turns
  logistics,     // Establish supply chain
  collection,    // Accumulate target cash
}

/// Status of a contract.
enum ContractStatus {
  available,     // Can be accepted
  active,        // In progress
  completed,     // Successfully finished
  failed,        // Time ran out or conditions failed
  expired,       // Was never accepted and timed out
}

/// A mission/contract the player can undertake.
class Contract extends Equatable {
  final String id;
  final String title;
  final String description;
  final ContractType type;

  /// Locations involved in this contract.
  final Set<LocationType> locations;

  /// Cash reward on completion (in cents).
  final int cashReward;

  /// Reputation reward on completion.
  final int reputationReward;

  /// Number of turns to complete (from acceptance).
  final int turnLimit;

  /// Difficulty rating (1-5).
  final int difficulty;

  /// Current status.
  final ContractStatus status;

  /// Turn the contract was accepted.
  final int? acceptedOnTurn;

  /// Progress percentage (0-100).
  final int progress;

  const Contract({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.locations,
    required this.cashReward,
    this.reputationReward = 0,
    required this.turnLimit,
    required this.difficulty,
    this.status = ContractStatus.available,
    this.acceptedOnTurn,
    this.progress = 0,
  });

  /// Whether the contract has expired.
  bool hasExpired(int currentTurn) {
    if (acceptedOnTurn == null) return false;
    return currentTurn - acceptedOnTurn! > turnLimit;
  }

  Contract copyWith({
    ContractStatus? status,
    int? acceptedOnTurn,
    int? progress,
  }) {
    return Contract(
      id: id,
      title: title,
      description: description,
      type: type,
      locations: locations,
      cashReward: cashReward,
      reputationReward: reputationReward,
      turnLimit: turnLimit,
      difficulty: difficulty,
      status: status ?? this.status,
      acceptedOnTurn: acceptedOnTurn ?? this.acceptedOnTurn,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        locations,
        cashReward,
        reputationReward,
        turnLimit,
        difficulty,
        status,
        acceptedOnTurn,
        progress,
      ];

  @override
  String toString() => 'Contract($title, $status)';
}

/// Contract templates (Phase 2 - only transport & logistics offered to players).
/// Stealth & collection templates exist for Phase 3.
class DefaultContracts {
  DefaultContracts._();

  static const List<Contract> templates = [
    // Transport contracts (functional in Phase 2C)
    Contract(
      id: 'transport_la_nyc',
      title: 'Coast to Coast',
      description: 'Move 100 units of cocaine from LA to NYC in 5 turns.',
      type: ContractType.transport,
      locations: {LocationType.losAngeles, LocationType.newYork},
      cashReward: 50000,
      reputationReward: 10,
      turnLimit: 5,
      difficulty: 2,
    ),
    Contract(
      id: 'transport_tokyo_london',
      title: 'Tokyo Express',
      description: 'Transport heroin from Tokyo to London in 8 turns.',
      type: ContractType.transport,
      locations: {LocationType.tokyo, LocationType.london},
      cashReward: 75000,
      reputationReward: 15,
      turnLimit: 8,
      difficulty: 3,
    ),
    Contract(
      id: 'transport_lagos_nyc',
      title: 'Atlantic Run',
      description: 'Deliver cocaine from Lagos to New York in 6 turns.',
      type: ContractType.transport,
      locations: {LocationType.lagos, LocationType.newYork},
      cashReward: 60000,
      reputationReward: 12,
      turnLimit: 6,
      difficulty: 2,
    ),

    // Logistics contracts (functional in Phase 2C)
    Contract(
      id: 'logistics_local_circuit',
      title: 'Atlantic Circuit',
      description: 'Establish supply chain: London → Paris → Barcelona in 10 turns.',
      type: ContractType.logistics,
      locations: {LocationType.london, LocationType.paris, LocationType.barcelona},
      cashReward: 80000,
      reputationReward: 16,
      turnLimit: 10,
      difficulty: 3,
    ),
    Contract(
      id: 'logistics_lagos_london',
      title: 'African Express',
      description: 'Establish supply chain: Lagos to London to NYC.',
      type: ContractType.logistics,
      locations: {LocationType.lagos, LocationType.london, LocationType.newYork},
      cashReward: 100000,
      reputationReward: 20,
      turnLimit: 15,
      difficulty: 4,
    ),

    // Stealth contracts (Phase 3 - NOT offered to players in 2C)
    Contract(
      id: 'stealth_avoid_5',
      title: 'Shadows',
      description: 'Avoid all police encounters for 5 turns.',
      type: ContractType.stealth,
      locations: {},
      cashReward: 20000,
      reputationReward: 8,
      turnLimit: 5,
      difficulty: 1,
    ),
    Contract(
      id: 'stealth_avoid_10',
      title: 'Ghost',
      description: 'Avoid all police encounters for 10 turns.',
      type: ContractType.stealth,
      locations: {},
      cashReward: 30000,
      reputationReward: 15,
      turnLimit: 10,
      difficulty: 3,
    ),
    Contract(
      id: 'stealth_ghost_premium',
      title: 'Silent Operator',
      description: 'Stay off the radar for 15 turns without police attention.',
      type: ContractType.stealth,
      locations: {},
      cashReward: 50000,
      reputationReward: 25,
      turnLimit: 15,
      difficulty: 5,
    ),

    // Collection contracts (Phase 3 - NOT offered to players in 2C)
    Contract(
      id: 'collection_50k',
      title: 'Modest Goals',
      description: 'Accumulate \$50,000 in net worth.',
      type: ContractType.collection,
      locations: {},
      cashReward: 25000,
      reputationReward: 10,
      turnLimit: 20,
      difficulty: 1,
    ),
    Contract(
      id: 'collection_200k',
      title: 'High Roller',
      description: 'Accumulate \$200,000 in net worth.',
      type: ContractType.collection,
      locations: {},
      cashReward: 100000,
      reputationReward: 30,
      turnLimit: 30,
      difficulty: 4,
    ),
  ];
}

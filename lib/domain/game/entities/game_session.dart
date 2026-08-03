import 'package:equatable/equatable.dart';

import '../../npc/entities/npc.dart';

/// Represents a saved game session metadata and persistent state.
///
/// Note: Full game state restoration would require serializing Player and DrugMarket,
/// which is complex. This stores essential metadata + persistent systems (NPCs).
class GameSession extends Equatable {
  final String id;
  final String playerName;
  final int turn;
  final int netWorth;
  final int locationIndex;
  final DateTime savedAt;

  /// NPC relationship tracking (persists across sessions).
  final Map<String, NpcRelationship> npcRelationships;

  const GameSession({
    required this.id,
    required this.playerName,
    required this.turn,
    required this.netWorth,
    required this.locationIndex,
    required this.savedAt,
    this.npcRelationships = const {},
  });

  /// Convert to JSON for persistence.
  Map<String, dynamic> toJson() {
    // Serialize NPC relationships
    final npcRelationshipsJson = npcRelationships.map((id, rel) => MapEntry(
          id,
          {
            'npcId': rel.npcId,
            'reputation': rel.reputation,
            'tradeCount': rel.tradeCount,
            'totalTradeValue': rel.totalTradeValue,
            'lastTradeTurn': rel.lastTradeTurn,
            'isActive': rel.isActive,
            'currentSupply': rel.currentSupply,
            'turnsSinceRestock': rel.turnsSinceRestock,
            'turnsUnavailable': rel.turnsUnavailable,
          },
        ));

    return {
      'id': id,
      'playerName': playerName,
      'turn': turn,
      'netWorth': netWorth,
      'locationIndex': locationIndex,
      'savedAt': savedAt.toIso8601String(),
      'npcRelationships': npcRelationshipsJson,
    };
  }

  /// Create from JSON.
  factory GameSession.fromJson(Map<String, dynamic> json) {
    // Deserialize NPC relationships
    final npcRelJson = json['npcRelationships'] as Map<String, dynamic>? ?? {};
    final npcRelationships = npcRelJson.map((id, relJson) {
      final data = relJson as Map<String, dynamic>;
      return MapEntry(
        id,
        NpcRelationship(
          npcId: data['npcId'] as String,
          reputation: data['reputation'] as int? ?? 0,
          tradeCount: data['tradeCount'] as int? ?? 0,
          totalTradeValue: data['totalTradeValue'] as int? ?? 0,
          lastTradeTurn: data['lastTradeTurn'] as int? ?? 0,
          isActive: data['isActive'] as bool? ?? true,
          currentSupply: data['currentSupply'] as int? ?? 0,
          turnsSinceRestock: data['turnsSinceRestock'] as int? ?? 0,
          turnsUnavailable: data['turnsUnavailable'] as int? ?? 0,
        ),
      );
    });

    return GameSession(
      id: json['id'] as String,
      playerName: json['playerName'] as String,
      turn: json['turn'] as int,
      netWorth: json['netWorth'] as int,
      locationIndex: json['locationIndex'] as int,
      savedAt: DateTime.parse(json['savedAt'] as String),
      npcRelationships: npcRelationships,
    );
  }

  @override
  List<Object?> get props => [
        id,
        playerName,
        turn,
        netWorth,
        locationIndex,
        savedAt,
        npcRelationships,
      ];

  @override
  String toString() =>
      'GameSession($playerName: turn $turn, net worth \$$netWorth at $savedAt)';
}

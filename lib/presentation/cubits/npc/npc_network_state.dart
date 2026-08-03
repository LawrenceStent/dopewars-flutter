part of 'npc_network_cubit.dart';

/// State for NPC trading network.
///
/// Maintains immutable snapshot of all NPC relationships and metadata.
class NpcNetworkState extends Equatable {
  /// All NPC relationships, indexed by NPC ID.
  final Map<String, NpcRelationship> relationships;

  /// Whether NPC system is currently locked (e.g., during turn processing).
  final bool isLocked;

  /// Error message if last operation failed.
  final String? error;

  const NpcNetworkState({
    this.relationships = const {},
    this.isLocked = false,
    this.error,
  });

  /// Create a copy with some fields replaced.
  NpcNetworkState copyWith({
    Map<String, NpcRelationship>? relationships,
    bool? isLocked,
    String? error,
  }) {
    return NpcNetworkState(
      relationships: relationships ?? this.relationships,
      isLocked: isLocked ?? this.isLocked,
      error: error,
    );
  }

  /// Get relationship for an NPC, or null if not encountered.
  NpcRelationship? getRelationship(String npcId) => relationships[npcId];

  /// Check if player has encountered this NPC before.
  bool hasMetNpc(String npcId) => relationships.containsKey(npcId);

  /// Get all relationships that are currently tradeable.
  Map<String, NpcRelationship> getTradeableRelationships(NpcRepository repository) {
    return Map.fromEntries(
      relationships.entries.where((e) => repository.canTrade(e.value)),
    );
  }

  /// Get all relationships that are NOT tradeable and why.
  Map<String, String> getUnavailableReasons(NpcRepository repository) {
    final result = <String, String>{};
    for (final entry in relationships.entries) {
      final reason = repository.getUnavailableReason(entry.value);
      if (reason != null) {
        result[entry.key] = reason;
      }
    }
    return result;
  }

  @override
  List<Object?> get props => [relationships, isLocked, error];
}

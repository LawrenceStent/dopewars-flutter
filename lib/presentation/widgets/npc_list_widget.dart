import 'package:flutter/material.dart';

import '../../domain/npc/entities/npc.dart';
import '../../domain/player/entities/player.dart';
import '../cubits/npc/npc_network_cubit.dart';

/// Widget for listing available NPCs at current location.
///
/// Shows all NPCs at the player's current location with their:
/// - Name and role
/// - Current reputation/trust level
/// - Trading status (available, busted, not met)
class NpcListWidget extends StatelessWidget {
  final Player player;
  final List<Npc> npcsAtLocation;
  final NpcNetworkCubit npcNetworkCubit;
  final Function(String npcId, String npcName) onNpcSelected;
  final VoidCallback onClose;

  const NpcListWidget({
    super.key,
    required this.player,
    required this.npcsAtLocation,
    required this.npcNetworkCubit,
    required this.onNpcSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Card(
          color: Colors.grey[850],
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Row(
                    children: [
                      Icon(Icons.people, color: Colors.cyan[300], size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AVAILABLE CONTACTS',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.cyan[300],
                              ),
                            ),
                            Text(
                              'Cash: ${player.cash}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 16),

                  // NPCs list
                  if (npcsAtLocation.isEmpty)
                    Text(
                      'No contacts here.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    )
                  else
                    Column(
                      children: [
                        for (final npc in npcsAtLocation) ...[
                          _NpcCard(
                            npc: npc,
                            npcNetworkCubit: npcNetworkCubit,
                            onTapped: () => onNpcSelected(npc.id, npc.name),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),

                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 16),

                  // Close button
                  ElevatedButton(
                    onPressed: onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'LEAVE',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual NPC card in the list.
class _NpcCard extends StatelessWidget {
  final Npc npc;
  final NpcNetworkCubit npcNetworkCubit;
  final VoidCallback onTapped;

  const _NpcCard({
    required this.npc,
    required this.npcNetworkCubit,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapped,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border.all(
            color: _getRoleColor(npc.role),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and role
            Row(
              children: [
                Icon(
                  _getRoleIcon(npc.role),
                  color: _getRoleColor(npc.role),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        npc.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getRoleColor(npc.role),
                        ),
                      ),
                      Text(
                        _formatRole(npc.role),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Reputation and status
            StreamBuilder<NpcNetworkState>(
              stream: npcNetworkCubit.stream,
              initialData: npcNetworkCubit.state,
              builder: (context, snapshot) {
                final state = snapshot.data ?? npcNetworkCubit.state;
                final hasMetNpc = state.hasMetNpc(npc.id);

                if (!hasMetNpc) {
                  return Text(
                    'Unknown contact',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                  );
                }

                final relationship = state.getRelationship(npc.id);
                if (relationship == null) {
                  return const SizedBox.shrink();
                }

                final status =
                    npcNetworkCubit.getRelationshipStatus(npc.id);
                final trustLevel = npcNetworkCubit.getTrustLevel(npc.id);
                final unavailableReason =
                    npcNetworkCubit.getUnavailableReason(npc.id);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reputation and trust level
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$status (${relationship.reputation}%)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (int i = 0; i < 5; i++)
                              Icon(
                                i < trustLevel ? Icons.star : Icons.star_outline,
                                size: 12,
                                color: Colors.amber,
                              ),
                          ],
                        ),
                      ],
                    ),

                    // Unavailable reason if applicable
                    if (unavailableReason != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          unavailableReason,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red[400],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(NpcRole role) {
    switch (role) {
      case NpcRole.supplier:
        return Colors.green[400]!;
      case NpcRole.buyer:
        return Colors.blue[400]!;
      case NpcRole.fixer:
        return Colors.yellow[700]!;
      case NpcRole.lawyer:
        return Colors.purple[400]!;
      case NpcRole.doctor:
        return Colors.red[400]!;
    }
  }

  IconData _getRoleIcon(NpcRole role) {
    switch (role) {
      case NpcRole.supplier:
        return Icons.local_shipping;
      case NpcRole.buyer:
        return Icons.shopping_cart;
      case NpcRole.fixer:
        return Icons.handshake;
      case NpcRole.lawyer:
        return Icons.gavel;
      case NpcRole.doctor:
        return Icons.local_hospital;
    }
  }

  String _formatRole(NpcRole role) {
    switch (role) {
      case NpcRole.supplier:
        return 'Supplier - Sells drugs';
      case NpcRole.buyer:
        return 'Buyer - Buys drugs';
      case NpcRole.fixer:
        return 'Fixer - Reduces heat';
      case NpcRole.lawyer:
        return 'Lawyer - Prevents arrest';
      case NpcRole.doctor:
        return 'Doctor - Heals health';
    }
  }
}

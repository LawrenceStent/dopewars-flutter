import 'package:flutter/material.dart';

/// Widget for displaying combat UI.
class CombatWidget extends StatelessWidget {
  final String opponentName;
  final int opponentHealth;
  final int playerHealth;
  final int deputyCount;
  final List<String> combatLog;
  final bool canFire;
  final bool canFlee;
  final VoidCallback onFire;
  final VoidCallback onFlee;

  const CombatWidget({
    super.key,
    required this.opponentName,
    required this.opponentHealth,
    required this.playerHealth,
    required this.deputyCount,
    required this.combatLog,
    required this.canFire,
    required this.canFlee,
    required this.onFire,
    required this.onFlee,
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
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Row(
                    children: [
                      Icon(Icons.local_police, color: Colors.red[400], size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'COMBAT!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[400],
                              ),
                            ),
                            Text(
                              opponentName,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Opponent info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red[700]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              opponentName,
                              style: TextStyle(
                                color: Colors.red[400],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'HP: $opponentHealth',
                              style: TextStyle(
                                color: opponentHealth <= 0
                                    ? Colors.grey[600]
                                    : Colors.red[400],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            minHeight: 20,
                            value: opponentHealth > 0 ? opponentHealth / 100 : 0,
                            backgroundColor: Colors.grey[700],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red[400]!),
                          ),
                        ),
                        if (deputyCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '$deputyCount deputies assisting',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Player health
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green[700]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'You',
                              style: TextStyle(
                                color: Colors.green[400],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'HP: $playerHealth',
                              style: TextStyle(
                                color: playerHealth <= 0
                                    ? Colors.grey[600]
                                    : Colors.green[400],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            minHeight: 20,
                            value: playerHealth > 0 ? playerHealth / 100 : 0,
                            backgroundColor: Colors.grey[700],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.green[400]!),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Combat log
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      border: Border.all(color: Colors.grey[700]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final log in combatLog)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                log,
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: canFire ? onFire : null,
                          icon: const Icon(Icons.gpp_good),
                          label: const Text('FIRE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: canFlee ? onFlee : null,
                          icon: const Icon(Icons.directions_run),
                          label: const Text('FLEE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
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

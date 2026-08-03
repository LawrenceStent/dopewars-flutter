import 'package:flutter/material.dart';

import '../../core/constants/game_constants.dart';
import '../../domain/player/entities/player.dart';

/// Widget for The Pub location (hiring bitches).
class PubWidget extends StatefulWidget {
  final Player player;
  final List<String> messages;
  final Function(int quantity) onHireBitch;
  final VoidCallback onLeave;

  const PubWidget({
    super.key,
    required this.player,
    required this.messages,
    required this.onHireBitch,
    required this.onLeave,
  });

  @override
  State<PubWidget> createState() => _PubWidgetState();
}

class _PubWidgetState extends State<PubWidget> {
  int hireQuantity = 1;

  @override
  Widget build(BuildContext context) {
    final bitchCostPerUnit = GameConstants.bitchHireCost;
    final totalCost = bitchCostPerUnit * hireQuantity;
    final canAfford = widget.player.cash.dollars >= totalCost;

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
                      Icon(Icons.local_bar, color: Colors.purple[400], size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'THE PUB',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple[400],
                              ),
                            ),
                            Text(
                              'Hire people to carry more drugs',
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

                  // Player info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple[700]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Cash:',
                              style: TextStyle(
                                color: Colors.purple[300],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.player.cash.toString(),
                              style: TextStyle(
                                color: Colors.green[400],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Carrying Capacity:',
                              style: TextStyle(
                                color: Colors.purple[300],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.player.coatSize.value.toString(),
                              style: TextStyle(
                                color: Colors.blue[400],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Messages
                  if (widget.messages.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        border: Border.all(color: Colors.purple[700]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.messages
                            .map((msg) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    msg,
                                    style: TextStyle(
                                      color: Colors.purple[300],
                                      fontSize: 12,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  if (widget.messages.isNotEmpty) const SizedBox(height: 16),

                  // Bitch hiring section
                  Text(
                    'Hire People',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[400],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple[700]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Cost per person: \$$bitchCostPerUnit',
                              style: TextStyle(
                                color: Colors.green[400],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '+${GameConstants.bitchCarryCapacity} capacity each',
                              style: TextStyle(
                                color: Colors.blue[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: hireQuantity > 1
                                        ? () {
                                            setState(() {
                                              hireQuantity--;
                                            });
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[700],
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: const Text('-'),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    hireQuantity.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        hireQuantity++;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[700],
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: const Text('+'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Total cost: \$$totalCost',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: canAfford ? Colors.green[400] : Colors.red[400],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: canAfford
                              ? () => widget.onHireBitch(hireQuantity)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'HIRE ${hireQuantity == 1 ? 'PERSON' : 'PEOPLE'}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Leave button
                  ElevatedButton(
                    onPressed: widget.onLeave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('LEAVE PUB'),
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

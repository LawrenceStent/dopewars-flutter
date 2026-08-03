import 'package:flutter/material.dart';

import '../../domain/combat/entities/gun.dart';
import '../../domain/player/entities/player.dart';

/// Widget for the Gun Shop location.
class GunShopWidget extends StatefulWidget {
  final Player player;
  final List<String> messages;
  final Function(int gunIndex, int quantity) onBuyGun;
  final VoidCallback onLeave;

  const GunShopWidget({
    super.key,
    required this.player,
    required this.messages,
    required this.onBuyGun,
    required this.onLeave,
  });

  @override
  State<GunShopWidget> createState() => _GunShopWidgetState();
}

class _GunShopWidgetState extends State<GunShopWidget> {
  final Map<int, int> quantities = {};

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
                      Icon(Icons.gpp_good, color: Colors.orange[400], size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DAN\'S HOUSE OF GUNS',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[400],
                              ),
                            ),
                            Text(
                              'Cash: ${widget.player.cash}',
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

                  // Messages
                  if (widget.messages.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        border: Border.all(color: Colors.orange[700]!),
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
                                      color: Colors.orange[300],
                                      fontSize: 12,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  if (widget.messages.isNotEmpty) const SizedBox(height: 16),

                  // Guns list
                  Text(
                    'Available Guns:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[400],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...DefaultGuns.all.map((gun) {
                    final playerHasGun = widget.player.guns.containsKey(gun.index);
                    final playerQuantity = playerHasGun
                        ? widget.player.guns[gun.index]?.carried ?? 0
                        : 0;
                    final quantity = quantities[gun.index] ?? 1;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange[700]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      gun.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[300],
                                      ),
                                    ),
                                    Text(
                                      'Damage: ${gun.damage} | Space: ${gun.space}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    if (playerQuantity > 0)
                                      Text(
                                        'You have: $playerQuantity',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green[400],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                gun.price.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[400],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          quantities[gun.index] =
                                              (quantities[gun.index] ?? 1) - 1;
                                          if ((quantities[gun.index] ?? 0) <= 0)
                                            quantities.remove(gun.index);
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[700],
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                      ),
                                      child: const Text('-'),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      quantity.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          quantities[gun.index] =
                                              (quantities[gun.index] ?? 1) + 1;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[700],
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                      ),
                                      child: const Text('+'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () =>
                                    widget.onBuyGun(gun.index, quantity),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[700],
                                ),
                                child: const Text('BUY'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),

                  // Leave button
                  ElevatedButton(
                    onPressed: widget.onLeave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('LEAVE GUN SHOP'),
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

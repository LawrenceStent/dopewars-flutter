import 'package:flutter/material.dart';

import '../../domain/player/entities/player.dart';
import '../../domain/trading/entities/drug.dart';
import '../../domain/trading/entities/drug_market.dart';

/// Widget displaying the player's drug inventory.
class InventoryWidget extends StatelessWidget {
  final Player player;
  final DrugMarket? market;
  final void Function(DrugType type, int quantity)? onSell;

  const InventoryWidget({
    super.key,
    required this.player,
    this.market,
    this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final drugsWithInventory = player.drugs.entries
        .where((e) => e.value.carried > 0)
        .toList()
      ..sort((a, b) => a.key.index.compareTo(b.key.index));

    if (drugsWithInventory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'Your pockets are empty',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: drugsWithInventory.length,
      itemBuilder: (context, index) {
        final entry = drugsWithInventory[index];
        final drugType = entry.key;
        final inventory = entry.value;
        final drug = DefaultDrugs.byType(drugType);
        final marketPrice = market?.getPrice(drugType);

        return _InventoryRow(
          drug: drug,
          carried: inventory.carried,
          avgPrice: inventory.price,
          currentPrice: marketPrice?.price,
          totalValue: inventory.totalValue,
          onSell: onSell != null && marketPrice != null
              ? (qty) => onSell!(drugType, qty)
              : null,
        );
      },
    );
  }
}

class _InventoryRow extends StatelessWidget {
  final Drug drug;
  final int carried;
  final dynamic avgPrice;
  final dynamic currentPrice;
  final dynamic totalValue;
  final void Function(int quantity)? onSell;

  const _InventoryRow({
    required this.drug,
    required this.carried,
    required this.avgPrice,
    this.currentPrice,
    required this.totalValue,
    this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final profitPerUnit = currentPrice != null
        ? (currentPrice.dollars - avgPrice.dollars)
        : null;
    final isProfitable = profitPerUnit != null && profitPerUnit > 0;
    final isLoss = profitPerUnit != null && profitPerUnit < 0;

    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drug.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Qty: $carried | Avg: $avgPrice',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (currentPrice != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Now: $currentPrice',
                        style: TextStyle(
                          color: isProfitable
                              ? Colors.green[400]
                              : isLoss
                                  ? Colors.red[400]
                                  : Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      if (profitPerUnit != null)
                        Text(
                          profitPerUnit >= 0
                              ? '+\$${profitPerUnit}/unit'
                              : '-\$${profitPerUnit.abs()}/unit',
                          style: TextStyle(
                            color: isProfitable
                                ? Colors.green[300]
                                : Colors.red[300],
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  if (onSell != null)
                    ElevatedButton(
                      onPressed: () => _showSellDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('SELL'),
                    ),
                ] else
                  Text(
                    'No buyers here',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSellDialog(BuildContext context) {
    var quantity = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final totalValue = currentPrice * quantity;
          final totalProfit = (currentPrice.dollars - avgPrice.dollars) * quantity;

          return AlertDialog(
            backgroundColor: Colors.grey[850],
            title: Text(
              'Sell ${drug.name}',
              style: const TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      onPressed:
                          quantity > 1 ? () => setState(() => quantity--) : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        quantity.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: quantity < carried
                          ? () => setState(() => quantity++)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => quantity = 1),
                      child: const Text('1'),
                    ),
                    if (carried >= 5)
                      TextButton(
                        onPressed: () => setState(() => quantity = 5),
                        child: const Text('5'),
                      ),
                    if (carried >= 10)
                      TextButton(
                        onPressed: () => setState(() => quantity = 10),
                        child: const Text('10'),
                      ),
                    TextButton(
                      onPressed: () => setState(() => quantity = carried),
                      child: const Text('ALL'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Total: $totalValue',
                  style: TextStyle(
                    color: Colors.green[400],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  totalProfit >= 0
                      ? 'Profit: +\$$totalProfit'
                      : 'Loss: -\$${totalProfit.abs()}',
                  style: TextStyle(
                    color: totalProfit >= 0 ? Colors.green[300] : Colors.red[300],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onSell!(quantity);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                ),
                child: const Text('SELL'),
              ),
            ],
          );
        },
      ),
    );
  }
}

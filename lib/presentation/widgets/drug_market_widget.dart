import 'package:flutter/material.dart';

import '../../core/utils/responsive_layout.dart';
import '../../domain/player/entities/player.dart';
import '../../domain/trading/entities/drug.dart';
import '../../domain/trading/entities/drug_market.dart';

/// Widget displaying the drug market and inventory.
class DrugMarketWidget extends StatelessWidget {
  final DrugMarket market;
  final Player player;
  final void Function(DrugType type, int quantity) onBuy;
  final void Function(DrugType type, int quantity) onSell;

  const DrugMarketWidget({
    super.key,
    required this.market,
    required this.player,
    required this.onBuy,
    required this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveLayout.responsivePadding(
      context,
      mobile: ResponsiveLayout.paddingSm,
      tablet: ResponsiveLayout.paddingMd,
      desktop: ResponsiveLayout.paddingLg,
    );

    return ListView.builder(
      padding: EdgeInsets.all(padding),
      itemCount: DefaultDrugs.count,
      itemBuilder: (context, index) {
        final drug = DefaultDrugs.all[index];
        final priceInfo = market.getPrice(drug.type);
        final inventory = player.getDrugInventory(drug.type);

        return _DrugRow(
          drug: drug,
          priceInfo: priceInfo,
          carried: inventory.carried,
          avgPrice: inventory.price,
          availableSpace: player.availableSpace,
          playerCash: player.cash,
          onBuy: (qty) => onBuy(drug.type, qty),
          onSell: (qty) => onSell(drug.type, qty),
          context: context,
        );
      },
    );
  }
}

class _DrugRow extends StatelessWidget {
  final Drug drug;
  final DrugPrice? priceInfo;
  final int carried;
  final dynamic avgPrice;
  final int availableSpace;
  final dynamic playerCash;
  final void Function(int quantity) onBuy;
  final void Function(int quantity) onSell;
  final BuildContext context;

  const _DrugRow({
    required this.drug,
    required this.priceInfo,
    required this.carried,
    required this.avgPrice,
    required this.availableSpace,
    required this.playerCash,
    required this.onBuy,
    required this.onSell,
    required this.context,
  });

  @override
  Widget build(BuildContext buildContext) {
    final isAvailable = priceInfo != null;
    final isSpecialDeal = priceInfo?.isSpecialDeal ?? false;

    final padding = ResponsiveLayout.responsivePadding(
      context,
      mobile: 8,
      tablet: 12,
      desktop: 16,
    );

    return Card(
      color: isSpecialDeal
          ? (priceInfo!.dealType == DealType.cheap
              ? Colors.green[900]
              : Colors.red[900])
          : Colors.grey[850],
      margin: EdgeInsets.symmetric(
        vertical: ResponsiveLayout.paddingXs,
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Row(
          children: [
            // Drug name and price
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drug.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isAvailable)
                    Text(
                      priceInfo!.price.toString(),
                      style: TextStyle(
                        color: isSpecialDeal
                            ? (priceInfo!.dealType == DealType.cheap
                                ? Colors.green[300]
                                : Colors.red[300])
                            : Colors.grey[300],
                        fontSize: 14,
                      ),
                    )
                  else
                    Text(
                      'Not available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            // Inventory
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Owned',
                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  ),
                  Text(
                    carried.toString(),
                    style: TextStyle(
                      color: carried > 0 ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Buy/Sell buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAvailable) ...[
                  _ActionButton(
                    label: 'BUY',
                    enabled: _canBuy(),
                    onTap: () => _showBuyDialog(context),
                  ),
                  const SizedBox(width: 8),
                ],
                _ActionButton(
                  label: 'SELL',
                  enabled: carried > 0 && isAvailable,
                  color: Colors.orange,
                  onTap: () => _showSellDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _canBuy() {
    if (priceInfo == null) return false;
    if (availableSpace <= 0) return false;
    if (playerCash < priceInfo!.price) return false;
    return true;
  }

  void _showBuyDialog(BuildContext context) {
    if (priceInfo == null) return;

    final maxAffordable = playerCash.dollars ~/ priceInfo!.price.dollars;
    final maxBuyable = maxAffordable < availableSpace
        ? maxAffordable
        : availableSpace;

    if (maxBuyable <= 0) return;

    _showQuantityDialog(
      context,
      title: 'Buy ${drug.name}',
      maxQuantity: maxBuyable,
      pricePerUnit: priceInfo!.price,
      actionLabel: 'BUY',
      onConfirm: onBuy,
    );
  }

  void _showSellDialog(BuildContext context) {
    if (carried <= 0 || priceInfo == null) return;

    _showQuantityDialog(
      context,
      title: 'Sell ${drug.name}',
      maxQuantity: carried,
      pricePerUnit: priceInfo!.price,
      actionLabel: 'SELL',
      onConfirm: onSell,
    );
  }

  void _showQuantityDialog(
    BuildContext context, {
    required String title,
    required int maxQuantity,
    required dynamic pricePerUnit,
    required String actionLabel,
    required void Function(int) onConfirm,
  }) {
    var quantity = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quantity selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.white),
                    onPressed: quantity > 1
                        ? () => setState(() => quantity--)
                        : null,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                    onPressed: quantity < maxQuantity
                        ? () => setState(() => quantity++)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Quick select buttons
              Wrap(
                spacing: 8,
                children: [
                  _QuickButton(
                    label: '1',
                    onTap: () => setState(() => quantity = 1),
                  ),
                  _QuickButton(
                    label: '5',
                    onTap: maxQuantity >= 5
                        ? () => setState(() => quantity = 5)
                        : null,
                  ),
                  _QuickButton(
                    label: '10',
                    onTap: maxQuantity >= 10
                        ? () => setState(() => quantity = 10)
                        : null,
                  ),
                  _QuickButton(
                    label: 'MAX',
                    onTap: () => setState(() => quantity = maxQuantity),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Total
              Text(
                'Total: ${pricePerUnit * quantity}',
                style: TextStyle(
                  color: Colors.green[400],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
                onConfirm(quantity);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.enabled,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.green[700],
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          textStyle: const TextStyle(fontSize: 10),
        ),
        child: Text(label),
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _QuickButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey[400],
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Text(label),
    );
  }
}

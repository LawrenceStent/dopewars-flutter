import 'package:flutter/material.dart';

import '../../domain/npc/entities/npc.dart';
import '../../domain/npc/repositories/npc_repository.dart';
import '../../domain/player/entities/inventory.dart';
import '../../domain/player/entities/player.dart';
import '../../domain/trading/entities/drug.dart';
import '../cubits/npc/npc_network_cubit.dart';

/// Dialog for trading with an NPC.
///
/// Shows:
/// - NPC name and role
/// - Available drugs to buy/sell
/// - NPC pricing (with reputation bonus)
/// - Market price comparison
/// - Trade buttons
class NpcTradeDialog extends StatefulWidget {
  final String npcId;
  final Npc npc;
  final Player player;
  final int currentHeat;
  final NpcNetworkCubit npcNetworkCubit;
  final NpcRepository npcRepository;
  final Function(String npcId, DrugType drugType, int quantity)
      onBuyFromNpc;
  final Function(String npcId, DrugType drugType, int quantity)
      onSellToNpc;
  final Function(String npcId, int heatToReduce)? onUseFixerService;
  final Function(String npcId, int healthToRestore)? onUseDoctorService;
  final Function(String npcId)? onUseLawyerService;
  final VoidCallback onClose;

  const NpcTradeDialog({
    super.key,
    required this.npcId,
    required this.npc,
    required this.player,
    required this.currentHeat,
    required this.npcNetworkCubit,
    required this.npcRepository,
    required this.onBuyFromNpc,
    required this.onSellToNpc,
    this.onUseFixerService,
    this.onUseDoctorService,
    this.onUseLawyerService,
    required this.onClose,
  });

  @override
  State<NpcTradeDialog> createState() => _NpcTradeDialogState();
}

class _NpcTradeDialogState extends State<NpcTradeDialog> {
  final Map<DrugType, int> quantities = {};
  int fixerHeatAmount = 1;
  int doctorHealthAmount = 10;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
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
                    // NPC info
                    Row(
                      children: [
                        Icon(
                          _getRoleIcon(widget.npc.role),
                          color: _getRoleColor(widget.npc.role),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.npc.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _getRoleColor(widget.npc.role),
                                ),
                              ),
                              _buildReputationInfo(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 16),

                    // Trading options
                    if (widget.npc.role == NpcRole.supplier)
                      _buildSupplierSection()
                    else if (widget.npc.role == NpcRole.buyer)
                      _buildBuyerSection()
                    else if (widget.npc.role == NpcRole.fixer)
                      _buildFixerSection()
                    else if (widget.npc.role == NpcRole.doctor)
                      _buildDoctorSection()
                    else if (widget.npc.role == NpcRole.lawyer)
                      _buildLawyerSection()
                    else
                      Center(
                        child: Text(
                          'Unknown contact type.',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 16),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 16),

                    // Close button
                    ElevatedButton(
                      onPressed: widget.onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'CLOSE',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReputationInfo() {
    return StreamBuilder<NpcNetworkState>(
      stream: widget.npcNetworkCubit.stream,
      initialData: widget.npcNetworkCubit.state,
      builder: (context, snapshot) {
        final status = widget.npcNetworkCubit.getRelationshipStatus(widget.npcId);
        final trustLevel = widget.npcNetworkCubit.getTrustLevel(widget.npcId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status,
              style: TextStyle(fontSize: 12, color: Colors.grey[300]),
            ),
            Row(
              children: [
                for (int i = 0; i < 5; i++)
                  Icon(
                    i < trustLevel ? Icons.star : Icons.star_outline,
                    size: 14,
                    color: Colors.amber,
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSupplierSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BUY DRUGS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green[300],
          ),
        ),
        const SizedBox(height: 12),
        ..._buildDrugOptions(isSelling: false),
      ],
    );
  }

  Widget _buildBuyerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELL DRUGS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue[300],
          ),
        ),
        const SizedBox(height: 12),
        ..._buildDrugOptions(isSelling: true),
      ],
    );
  }

  List<Widget> _buildDrugOptions({required bool isSelling}) {
    final drugs = DefaultDrugs.all;
    final widgets = <Widget>[];

    for (final drug in drugs) {
      final inventory = widget.player.getDrugInventory(drug.type);
      final canTrade = isSelling
          ? inventory.carried > 0
          : widget.player.cash.dollars > 0; // Simplified check

      widgets.add(
        _buildDrugOption(
          drug: drug,
          inventory: inventory,
          canTrade: canTrade,
          isSelling: isSelling,
        ),
      );
      widgets.add(const SizedBox(height: 8));
    }

    return widgets;
  }

  Widget _buildDrugOption({
    required Drug drug,
    required Inventory inventory,
    required bool canTrade,
    required bool isSelling,
  }) {
    final relationship =
        widget.npcNetworkCubit.state.getRelationship(widget.npcId);
    if (relationship == null) return const SizedBox.shrink();

    final basePrice = ((drug.minPrice.dollars + drug.maxPrice.dollars) / 2).toDouble();
    final npcPrice = widget.npcRepository.calculateNpcPrice(
      basePrice,
      widget.npc,
      relationship,
    );

    final quantity = quantities[drug.type] ?? 0;
    final totalPrice = (npcPrice * quantity).toInt();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border.all(
          color: canTrade ? Colors.grey[700]! : Colors.grey[800]!,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drug name and prices
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drug.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: canTrade ? Colors.white : Colors.grey[600],
                      ),
                    ),
                    Text(
                      'NPC: \$${npcPrice.toInt()} / Market avg: \$${basePrice.toInt()}',
                      style: TextStyle(
                        fontSize: 11,
                        color: canTrade
                            ? Colors.grey[300]
                            : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Quantity controls
          Row(
            children: [
              IconButton(
                onPressed:
                    canTrade && quantity > 0
                        ? () => setState(() =>
                            quantities[drug.type] = quantity - 1)
                        : null,
                icon: const Icon(Icons.remove),
                iconSize: 18,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$quantity',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              IconButton(
                onPressed: canTrade
                    ? () => setState(() =>
                        quantities[drug.type] = quantity + 1)
                    : null,
                icon: const Icon(Icons.add),
                iconSize: 18,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Total: \$$totalPrice',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelling
                        ? Colors.green[300]
                        : totalPrice > widget.player.cash.dollars
                            ? Colors.red[300]
                            : Colors.grey[300],
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),

          // Trade button
          if (quantity > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSelling
                      ? () {
                          widget.onSellToNpc(
                            widget.npcId,
                            drug.type,
                            quantity,
                          );
                          widget.onClose();
                        }
                      : totalPrice > widget.player.cash.dollars
                          ? null
                          : () {
                              widget.onBuyFromNpc(
                                widget.npcId,
                                drug.type,
                                quantity,
                              );
                              widget.onClose();
                            },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelling
                        ? Colors.blue[700]
                        : Colors.green[700],
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    isSelling ? 'SELL' : 'BUY',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFixerSection() {
    final relationship =
        widget.npcNetworkCubit.state.getRelationship(widget.npcId);
    if (relationship == null) return const SizedBox.shrink();

    final cost = widget.npcRepository.calculateFixerCost(
      fixerHeatAmount,
      relationship,
    );
    final canAfford = cost <= widget.player.cash.dollars;
    final maxHeat = widget.currentHeat;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BRIBE FOR HEAT REDUCTION',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.yellow[700],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            border: Border.all(color: Colors.grey[700]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Heat:',
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                  Text(
                    '$widget.currentHeat',
                    style: TextStyle(
                      color: Colors.red[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Heat to Reduce:',
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                  Text(
                    '$fixerHeatAmount',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                value: fixerHeatAmount.toDouble(),
                min: 1,
                max: maxHeat > 0 ? maxHeat.toDouble() : 1,
                divisions: maxHeat > 1 ? maxHeat - 1 : 1,
                onChanged: (value) {
                  setState(() => fixerHeatAmount = value.toInt());
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cost:',
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                  Text(
                    '\$${cost.toInt()}',
                    style: TextStyle(
                      color: !canAfford ? Colors.red[400] : Colors.green[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canAfford && maxHeat > 0
                ? () {
                    widget.onUseFixerService?.call(widget.npcId, fixerHeatAmount);
                    widget.onClose();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[700],
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'BRIBE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorSection() {
    final relationship =
        widget.npcNetworkCubit.state.getRelationship(widget.npcId);
    if (relationship == null) return const SizedBox.shrink();

    final maxRestorable = 100 - widget.player.health.value;
    final actualAmount = doctorHealthAmount.clamp(0, maxRestorable);
    final cost = widget.npcRepository.calculateDoctorCost(
      actualAmount,
      relationship,
    );
    final canAfford = cost <= widget.player.cash.dollars;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MEDICAL TREATMENT',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red[400],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            border: Border.all(color: Colors.grey[700]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Health:',
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                  Text(
                    '${widget.player.health.value}/100',
                    style: TextStyle(
                      color: widget.player.health.value < 50
                          ? Colors.red[400]
                          : Colors.green[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Health to Restore:',
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                  Text(
                    '$actualAmount',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                value: doctorHealthAmount.toDouble(),
                min: 1,
                max: maxRestorable > 0 ? maxRestorable.toDouble() : 1,
                divisions: maxRestorable > 1 ? maxRestorable - 1 : 1,
                onChanged: maxRestorable > 0
                    ? (value) {
                        setState(() => doctorHealthAmount = value.toInt());
                      }
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cost:',
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                  Text(
                    '\$${cost.toInt()}',
                    style: TextStyle(
                      color: !canAfford ? Colors.red[400] : Colors.green[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canAfford && maxRestorable > 0
                ? () {
                    widget.onUseDoctorService?.call(widget.npcId, actualAmount);
                    widget.onClose();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'HEAL',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLawyerSection() {
    final relationship =
        widget.npcNetworkCubit.state.getRelationship(widget.npcId);
    if (relationship == null) return const SizedBox.shrink();

    final alreadyUsed = widget.npcRepository.lawyerAlreadyUsed(relationship);
    final cost = widget.npcRepository.calculateLawyerCost(relationship);
    final canAfford = cost <= widget.player.cash.dollars;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LEGAL PROTECTION',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.purple[400],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            border: Border.all(color: Colors.grey[700]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alreadyUsed
                    ? 'Protection Active'
                    : 'Get out of jail free (one-time use)',
                style: TextStyle(
                  color: alreadyUsed ? Colors.green[400] : Colors.grey[300],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              if (!alreadyUsed)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cost:',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                    Text(
                      '\$${cost.toInt()}',
                      style: TextStyle(
                        color: !canAfford ? Colors.red[400] : Colors.green[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Text(
                'If arrested, your lawyer converts the arrest to a fine. '
                'Can only be used once per game.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: !alreadyUsed && canAfford
                ? () {
                    widget.onUseLawyerService?.call(widget.npcId);
                    widget.onClose();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: alreadyUsed
                  ? Colors.grey[700]
                  : Colors.purple[700],
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              alreadyUsed ? 'PROTECTION ACTIVE' : 'HIRE LAWYER',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
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
}

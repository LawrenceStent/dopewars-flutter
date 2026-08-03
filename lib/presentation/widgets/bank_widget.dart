import 'package:flutter/material.dart';

import '../../core/value_objects/money.dart';
import '../../domain/player/entities/player.dart';

/// Widget for bank interactions (deposit/withdraw).
class BankWidget extends StatefulWidget {
  final Player player;
  final List<String> messages;
  final void Function(Money amount) onDeposit;
  final void Function(Money amount) onWithdraw;
  final VoidCallback onLeave;

  const BankWidget({
    super.key,
    required this.player,
    this.messages = const [],
    required this.onDeposit,
    required this.onWithdraw,
    required this.onLeave,
  });

  @override
  State<BankWidget> createState() => _BankWidgetState();
}

class _BankWidgetState extends State<BankWidget> {
  final _amountController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int? get _enteredAmount {
    final text = _amountController.text.replaceAll(',', '');
    return int.tryParse(text);
  }

  void _deposit() {
    final amount = _enteredAmount;
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Enter a valid amount');
      return;
    }
    if (amount > widget.player.cash.dollars) {
      setState(() => _errorMessage = 'You don\'t have that much cash!');
      return;
    }
    setState(() => _errorMessage = null);
    _amountController.clear();
    widget.onDeposit(Money(amount));
  }

  void _withdraw() {
    final amount = _enteredAmount;
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Enter a valid amount');
      return;
    }
    if (amount > widget.player.bank.dollars) {
      setState(() => _errorMessage = 'You don\'t have that much in the bank!');
      return;
    }
    setState(() => _errorMessage = null);
    _amountController.clear();
    widget.onWithdraw(Money(amount));
  }

  void _depositAll() {
    if (widget.player.cash.dollars > 0) {
      widget.onDeposit(widget.player.cash);
    }
  }

  void _withdrawAll() {
    if (widget.player.bank.dollars > 0) {
      widget.onWithdraw(widget.player.bank);
    }
  }

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
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Row(
                    children: [
                      Icon(Icons.account_balance, color: Colors.green[400], size: 32),
                      const SizedBox(width: 12),
                      Text(
                        'THE BANK',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Messages
                  if (widget.messages.isNotEmpty) ...[
                    for (final msg in widget.messages)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          msg,
                          style: TextStyle(
                            color: Colors.green[300],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],

                  // Balances
                  _BalanceRow(
                    label: 'Cash on hand:',
                    amount: widget.player.cash,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  _BalanceRow(
                    label: 'Bank balance:',
                    amount: widget.player.bank,
                    color: Colors.green[400]!,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '5% interest per day',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Amount input
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      prefixText: '\$ ',
                      prefixStyle: const TextStyle(color: Colors.white),
                      errorText: _errorMessage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.green[400]!),
                      ),
                    ),
                    onChanged: (_) => setState(() => _errorMessage = null),
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.player.cash.dollars > 0 ? _deposit : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('DEPOSIT'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.player.bank.dollars > 0 ? _withdraw : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('WITHDRAW'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Quick action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.player.cash.dollars > 0 ? _depositAll : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green[400],
                            side: BorderSide(color: Colors.green[700]!),
                          ),
                          child: const Text('DEPOSIT ALL'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.player.bank.dollars > 0 ? _withdrawAll : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue[400],
                            side: BorderSide(color: Colors.blue[700]!),
                          ),
                          child: const Text('WITHDRAW ALL'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Leave button
                  TextButton(
                    onPressed: widget.onLeave,
                    child: Text(
                      'LEAVE BANK',
                      style: TextStyle(color: Colors.grey[400]),
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

class _BalanceRow extends StatelessWidget {
  final String label;
  final Money amount;
  final Color color;

  const _BalanceRow({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[400]),
        ),
        Text(
          '$amount',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

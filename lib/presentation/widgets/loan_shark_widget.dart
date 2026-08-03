import 'package:flutter/material.dart';

import '../../core/constants/game_constants.dart';
import '../../core/value_objects/money.dart';
import '../../domain/player/entities/player.dart';

/// Widget for loan shark interactions (pay debt/borrow).
class LoanSharkWidget extends StatefulWidget {
  final Player player;
  final List<String> messages;
  final void Function(Money amount) onPayDebt;
  final void Function(Money amount) onBorrow;
  final VoidCallback onLeave;

  const LoanSharkWidget({
    super.key,
    required this.player,
    this.messages = const [],
    required this.onPayDebt,
    required this.onBorrow,
    required this.onLeave,
  });

  @override
  State<LoanSharkWidget> createState() => _LoanSharkWidgetState();
}

class _LoanSharkWidgetState extends State<LoanSharkWidget> {
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

  Money get _maxBorrow {
    final maxDebt = Money(GameConstants.startDebt * 2);
    final remaining = maxDebt - widget.player.debt;
    return remaining.dollars > 0 ? remaining : Money.zero;
  }

  void _payDebt() {
    final amount = _enteredAmount;
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Enter a valid amount');
      return;
    }
    if (amount > widget.player.cash.dollars) {
      setState(() => _errorMessage = 'You don\'t have that much cash!');
      return;
    }
    if (amount > widget.player.debt.dollars) {
      setState(() => _errorMessage = 'You only owe \$${widget.player.debt.dollars}');
      return;
    }
    setState(() => _errorMessage = null);
    _amountController.clear();
    widget.onPayDebt(Money(amount));
  }

  void _borrow() {
    final amount = _enteredAmount;
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Enter a valid amount');
      return;
    }
    if (amount > _maxBorrow.dollars) {
      setState(() => _errorMessage = 'The shark won\'t lend you that much!');
      return;
    }
    setState(() => _errorMessage = null);
    _amountController.clear();
    widget.onBorrow(Money(amount));
  }

  void _payAll() {
    final payAmount = widget.player.cash > widget.player.debt
        ? widget.player.debt
        : widget.player.cash;
    if (payAmount.dollars > 0) {
      widget.onPayDebt(payAmount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDebt = widget.player.debt.dollars > 0;
    final canBorrow = _maxBorrow.dollars > 0;

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
                      Icon(Icons.attach_money, color: Colors.red[400], size: 32),
                      const SizedBox(width: 12),
                      Text(
                        'THE LOAN SHARK',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[400],
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
                            color: Colors.orange[300],
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
                    label: 'You owe:',
                    amount: widget.player.debt,
                    color: hasDebt ? Colors.red[400]! : Colors.green[400]!,
                  ),
                  const SizedBox(height: 8),
                  if (canBorrow)
                    _BalanceRow(
                      label: 'Can borrow:',
                      amount: _maxBorrow,
                      color: Colors.orange[400]!,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '10% interest per day - PAY UP OR ELSE!',
                    style: TextStyle(
                      color: Colors.red[300],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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
                        borderSide: BorderSide(color: Colors.red[400]!),
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
                          onPressed: hasDebt && widget.player.cash.dollars > 0
                              ? _payDebt
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('PAY DEBT'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: canBorrow ? _borrow : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('BORROW'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Quick action button
                  if (hasDebt && widget.player.cash.dollars > 0)
                    OutlinedButton(
                      onPressed: _payAll,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green[400],
                        side: BorderSide(color: Colors.green[700]!),
                      ),
                      child: Text(
                        widget.player.cash >= widget.player.debt
                            ? 'PAY OFF ENTIRE DEBT'
                            : 'PAY ALL CASH (\$${widget.player.cash.dollars})',
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Leave button
                  TextButton(
                    onPressed: widget.onLeave,
                    child: Text(
                      'LEAVE',
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

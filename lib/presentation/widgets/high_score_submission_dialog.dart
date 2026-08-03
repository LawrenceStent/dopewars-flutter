import 'package:flutter/material.dart';

import '../../domain/game/entities/high_score.dart';
import '../../domain/game/services/high_score_service.dart';
import '../../injection_container.dart';

/// Dialog for submitting a high score.
class HighScoreSubmissionDialog extends StatefulWidget {
  final int netWorth;
  final int turn;
  final VoidCallback onClose;

  const HighScoreSubmissionDialog({
    super.key,
    required this.netWorth,
    required this.turn,
    required this.onClose,
  });

  @override
  State<HighScoreSubmissionDialog> createState() =>
      _HighScoreSubmissionDialogState();
}

class _HighScoreSubmissionDialogState extends State<HighScoreSubmissionDialog> {
  late TextEditingController _nameController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitScore() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a player name')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final service = sl<HighScoreService>();
      final score = HighScore(
        playerName: _nameController.text,
        netWorth: widget.netWorth,
        turn: widget.turn,
        date: DateTime.now(),
      );

      final success = await service.addHighScore(score);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Score submitted! You made the high scores list!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your score did not make the high scores list.')),
          );
        }
        widget.onClose();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting score: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('NEW HIGH SCORE!'),
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.amber[400],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Net Worth: \$${widget.netWorth}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Turn: ${widget.turn}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Enter your name:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              maxLength: 20,
              enabled: !_isSubmitting,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Your name',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber[400]!),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[850],
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : widget.onClose,
          child: const Text('SKIP'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitScore,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[400],
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : const Text('SUBMIT'),
        ),
      ],
    );
  }
}

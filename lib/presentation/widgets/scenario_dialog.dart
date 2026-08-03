import 'package:flutter/material.dart';

import '../../domain/scenario/entities/scenario.dart';

/// Dialog for interactive scenario events.
class ScenarioDialog extends StatelessWidget {
  final Scenario scenario;
  final Function(String choiceId) onChoiceMade;

  const ScenarioDialog({
    super.key,
    required this.scenario,
    required this.onChoiceMade,
  });

  /// Show a scenario dialog.
  static Future<void> show({
    required BuildContext context,
    required Scenario scenario,
    required Function(String choiceId) onChoiceMade,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScenarioDialog(
        scenario: scenario,
        onChoiceMade: (choiceId) {
          Navigator.of(context).pop();
          onChoiceMade(choiceId);
        },
      ),
    );
  }

  /// Get color for scenario category.
  Color _getCategoryColor() {
    switch (scenario.category) {
      case ScenarioCategory.police:
        return Colors.red[400]!;
      case ScenarioCategory.criminal:
        return Colors.yellow[600]!;
      case ScenarioCategory.environmental:
        return Colors.blue[400]!;
      case ScenarioCategory.social:
        return Colors.green[400]!;
    }
  }

  /// Get icon for scenario category.
  IconData _getCategoryIcon() {
    switch (scenario.category) {
      case ScenarioCategory.police:
        return Icons.local_police;
      case ScenarioCategory.criminal:
        return Icons.gavel;
      case ScenarioCategory.environmental:
        return Icons.public;
      case ScenarioCategory.social:
        return Icons.people;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[850],
      title: Row(
        children: [
          Icon(
            _getCategoryIcon(),
            color: _getCategoryColor(),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              scenario.title,
              style: TextStyle(
                color: _getCategoryColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            scenario.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'What do you do?',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        ...scenario.choices.map((choice) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onChoiceMade(choice.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getCategoryColor().withOpacity(0.8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Column(
                children: [
                  Text(
                    choice.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    choice.description,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

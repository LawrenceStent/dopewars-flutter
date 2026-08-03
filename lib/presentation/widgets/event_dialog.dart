import 'package:flutter/material.dart';

import '../../domain/game/services/random_encounter_service.dart';

/// Dialog for displaying random encounter events.
class EventDialog {
  /// Show an encounter event dialog.
  static Future<bool?> showEncounter({
    required BuildContext context,
    required EncounterResult encounter,
  }) {
    final Color accentColor = _getColorForEncounter(encounter.type);

    return showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: accentColor, width: 2),
        ),
        title: Row(
          children: [
            Icon(_getIconForEncounter(encounter.type),
                color: accentColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getTitleForEncounter(encounter.type),
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          encounter.message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Get color for encounter type.
  static Color _getColorForEncounter(EncounterType type) {
    return switch (type) {
      EncounterType.mugged => Colors.red[400]!,
      EncounterType.findDrugs => Colors.green[400]!,
      EncounterType.friendHelps => Colors.blue[400]!,
      EncounterType.policeDogs => Colors.red[700]!,
      EncounterType.findBody => Colors.orange[400]!,
      EncounterType.cheapOffer => Colors.yellow[400]!,
      EncounterType.none => Colors.grey[400]!,
    };
  }

  /// Get icon for encounter type.
  static IconData _getIconForEncounter(EncounterType type) {
    return switch (type) {
      EncounterType.mugged => Icons.warning,
      EncounterType.findDrugs => Icons.star,
      EncounterType.friendHelps => Icons.favorite,
      EncounterType.policeDogs => Icons.gpp_bad,
      EncounterType.findBody => Icons.info,
      EncounterType.cheapOffer => Icons.local_offer,
      EncounterType.none => Icons.info_outline,
    };
  }

  /// Get title for encounter type.
  static String _getTitleForEncounter(EncounterType type) {
    return switch (type) {
      EncounterType.mugged => 'MUGGED!',
      EncounterType.findDrugs => 'LUCKY FIND!',
      EncounterType.friendHelps => 'NEW FRIEND!',
      EncounterType.policeDogs => 'POLICE DOGS!',
      EncounterType.findBody => 'FOUND SOMETHING...',
      EncounterType.cheapOffer => 'OPPORTUNITY!',
      EncounterType.none => 'EVENT',
    };
  }
}

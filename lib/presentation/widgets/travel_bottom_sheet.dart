import 'package:flutter/material.dart';

import '../../domain/location/entities/location.dart';
import '../../domain/player/entities/player.dart';

/// Bottom sheet for selecting travel destination on mobile.
class TravelBottomSheet extends StatelessWidget {
  final Player player;
  final void Function(int locationIndex) onLocationSelected;
  final VoidCallback? onVisitBank;
  final VoidCallback? onVisitLoanShark;

  const TravelBottomSheet({
    super.key,
    required this.player,
    required this.onLocationSelected,
    this.onVisitBank,
    this.onVisitLoanShark,
  });

  static void show(
    BuildContext context, {
    required Player player,
    required void Function(int) onLocationSelected,
    VoidCallback? onVisitBank,
    VoidCallback? onVisitLoanShark,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      builder: (context) => TravelBottomSheet(
        player: player,
        onLocationSelected: onLocationSelected,
        onVisitBank: onVisitBank,
        onVisitLoanShark: onVisitLoanShark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'SELECT DESTINATION',
                style: TextStyle(
                  color: Colors.green[400],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Location grid
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: DefaultLocations.count,
                itemBuilder: (context, index) {
                  final location = DefaultLocations.byIndex(index);
                  final isCurrentLocation = index == player.locationIndex;

                  return _LocationCard(
                    location: location,
                    index: index,
                    isCurrentLocation: isCurrentLocation,
                    onSelected: () {
                      onLocationSelected(index);
                      Navigator.pop(context);
                    },
                    onVisitBank: isCurrentLocation ? onVisitBank : null,
                    onVisitLoanShark: isCurrentLocation ? onVisitLoanShark : null,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LocationCard extends StatelessWidget {
  final Location location;
  final int index;
  final bool isCurrentLocation;
  final VoidCallback onSelected;
  final VoidCallback? onVisitBank;
  final VoidCallback? onVisitLoanShark;

  const _LocationCard({
    required this.location,
    required this.index,
    required this.isCurrentLocation,
    required this.onSelected,
    this.onVisitBank,
    this.onVisitLoanShark,
  });

  String _getRiskLevel() {
    // Estimate risk based on police presence and location multiplier
    // Higher police presence = higher risk
    if (location.policePresence > 70) return 'HIGH';
    if (location.policePresence > 40) return 'MEDIUM';
    return 'LOW';
  }

  Color _getRiskColor() {
    final risk = _getRiskLevel();
    switch (risk) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isCurrentLocation ? Colors.green[900] : Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              location.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isCurrentLocation ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.country,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Drug count
                      Chip(
                        backgroundColor: Colors.blue[900],
                        label: Text(
                          '${location.drugCount} drugs',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const SizedBox(width: 8),
                      // Police presence
                      Chip(
                        backgroundColor: _getRiskColor(),
                        label: Text(
                          '${_getRiskLevel()} risk',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                  if (!isCurrentLocation)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Price multiplier: ${location.priceMultiplier.toStringAsFixed(1)}x',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            trailing: isCurrentLocation
                ? Icon(Icons.location_on, color: Colors.green[400])
                : Icon(Icons.arrow_forward, color: Colors.grey[600]),
            enabled: !isCurrentLocation,
            onTap: isCurrentLocation ? null : onSelected,
          ),
          // Special location buttons (only if current location)
          if (isCurrentLocation) ...[
            const Divider(height: 1, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (location.hasFacility(LocationFacility.bank) && onVisitBank != null)
                    _SpecialButton(
                      icon: Icons.account_balance,
                      label: 'BANK',
                      color: Colors.green,
                      onPressed: onVisitBank!,
                    ),
                  if (location.hasFacility(LocationFacility.loanShark) &&
                      onVisitLoanShark != null)
                    _SpecialButton(
                      icon: Icons.attach_money,
                      label: 'LOAN SHARK',
                      color: Colors.red,
                      onPressed: onVisitLoanShark!,
                    ),
                  if (location.hasFacility(LocationFacility.gunShop))
                    _SpecialButton(
                      icon: Icons.gpp_good,
                      label: 'GUN SHOP',
                      color: Colors.orange,
                      onPressed: () {
                        // TODO: Implement gun shop visit
                      },
                    ),
                  if (location.hasFacility(LocationFacility.roughPub))
                    _SpecialButton(
                      icon: Icons.local_bar,
                      label: 'PUB',
                      color: Colors.purple,
                      onPressed: () {
                        // TODO: Implement pub visit
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SpecialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _SpecialButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      onPressed: onPressed,
    );
  }
}

import 'package:flutter/material.dart';

import '../../domain/location/entities/location.dart';

/// Widget for selecting a location to travel to.
class LocationSelector extends StatelessWidget {
  final int currentLocation;
  final void Function(int index) onLocationSelected;
  final VoidCallback? onVisitBank;
  final VoidCallback? onVisitLoanShark;
  final VoidCallback? onVisitGunShop;
  final VoidCallback? onVisitPub;
  final VoidCallback? onVisitNpcs;

  const LocationSelector({
    super.key,
    required this.currentLocation,
    required this.onLocationSelected,
    this.onVisitBank,
    this.onVisitLoanShark,
    this.onVisitGunShop,
    this.onVisitPub,
    this.onVisitNpcs,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: DefaultLocations.count,
      itemBuilder: (context, index) {
        final location = DefaultLocations.byIndex(index);
        final isCurrentLocation = index == currentLocation;

        return Card(
          color: isCurrentLocation ? Colors.green[900] : Colors.grey[850],
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  location.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        isCurrentLocation ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  _getLocationInfo(location, index),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                trailing: isCurrentLocation
                    ? Icon(Icons.location_on, color: Colors.green[400])
                    : Icon(Icons.arrow_forward, color: Colors.grey[600]),
                enabled: !isCurrentLocation,
                onTap: isCurrentLocation
                    ? null
                    : () => onLocationSelected(index),
              ),
              // Show special location buttons if at this location
              if (isCurrentLocation) _buildSpecialLocationButtons(index),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecialLocationButtons(int locationIndex) {
    final buttons = <Widget>[];

    if (locationIndex == DefaultLocations.bankIndex() && onVisitBank != null) {
      buttons.add(
        _SpecialLocationButton(
          icon: Icons.account_balance,
          label: 'BANK',
          color: Colors.green,
          onPressed: onVisitBank!,
        ),
      );
    }

    if (locationIndex == DefaultLocations.loanSharkIndex() &&
        onVisitLoanShark != null) {
      buttons.add(
        _SpecialLocationButton(
          icon: Icons.attach_money,
          label: 'LOAN SHARK',
          color: Colors.red,
          onPressed: onVisitLoanShark!,
        ),
      );
    }

    if (locationIndex == DefaultLocations.gunShopIndex() && onVisitGunShop != null) {
      buttons.add(
        _SpecialLocationButton(
          icon: Icons.gpp_good,
          label: 'GUN SHOP',
          color: Colors.orange,
          onPressed: onVisitGunShop!,
        ),
      );
    }

    if (locationIndex == DefaultLocations.roughPubIndex() && onVisitPub != null) {
      buttons.add(
        _SpecialLocationButton(
          icon: Icons.local_bar,
          label: 'PUB',
          color: Colors.purple,
          onPressed: onVisitPub!,
        ),
      );
    }

    // CONTACTS button (available at all locations)
    if (onVisitNpcs != null) {
      buttons.add(
        _SpecialLocationButton(
          icon: Icons.people,
          label: 'CONTACTS',
          color: Colors.cyan,
          onPressed: onVisitNpcs!,
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: buttons,
      ),
    );
  }

  String _getLocationInfo(Location location, int index) {
    final parts = <String>[];

    // Police presence
    final policeLevel = _getPoliceLevel(location.policePresence);
    parts.add('Police: $policeLevel');

    // Special locations
    if (index == DefaultLocations.bankIndex()) {
      parts.add('Bank');
    }
    if (index == DefaultLocations.loanSharkIndex()) {
      parts.add('Loan Shark');
    }
    if (index == DefaultLocations.gunShopIndex()) {
      parts.add('Gun Shop');
    }
    if (index == DefaultLocations.roughPubIndex()) {
      parts.add('Pub');
    }

    return parts.join(' | ');
  }

  String _getPoliceLevel(int presence) {
    if (presence <= 10) return 'Low';
    if (presence <= 30) return 'Medium';
    if (presence <= 60) return 'High';
    return 'Very High';
  }
}

class _SpecialLocationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _SpecialLocationButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}

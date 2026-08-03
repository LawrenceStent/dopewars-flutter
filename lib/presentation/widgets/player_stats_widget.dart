import 'package:flutter/material.dart';

import '../../core/constants/game_constants.dart';
import '../../core/utils/responsive_layout.dart';
import '../../domain/location/entities/location.dart';
import '../../domain/player/entities/player.dart';

/// Widget displaying player stats.
class PlayerStatsWidget extends StatelessWidget {
  final Player player;
  final bool compact;

  const PlayerStatsWidget({
    super.key,
    required this.player,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final location = DefaultLocations.byIndex(player.locationIndex);

    if (compact) {
      return _buildCompactStats(location, context);
    }
    return _buildFullStats(location, context);
  }

  Widget _buildCompactStats(Location location, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveLayout.responsivePadding(
          context,
          mobile: 12,
          tablet: 16,
          desktop: 20,
        ),
        vertical: ResponsiveLayout.paddingSm,
      ),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Name and location
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveLayout.responsiveFontSize(
                    context,
                    mobile: 14,
                    tablet: 16,
                    desktop: 18,
                  ),
                ),
              ),
              Text(
                location.name,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: ResponsiveLayout.responsiveFontSize(
                    context,
                    mobile: 11,
                    tablet: 12,
                    desktop: 13,
                  ),
                ),
              ),
            ],
          ),
          // Turn and cash
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Day ${player.turn}/${GameConstants.numTurns}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: ResponsiveLayout.responsiveFontSize(
                    context,
                    mobile: 11,
                    tablet: 12,
                    desktop: 13,
                  ),
                ),
              ),
              Text(
                player.cash.toString(),
                style: TextStyle(
                  color: Colors.green[400],
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveLayout.responsiveFontSize(
                    context,
                    mobile: 13,
                    tablet: 14,
                    desktop: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFullStats(Location location, BuildContext context) {
    final padding = ResponsiveLayout.responsivePadding(context);
    final gap = ResponsiveLayout.responsiveGap(context);

    return Container(
      padding: EdgeInsets.all(padding),
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  player.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveLayout.responsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 24,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Day ${player.turn}/${GameConstants.numTurns}',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: ResponsiveLayout.responsiveFontSize(
                      context,
                      mobile: 11,
                      tablet: 12,
                      desktop: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: gap / 4),
          Text(
            location.name,
            style: TextStyle(
              color: Colors.green[400],
              fontSize: ResponsiveLayout.responsiveFontSize(
                context,
                mobile: 13,
                tablet: 14,
                desktop: 15,
              ),
            ),
          ),
          SizedBox(height: gap),

          // Financial stats
          _StatRow(
            label: 'Cash',
            value: player.cash.toString(),
            valueColor: Colors.green[400]!,
            context: context,
          ),
          _StatRow(
            label: 'Bank',
            value: player.bank.toString(),
            valueColor: Colors.blue[300]!,
            context: context,
          ),
          _StatRow(
            label: 'Debt',
            value: player.debt.toString(),
            valueColor: Colors.red[400]!,
            context: context,
          ),
          SizedBox(height: gap / 2),
          _StatRow(
            label: 'Net Worth',
            value: player.netWorth.toString(),
            valueColor: player.netWorth.isNegative
                ? Colors.red[400]!
                : Colors.green[400]!,
            bold: true,
            context: context,
          ),
          SizedBox(height: gap),

          // Health bar
          _buildHealthBar(context),
          SizedBox(height: gap / 2),

          // Carrying capacity
          _buildCapacityBar(context),

          // Guns owned
          if (player.totalGunsCarried > 0) ...[
            SizedBox(height: gap / 2),
            Text(
              'Guns: ${player.totalGunsCarried}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: ResponsiveLayout.responsiveFontSize(
                  context,
                  mobile: 12,
                  tablet: 13,
                  desktop: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthBar(BuildContext context) {
    final fontSize = ResponsiveLayout.responsiveFontSize(
      context,
      mobile: 11,
      tablet: 12,
      desktop: 13,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Health',
              style: TextStyle(color: Colors.grey[400], fontSize: fontSize),
            ),
            Text(
              '${player.health.value}%',
              style: TextStyle(color: Colors.grey[400], fontSize: fontSize),
            ),
          ],
        ),
        SizedBox(height: ResponsiveLayout.paddingSm),
        LinearProgressIndicator(
          value: player.health.percentage,
          backgroundColor: Colors.grey[800],
          minHeight: 6,
          valueColor: AlwaysStoppedAnimation(
            player.health.value > 50
                ? Colors.green
                : player.health.value > 25
                    ? Colors.orange
                    : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildCapacityBar(BuildContext context) {
    final used = player.totalDrugsCarried + player.gunSpaceUsed;
    final total = player.coatSize.value;
    final percentage = total > 0 ? used / total : 0.0;

    final fontSize = ResponsiveLayout.responsiveFontSize(
      context,
      mobile: 11,
      tablet: 12,
      desktop: 13,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Capacity',
              style: TextStyle(color: Colors.grey[400], fontSize: fontSize),
            ),
            Text(
              '$used/$total',
              style: TextStyle(color: Colors.grey[400], fontSize: fontSize),
            ),
          ],
        ),
        SizedBox(height: ResponsiveLayout.paddingSm),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[800],
          minHeight: 6,
          valueColor: AlwaysStoppedAnimation(
            percentage < 0.7
                ? Colors.blue
                : percentage < 0.9
                    ? Colors.orange
                    : Colors.red,
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool bold;
  final BuildContext context;

  const _StatRow({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.context,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveLayout.responsiveFontSize(
      this.context,
      mobile: 13,
      tablet: 14,
      desktop: 15,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveLayout.paddingXs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:equatable/equatable.dart';

import '../../trading/entities/drug.dart';
import 'location.dart';

/// Tracks supply levels for a drug at a location.
/// Used to implement dynamic pricing based on player activity.
class DrugSupply extends Equatable {
  final DrugType drugType;
  final LocationType location;

  /// Current supply level (0-200, starts at 100).
  final int supply;

  const DrugSupply({
    required this.drugType,
    required this.location,
    this.supply = 100,
  });

  /// Supply factor for price calculation.
  /// supply=100 -> 1.0 (normal)
  /// supply=50  -> 1.5 (scarce, prices up)
  /// supply=150 -> 0.75 (surplus, prices down)
  double get supplyFactor => (100.0 / supply).clamp(0.5, 2.0);

  /// Reduce supply when player buys.
  DrugSupply onBuy(int quantity) {
    return DrugSupply(
      drugType: drugType,
      location: location,
      supply: (supply - quantity).clamp(0, 200),
    );
  }

  /// Increase supply when player sells (market absorbs half).
  DrugSupply onSell(int quantity) {
    return DrugSupply(
      drugType: drugType,
      location: location,
      supply: (supply + (quantity * 0.5).round()).clamp(0, 200),
    );
  }

  /// Per-turn natural supply recovery.
  DrugSupply applyRecovery({int recoveryAmount = 10}) {
    return DrugSupply(
      drugType: drugType,
      location: location,
      supply: (supply + recoveryAmount).clamp(0, 200),
    );
  }

  @override
  List<Object?> get props => [drugType, location, supply];
}

/// Tracks supply/demand state across all locations.
class MarketSupplyState extends Equatable {
  /// Supply levels keyed by "locationIndex:drugIndex".
  final Map<String, DrugSupply> supplies;

  const MarketSupplyState({this.supplies = const {}});

  static String _key(LocationType location, DrugType drug) =>
      '${location.index}:${drug.index}';

  /// Get supply for a drug at a location.
  DrugSupply getSupply(LocationType location, DrugType drug) =>
      supplies[_key(location, drug)] ??
      DrugSupply(drugType: drug, location: location);

  /// Get supply factor for price calculation.
  double getSupplyFactor(LocationType location, DrugType drug) =>
      getSupply(location, drug).supplyFactor;

  /// Update supply after a buy.
  MarketSupplyState onBuy(LocationType location, DrugType drug, int quantity) {
    final key = _key(location, drug);
    final current = getSupply(location, drug);
    final updated = Map<String, DrugSupply>.from(supplies);
    updated[key] = current.onBuy(quantity);
    return MarketSupplyState(supplies: updated);
  }

  /// Update supply after a sell.
  MarketSupplyState onSell(LocationType location, DrugType drug, int quantity) {
    final key = _key(location, drug);
    final current = getSupply(location, drug);
    final updated = Map<String, DrugSupply>.from(supplies);
    updated[key] = current.onSell(quantity);
    return MarketSupplyState(supplies: updated);
  }

  /// Apply per-turn recovery to all supplies.
  MarketSupplyState applyRecovery() {
    final updated = Map<String, DrugSupply>.from(supplies);
    for (final entry in updated.entries) {
      updated[entry.key] = entry.value.applyRecovery();
    }
    return MarketSupplyState(supplies: updated);
  }

  @override
  List<Object?> get props => [supplies];
}

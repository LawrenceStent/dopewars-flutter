import 'package:equatable/equatable.dart';

import '../../../core/value_objects/money.dart';
import 'drug.dart';

/// Represents a special deal on a drug.
enum DealType {
  /// Normal price range.
  normal,

  /// Price is divided by 4 (cheap deal).
  cheap,

  /// Price is multiplied by 4 (expensive/bust).
  expensive,
}

/// Represents the current price of a drug at a location.
class DrugPrice extends Equatable {
  final DrugType drugType;
  final Money price;
  final DealType dealType;
  final String? message;

  const DrugPrice({
    required this.drugType,
    required this.price,
    required this.dealType,
    this.message,
  });

  /// Check if this is a special deal.
  bool get isSpecialDeal => dealType != DealType.normal;

  @override
  List<Object?> get props => [drugType, price, dealType, message];

  @override
  String toString() => 'DrugPrice(${drugType.name}: $price, $dealType)';
}

/// Represents the drug market at a specific location.
/// Contains all available drugs and their current prices.
class DrugMarket extends Equatable {
  final int locationIndex;
  final Map<DrugType, DrugPrice> prices;

  const DrugMarket({
    required this.locationIndex,
    required this.prices,
  });

  /// Get price for a specific drug (null if not available).
  DrugPrice? getPrice(DrugType type) => prices[type];

  /// Check if a drug is available at this market.
  bool hasPrice(DrugType type) => prices.containsKey(type);

  /// Get all available drug types.
  List<DrugType> get availableDrugs => prices.keys.toList();

  /// Get all special deals.
  List<DrugPrice> get specialDeals =>
      prices.values.where((p) => p.isSpecialDeal).toList();

  @override
  List<Object?> get props => [locationIndex, prices];
}

import '../../../core/constants/game_constants.dart';
import '../../../core/utils/random_generator.dart';
import '../../../core/value_objects/money.dart';
import '../../location/entities/location.dart';
import '../../location/entities/supply_demand.dart';
import '../entities/drug.dart';
import '../entities/drug_market.dart';

/// Service for generating drug prices at locations.
/// Ported from GenerateDrugsHere() in serverside.c lines 3205-3252.
class PriceGenerator {
  final RandomGenerator _random;
  final List<Drug> _drugs;
  final List<Location> _locations;

  PriceGenerator({
    required RandomGenerator random,
    List<Drug>? drugs,
    List<Location>? locations,
  })  : _random = random,
        _drugs = drugs ?? DefaultDrugs.all,
        _locations = locations ?? DefaultLocations.all;

  /// Generate the drug market for a specific location.
  ///
  /// Uses location multiplier, supply/demand factors, and transaction taxes
  /// to calculate realistic prices based on the modernization system.
  DrugMarket generateMarket(
    int locationIndex, {
    MarketSupplyState supplyState = const MarketSupplyState(),
  }) {
    final location = _locations[locationIndex];
    final prices = <DrugType, DrugPrice>{};

    // Determine if there will be a special deal at this location
    final hasSpecialDeal =
        _random.nextDouble() < GameConstants.specialDealChance;
    DrugType? specialDealDrug;
    DealType? specialDealType;

    if (hasSpecialDeal) {
      // Pick a random drug for the special deal
      final eligibleDrugs = _drugs
          .where((d) => d.canBeCheap || d.canBeExpensive)
          .toList();
      if (eligibleDrugs.isNotEmpty) {
        final chosen = _random.pickFrom(eligibleDrugs);
        specialDealDrug = chosen.type;
        // Determine deal type based on drug's capabilities
        if (chosen.canBeCheap && chosen.canBeExpensive) {
          specialDealType = _random.nextBool() ? DealType.cheap : DealType.expensive;
        } else if (chosen.canBeCheap) {
          specialDealType = DealType.cheap;
        } else {
          specialDealType = DealType.expensive;
        }
      }
    }

    // Generate prices for all drugs available at this location
    for (var i = 0; i < _drugs.length; i++) {
      // Check if drug is available at this location
      if (!location.hasDrug(i)) {
        continue;
      }

      final drug = _drugs[i];
      final isSpecialDeal = drug.type == specialDealDrug;

      final drugPrice = _generateDrugPrice(
        drug,
        location,
        supplyState,
        isSpecialDeal ? specialDealType! : DealType.normal,
      );

      prices[drug.type] = drugPrice;
    }

    return DrugMarket(
      locationIndex: locationIndex,
      prices: prices,
    );
  }

  /// Generate a price for a single drug at a location.
  ///
  /// Formula: basePrice * locationMultiplier * supplyFactor * (1 + transactionTax)
  DrugPrice _generateDrugPrice(
    Drug drug,
    Location location,
    MarketSupplyState supplyState,
    DealType dealType,
  ) {
    // Generate random base price within drug's range
    var price = Money(_random.nextInt(
      drug.minPrice.dollars,
      drug.maxPrice.dollars,
    ));

    String? message;

    // Apply special deal modifiers
    switch (dealType) {
      case DealType.cheap:
        price = price.integerDivide(GameConstants.cheapDivide);
        message = drug.cheapMessage;
        break;
      case DealType.expensive:
        price = price * GameConstants.expensiveMultiply;
        // Pick one of the expensive messages
        message = _random.nextBool()
            ? DrugMessages.expensiveMessage1.replaceAll('%drug', drug.name)
            : DrugMessages.expensiveMessage2.replaceAll('%drug', drug.name);
        break;
      case DealType.normal:
        break;
    }

    // Apply location multiplier (e.g., 0.3x in Lagos, 1.8x in Tokyo)
    final locationMultiplier = location.priceMultiplier;
    price = Money.fromCents((price.cents * locationMultiplier).toInt());

    // Apply supply/demand factor
    final supplyFactor = supplyState.getSupplyFactor(location.type, drug.type);
    price = Money.fromCents((price.cents * supplyFactor).toInt());

    // Apply transaction tax (e.g., 2% in Lagos, 10% in Tokyo)
    final taxRate = location.transactionTaxPercent / 100.0;
    price = Money.fromCents((price.cents * (1 + taxRate)).toInt());

    return DrugPrice(
      drugType: drug.type,
      price: price,
      dealType: dealType,
      message: message,
    );
  }
}

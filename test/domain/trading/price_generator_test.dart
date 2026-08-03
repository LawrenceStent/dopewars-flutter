import 'package:flutter_test/flutter_test.dart';

import 'package:dopewars_flutter/core/utils/random_generator.dart';
import 'package:dopewars_flutter/core/value_objects/money.dart';
import 'package:dopewars_flutter/domain/location/entities/location.dart';
import 'package:dopewars_flutter/domain/location/entities/supply_demand.dart';
import 'package:dopewars_flutter/domain/trading/entities/drug.dart';
import 'package:dopewars_flutter/domain/trading/services/price_generator.dart';

void main() {
  group('PriceGenerator with Location Multipliers', () {
    late PriceGenerator priceGenerator;
    late RandomGenerator randomGenerator;

    setUp(() {
      randomGenerator = DeterministicRandomGenerator();
      priceGenerator = PriceGenerator(random: randomGenerator);
    });

    test('applies location price multiplier', () {
      // New York has 1.0x multiplier
      final nyMarket = priceGenerator.generateMarket(0);

      // Lagos has 0.3x multiplier
      final lagosMarket = priceGenerator.generateMarket(10);

      // For same drug, Lagos price should be lower than NY
      final nyCocaine = nyMarket.getPrice(DrugType.cocaine);
      final lagosCocaine = lagosMarket.getPrice(DrugType.cocaine);

      expect(nyCocaine, isNotNull);
      expect(lagosCocaine, isNotNull);
      expect(lagosCocaine!.price.dollars, lessThan(nyCocaine!.price.dollars));
    });

    test('Tokyo has highest prices (1.8x multiplier)', () {
      final tokyoMarket = priceGenerator.generateMarket(5);
      final nyMarket = priceGenerator.generateMarket(0);

      final tokyoPrice = tokyoMarket.getPrice(DrugType.cocaine);
      final nyPrice = nyMarket.getPrice(DrugType.cocaine);

      expect(tokyoPrice!.price.dollars, greaterThan(nyPrice!.price.dollars));
    });

    test('Lagos has lowest prices (0.3x multiplier)', () {
      final lagosMarket = priceGenerator.generateMarket(10);
      final tokyoMarket = priceGenerator.generateMarket(5);

      final lagosPrice = lagosMarket.getPrice(DrugType.cocaine);
      final tokyoPrice = tokyoMarket.getPrice(DrugType.cocaine);

      expect(lagosPrice!.price.dollars, lessThan(tokyoPrice!.price.dollars));
    });

    test('supply factor affects prices', () {
      // Normal supply
      final normalSupply = const MarketSupplyState();
      final market1 = priceGenerator.generateMarket(0, supplyState: normalSupply);

      // Scarce supply (50 units instead of 100)
      final scarceSupply = MarketSupplyState(
        supplies: {
          '0:1': DrugSupply(
            drugType: DrugType.cocaine,
            location: LocationType.newYork,
            supply: 50, // Scarce
          ),
        },
      );
      final market2 = priceGenerator.generateMarket(0, supplyState: scarceSupply);

      final price1 = market1.getPrice(DrugType.cocaine);
      final price2 = market2.getPrice(DrugType.cocaine);

      // Scarce supply should have higher price
      expect(price2!.price.dollars, greaterThan(price1!.price.dollars));
    });

    test('transaction tax is applied to final price', () {
      // New York has 5% tax
      final nyMarket = priceGenerator.generateMarket(0);
      final nyPrice = nyMarket.getPrice(DrugType.cocaine);

      // Lagos has 2% tax
      final lagosMarket = priceGenerator.generateMarket(10);
      final lagosPrice = lagosMarket.getPrice(DrugType.cocaine);

      // Both should have tax applied (prices include tax)
      expect(nyPrice, isNotNull);
      expect(lagosPrice, isNotNull);
      // Lagos price should still be lower despite lower tax
      expect(lagosPrice!.price.dollars, lessThan(nyPrice!.price.dollars));
    });
  });

  group('Supply/Demand Integration', () {
    late PriceGenerator priceGenerator;
    late RandomGenerator randomGenerator;

    setUp(() {
      randomGenerator = DeterministicRandomGenerator();
      priceGenerator = PriceGenerator(random: randomGenerator);
    });

    test('buying drugs reduces supply', () {
      var supply = const MarketSupplyState();

      // Simulate buying 50 cocaine in New York
      supply = supply.onBuy(LocationType.newYork, DrugType.cocaine, 50);

      // Supply should decrease from 100 to 50
      final cocaine = supply.getSupply(LocationType.newYork, DrugType.cocaine);
      expect(cocaine.supply, equals(50));
    });

    test('selling drugs increases supply', () {
      var supply = const MarketSupplyState();

      // Simulate selling 50 cocaine in New York (adds 25, since absorbed at 0.5x)
      supply = supply.onSell(LocationType.newYork, DrugType.cocaine, 50);

      // Supply should increase from 100 to 125 (50 * 0.5 absorbed)
      final cocaine = supply.getSupply(LocationType.newYork, DrugType.cocaine);
      expect(cocaine.supply, equals(125));
    });

    test('supply recovers over time', () {
      var supply = const MarketSupplyState();

      // Start at low supply
      supply = supply.onBuy(LocationType.newYork, DrugType.cocaine, 80);
      expect(supply.getSupply(LocationType.newYork, DrugType.cocaine).supply, equals(20));

      // Recover for multiple turns
      supply = supply.applyRecovery();
      expect(supply.getSupply(LocationType.newYork, DrugType.cocaine).supply, equals(30));

      supply = supply.applyRecovery();
      expect(supply.getSupply(LocationType.newYork, DrugType.cocaine).supply, equals(40));
    });

    test('supply factor affects price correctly', () {
      // Low supply = higher prices
      final lowSupply = MarketSupplyState(
        supplies: {
          '0:1': DrugSupply(
            drugType: DrugType.cocaine,
            location: LocationType.newYork,
            supply: 25, // Very scarce
          ),
        },
      );

      final lowSupplyFactor = lowSupply.getSupplyFactor(
        LocationType.newYork,
        DrugType.cocaine,
      );

      // Supply factor = 100 / 25 = 4.0 (clamped to 2.0 max)
      expect(lowSupplyFactor, equals(2.0));

      // High supply = lower prices
      final highSupply = MarketSupplyState(
        supplies: {
          '0:1': DrugSupply(
            drugType: DrugType.cocaine,
            location: LocationType.newYork,
            supply: 150, // Surplus
          ),
        },
      );

      final highSupplyFactor = highSupply.getSupplyFactor(
        LocationType.newYork,
        DrugType.cocaine,
      );

      // Supply factor = 100 / 150 = 0.67 (clamped to 0.5 min)
      expect(highSupplyFactor, lessThan(1.0));
    });
  });
}

/// Deterministic random generator for testing
class DeterministicRandomGenerator implements RandomGenerator {
  int _nextValue = 50; // Start with middle value

  @override
  int nextInt(int min, int max) {
    final range = max - min + 1;
    final value = (_nextValue % range) + min;
    _nextValue += 13; // Prime number for variety
    return value;
  }

  @override
  double nextDouble() => 0.5;

  @override
  bool nextBool([double probability = 0.5]) => _nextValue.isEven;

  @override
  T pickFrom<T>(List<T> list) => list[_nextValue % list.length];

  @override
  List<T> shuffle<T>(List<T> list) => list;
}

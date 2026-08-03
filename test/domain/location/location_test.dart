import 'package:flutter_test/flutter_test.dart';

import 'package:dopewars_flutter/domain/location/entities/location.dart';

void main() {
  group('Location System', () {
    test('12 global locations exist', () {
      expect(DefaultLocations.count, equals(12));
    });

    test('locations have correct price multipliers', () {
      final newYork = DefaultLocations.byIndex(0);
      final lagos = DefaultLocations.byIndex(10);
      final tokyo = DefaultLocations.byIndex(5);

      expect(newYork.priceMultiplier, equals(1.0));
      expect(lagos.priceMultiplier, equals(0.3));
      expect(tokyo.priceMultiplier, equals(1.8));
    });

    test('locations have transaction taxes', () {
      final newYork = DefaultLocations.byIndex(0);
      final tokyo = DefaultLocations.byIndex(5);

      expect(newYork.transactionTaxPercent, equals(5));
      expect(tokyo.transactionTaxPercent, equals(10));
    });

    test('special locations have correct facilities', () {
      final newYork = DefaultLocations.byIndex(0);

      expect(newYork.hasFacility(LocationFacility.bank), isTrue);
      expect(newYork.hasFacility(LocationFacility.loanShark), isTrue);
    });

    test('helper methods find special locations by facility', () {
      final bankIndex = DefaultLocations.bankIndex();
      final loanSharkIndex = DefaultLocations.loanSharkIndex();

      expect(bankIndex, equals(0)); // New York
      expect(loanSharkIndex, equals(0)); // New York
    });

    test('drug availability varies by location', () {
      final newYork = DefaultLocations.byIndex(0);
      final darkWeb = DefaultLocations.byIndex(11);

      // New York has some drugs but not all
      expect(newYork.drugCount, greaterThan(0));
      expect(newYork.drugCount, lessThan(12));

      // Dark Web has all drugs
      expect(darkWeb.drugCount, equals(12));
    });

    test('locations are grouped by region', () {
      final newYork = DefaultLocations.byIndex(0);
      final lagos = DefaultLocations.byIndex(10);
      final tokyo = DefaultLocations.byIndex(5);

      expect(newYork.region, equals(Region.northAmerica));
      expect(lagos.region, equals(Region.africa));
      expect(tokyo.region, equals(Region.asia));
    });
  });
}

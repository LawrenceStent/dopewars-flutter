import 'package:flutter_test/flutter_test.dart';

import 'package:dopewars_flutter/domain/agency/entities/agency.dart';
import 'package:dopewars_flutter/domain/reputation/entities/reputation.dart';

void main() {
  group('PlayerReputation', () {
    test('starts with zero reputation and heat', () {
      const reputation = PlayerReputation();

      expect(reputation.reputation, equals(0));
      expect(reputation.globalHeat, equals(0));
      expect(reputation.maxWantedLevel, equals(0));
    });

    test('reputation is clamped to 0-100', () {
      const base = PlayerReputation(reputation: 50);

      final increased = base.addReputation(100); // Try to add 100
      expect(increased.reputation, equals(100)); // Clamped to max

      final decreased = base.addReputation(-100); // Try to subtract 100
      expect(decreased.reputation, equals(0)); // Clamped to min
    });

    test('heat is clamped to 0-100', () {
      const base = PlayerReputation(globalHeat: 50);

      final increased = base.addHeat(100);
      expect(increased.globalHeat, equals(100));

      final decreased = base.addHeat(-100);
      expect(decreased.globalHeat, equals(0));
    });

    test('wanted level per agency is tracked', () {
      const base = PlayerReputation();

      final wanted = base.addWantedLevel(AgencyType.dea, 25);
      expect(wanted.getWantedLevel(AgencyType.dea), equals(25));
      expect(wanted.getWantedLevel(AgencyType.interpol), equals(0)); // Not set
    });

    test('Interpol flag set when wanted > 50', () {
      const base = PlayerReputation();

      final wanted30 = base.addWantedLevel(AgencyType.interpol, 30);
      expect(wanted30.isWantedByInterpol, isFalse);

      final wanted60 = base.addWantedLevel(AgencyType.interpol, 60);
      expect(wanted60.isWantedByInterpol, isTrue);
    });

    test('heat decays per turn', () {
      const base = PlayerReputation(globalHeat: 50);

      final decayed = base.applyHeatDecay();
      expect(decayed.globalHeat, equals(48)); // Decreased by 2

      final decayed5Turns = base
          .applyHeatDecay()
          .applyHeatDecay()
          .applyHeatDecay()
          .applyHeatDecay()
          .applyHeatDecay();
      expect(decayed5Turns.globalHeat, equals(40)); // Decreased by 10 (2*5)
    });

    test('wanted levels decay per turn', () {
      const base = PlayerReputation();
      final wanted = base.addWantedLevel(AgencyType.dea, 50);

      final decayed = wanted.applyHeatDecay();
      expect(decayed.getWantedLevel(AgencyType.dea), equals(49)); // Decreased by 1
    });

    test('wanted levels at zero are removed', () {
      const base = PlayerReputation();
      final wanted = base.addWantedLevel(AgencyType.dea, 1);

      final decayed = wanted.applyHeatDecay();
      expect(decayed.getWantedLevel(AgencyType.dea), equals(0)); // Removed

      expect(decayed.agencyWantedLevels.isEmpty, isTrue);
    });

    test('max wanted level returns highest across all agencies', () {
      const base = PlayerReputation();
      final wanted = base
          .addWantedLevel(AgencyType.dea, 30)
          .addWantedLevel(AgencyType.interpol, 75)
          .addWantedLevel(AgencyType.nypd, 20);

      expect(wanted.maxWantedLevel, equals(75)); // Interpol has highest
    });

    test('copyWith updates specific fields', () {
      const original = PlayerReputation(reputation: 50, globalHeat: 30);

      final updated = original.copyWith(reputation: 100);
      expect(updated.reputation, equals(100));
      expect(updated.globalHeat, equals(30)); // Unchanged
    });
  });
}

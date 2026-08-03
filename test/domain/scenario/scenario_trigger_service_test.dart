import 'package:flutter_test/flutter_test.dart';

import 'package:dopewars_flutter/core/utils/random_generator.dart';
import 'package:dopewars_flutter/domain/location/entities/location.dart';
import 'package:dopewars_flutter/domain/scenario/entities/scenario.dart';
import 'package:dopewars_flutter/domain/scenario/services/scenario_trigger_service.dart';

void main() {
  group('ScenarioTriggerService', () {
    late MockRandomGenerator mockRandom;
    late ScenarioTriggerService service;

    setUp(() {
      mockRandom = MockRandomGenerator(doubleValues: [0.0]);
      service = ScenarioTriggerService(random: mockRandom);
    });

    test('returns null when no candidates match location', () {
      final result = service.rollForScenario(
        location: LocationType.london,
        heat: 0,
        playerDrugCount: 0,
        recentlyTriggered: {},
      );
      expect(result, isNull);
    });

    test('filters by minimum heat to trigger', () {
      // Random patrol requires heat >= 20
      mockRandom = MockRandomGenerator(doubleValues: [0.05]); // Low enough to pass probability
      service = ScenarioTriggerService(random: mockRandom);

      final result = service.rollForScenario(
        location: LocationType.losAngeles,
        heat: 10, // Below minimum
        playerDrugCount: 0,
        recentlyTriggered: {},
      );

      expect(result, isNull);
    });

    test('triggers scenario above minimum heat', () {
      // Random patrol requires heat >= 20
      mockRandom = MockRandomGenerator(doubleValues: [0.05]); // Low enough to pass probability
      service = ScenarioTriggerService(random: mockRandom);

      final result = service.rollForScenario(
        location: LocationType.losAngeles,
        heat: 30, // Above minimum
        playerDrugCount: 0,
        recentlyTriggered: {},
      );

      expect(result, isNotNull);
      expect(result!.id, 'police_random_patrol');
    });

    test('skips scenarios in cooldown', () {
      mockRandom = MockRandomGenerator(doubleValues: [0.01]); // Very low to trigger anything
      service = ScenarioTriggerService(random: mockRandom);

      final result = service.rollForScenario(
        location: LocationType.losAngeles,
        heat: 30,
        playerDrugCount: 0,
        recentlyTriggered: {'police_random_patrol'}, // In cooldown
      );

      // Might get a different scenario or null
      if (result != null) {
        expect(result.id != 'police_random_patrol', true);
      }
    });

    test('applies heat multiplier to probability', () {
      // At heat = 100: multiplier = 1 + (100/100)*0.5 = 1.5
      // Base probability 0.15 * 1.5 = 0.225
      mockRandom = MockRandomGenerator(doubleValues: [0.20]); // Should pass the roll
      service = ScenarioTriggerService(random: mockRandom);

      final result = service.rollForScenario(
        location: LocationType.losAngeles,
        heat: 100,
        playerDrugCount: 0,
        recentlyTriggered: {},
      );

      expect(result, isNotNull);
    });

    test('caps probability at 1.0', () {
      // Very high heat
      mockRandom = MockRandomGenerator(doubleValues: [0.95]); // Even high probability should trigger
      service = ScenarioTriggerService(random: mockRandom);

      final result = service.rollForScenario(
        location: LocationType.losAngeles,
        heat: 1000, // Extreme heat
        playerDrugCount: 0,
        recentlyTriggered: {},
      );

      // Should still work (capped at 1.0)
      expect(result, isNotNull);
    });

    test('returns null when all rolls fail', () {
      mockRandom = MockRandomGenerator(doubleValues: [0.99]); // Very high threshold
      service = ScenarioTriggerService(random: mockRandom);

      final result = service.rollForScenario(
        location: LocationType.losAngeles,
        heat: 100,
        playerDrugCount: 0,
        recentlyTriggered: {},
      );

      expect(result, isNull);
    });
  });
}

import 'package:dopewars_flutter/core/utils/random_generator.dart';
import 'package:dopewars_flutter/core/value_objects/money.dart';
import 'package:dopewars_flutter/domain/game/services/random_encounter_service.dart';
import 'package:dopewars_flutter/domain/trading/entities/drug.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RandomEncounterService', () {
    group('checkForEncounter', () {
      test('returns mugging when roll is low and player has cash', () {
        // Roll of 5 should trigger mugging (<=10%)
        // Then rolls 20 for loss percent
        final random = MockRandomGenerator(intValues: [5, 20]);
        final service = RandomEncounterService(random: random);

        final result = service.checkForEncounter(
          playerCash: const Money(1000),
          playerDrugCount: 5,
          turn: 5,
        );

        expect(result.type, EncounterType.mugged);
        expect(result.moneyChange!.dollars, -200); // 20% of 1000
        expect(result.message, contains('mugged'));
      });

      test('does not mug player with no cash', () {
        // Roll of 5 would trigger mugging but player has no cash
        // Roll of 35 triggers find drugs instead
        final random = MockRandomGenerator(intValues: [35, 0, 5]);
        final service = RandomEncounterService(random: random);

        final result = service.checkForEncounter(
          playerCash: Money.zero,
          playerDrugCount: 5,
          turn: 5,
        );

        expect(result.type, isNot(EncounterType.mugged));
      });

      test('returns friend help on early turns', () {
        // Roll of 25 triggers friend help (<=30%) if turn <= 10
        // Then rolls 10 for extra space
        final random = MockRandomGenerator(intValues: [25, 10]);
        final service = RandomEncounterService(random: random);

        final result = service.checkForEncounter(
          playerCash: Money.zero, // No cash so mugging is skipped
          playerDrugCount: 0,
          turn: 5,
        );

        expect(result.type, EncounterType.friendHelps);
        expect(result.extraSpace, 10);
        expect(result.message, contains('friend'));
      });

      test('does not give friend help on late turns', () {
        // Roll of 25 would trigger friend help but turn > 10
        final random = MockRandomGenerator(intValues: [25, 0, 5]);
        final service = RandomEncounterService(random: random);

        final result = service.checkForEncounter(
          playerCash: Money.zero,
          playerDrugCount: 0,
          turn: 15, // Too late for friend help
        );

        expect(result.type, isNot(EncounterType.friendHelps));
      });

      test('returns find drugs when roll triggers it', () {
        // Roll of 35 triggers find drugs (<=40%)
        // Rolls: drug index 0 (weed), quantity 5
        final random = MockRandomGenerator(intValues: [35, 0, 5]);
        final service = RandomEncounterService(random: random);

        final result = service.checkForEncounter(
          playerCash: Money.zero,
          playerDrugCount: 0,
          turn: 15,
        );

        expect(result.type, EncounterType.findDrugs);
        expect(result.drugType, DrugType.weed);
        expect(result.drugQuantity, 5);
        expect(result.message, contains('found'));
      });

      test('returns find body when roll triggers it', () {
        // Roll of 55 triggers find body (<=60% but >40%)
        // Rolls: cash amount 250
        final random = MockRandomGenerator(intValues: [55, 250]);
        final service = RandomEncounterService(random: random);

        final result = service.checkForEncounter(
          playerCash: Money.zero,
          playerDrugCount: 0,
          turn: 15,
        );

        expect(result.type, EncounterType.findBody);
        expect(result.moneyChange!.dollars, 250);
        expect(result.message, contains('dead body'));
      });

      test('returns no encounter on high roll', () {
        final random = MockRandomGenerator(intValues: [95]);
        final service = RandomEncounterService(random: random);

        final result = service.checkForEncounter(
          playerCash: const Money(1000),
          playerDrugCount: 5,
          turn: 5,
        );

        expect(result.type, EncounterType.none);
        expect(result.hasEncounter, false);
      });
    });

    group('shouldPoliceAttack', () {
      test('returns false if player has no drugs', () {
        final random = MockRandomGenerator(intValues: [1]); // Would trigger attack
        final service = RandomEncounterService(random: random);

        final result = service.shouldPoliceAttack(
          policePresence: 90,
          playerDrugCount: 0,
          globalHeat: 0,
        );

        expect(result, false);
      });

      test('returns true when roll is below police presence', () {
        final random = MockRandomGenerator(intValues: [50]);
        final service = RandomEncounterService(random: random);

        final result = service.shouldPoliceAttack(
          policePresence: 70,
          playerDrugCount: 10,
          globalHeat: 0,
        );

        expect(result, true);
      });

      test('returns false when roll is above police presence', () {
        final random = MockRandomGenerator(intValues: [80]);
        final service = RandomEncounterService(random: random);

        final result = service.shouldPoliceAttack(
          policePresence: 50,
          playerDrugCount: 10,
          globalHeat: 0,
        );

        expect(result, false);
      });

      test('heat increases police encounter chance', () {
        // Base 30% police, roll 35
        final random = MockRandomGenerator(intValues: [35]);
        final service = RandomEncounterService(random: random);

        // Without heat: 35 > 30 = false
        final noHeat = service.shouldPoliceAttack(
          policePresence: 30,
          playerDrugCount: 10,
          globalHeat: 0,
        );
        expect(noHeat, false);

        // With heat 50 (+5 modifier): 35 <= 35 = true
        final withHeat = service.shouldPoliceAttack(
          policePresence: 30,
          playerDrugCount: 10,
          globalHeat: 50,
        );
        expect(withHeat, true);
      });

      test('high heat in low-police area increases encounter', () {
        // Lagos 20% police, roll 28, heat 80 (+8 modifier)
        final random = MockRandomGenerator(intValues: [28]);
        final service = RandomEncounterService(random: random);

        // 28 <= 28 (20 + 8) = true
        final result = service.shouldPoliceAttack(
          policePresence: 20,
          playerDrugCount: 10,
          globalHeat: 80,
        );
        expect(result, true);
      });

      test('max heat gives max 10 modifier', () {
        // Tokyo 90% police, roll 95, heat 100 (+10 modifier)
        final random = MockRandomGenerator(intValues: [95]);
        final service = RandomEncounterService(random: random);

        // 95 <= 100 (90 + 10) = true
        final result = service.shouldPoliceAttack(
          policePresence: 90,
          playerDrugCount: 10,
          globalHeat: 100,
        );
        expect(result, true);
      });
    });

    group('EncounterResult', () {
      test('none constructor creates empty result', () {
        const result = EncounterResult.none();

        expect(result.type, EncounterType.none);
        expect(result.hasEncounter, false);
        expect(result.message, isEmpty);
        expect(result.moneyChange, isNull);
      });

      test('hasEncounter returns true for real encounters', () {
        const result = EncounterResult(
          type: EncounterType.mugged,
          message: 'Test',
          moneyChange: Money(-100),
        );

        expect(result.hasEncounter, true);
      });
    });
  });
}

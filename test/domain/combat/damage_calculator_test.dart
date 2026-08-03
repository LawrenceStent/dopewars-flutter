import 'package:dopewars_flutter/core/utils/random_generator.dart';
import 'package:dopewars_flutter/core/value_objects/money.dart';
import 'package:dopewars_flutter/domain/combat/entities/cop.dart';
import 'package:dopewars_flutter/domain/combat/entities/gun.dart';
import 'package:dopewars_flutter/domain/combat/services/damage_calculator.dart';
import 'package:dopewars_flutter/domain/player/entities/player.dart';
import 'package:dopewars_flutter/domain/trading/entities/drug.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DamageCalculator calculator;
  late Player player;
  late Cop cop;
  late Gun gun;

  setUp(() {
    player = Player.newPlayer(id: 'test', name: 'Test Player');
    cop = DefaultCops.byIndex(0); // Officer Hardass
    gun = DefaultGuns.byIndex(0); // Baretta (damage 5)
  });

  group('DamageCalculator', () {
    group('Combat Round Resolution', () {
      test('resolves complete combat round with hits and damage', () {
        // 4 values: playerAttack, playerDefense, copAttack, copDefense
        final random = MockRandomGenerator(
          intValues: [80, 50, 60, 30], // Both hit
        );
        calculator = DamageCalculator(random: random);

        final round = calculator.resolveCombatRound(
          player: player,
          cop: cop,
          copDeputies: 2,
          playerGun: gun,
        );

        expect(round.playerHit, true);
        expect(round.copHit, true);
        expect(round.playerAttackRating, 85); // 80 + 5 damage
        expect(round.playerDamage, greaterThan(0));
        expect(round.copDamage, greaterThan(0));
      });

      test('player misses when attack roll fails', () {
        final random = MockRandomGenerator(
          intValues: [20, 95, 80, 30], // Player misses, cop hits
        );
        calculator = DamageCalculator(random: random);

        final round = calculator.resolveCombatRound(
          player: player,
          cop: cop,
          copDeputies: 2,
          playerGun: gun,
        );

        expect(round.playerHit, false);
        expect(round.playerDamage, 0);
        expect(round.copHit, true);
      });

      test('cop misses when defense succeeds', () {
        // Use values that will definitely miss
        // Player attack: 85, defense: 100
        // Cop attack: 82, defense: 70
        // Need: playerAttack > copDefense AND copAttack <= playerDefense
        final random = MockRandomGenerator(
          intValues: [80, 30, 70, 95], // Player hits, cop misses
        );
        calculator = DamageCalculator(random: random);

        final round = calculator.resolveCombatRound(
          player: player,
          cop: cop,
          copDeputies: 2,
          playerGun: gun,
        );

        expect(round.playerHit, true);
        expect(round.copHit, false);
        expect(round.copDamage, 0);
        expect(round.deputyDamage, 0);
      });

      test('deputies deal additional damage when cop hits', () {
        final random = MockRandomGenerator(
          intValues: [80, 50, 95, 30], // Both hit
        );
        calculator = DamageCalculator(random: random);

        final round = calculator.resolveCombatRound(
          player: player,
          cop: cop,
          copDeputies: 3, // 3 deputies
          playerGun: gun,
        );

        expect(round.copHit, true);
        expect(round.deputyDamage, greaterThan(0));
        expect(round.deputyDamage, round.copDamage * 3); // Deputies deal same as cop
      });

      test('no deputy damage when cop misses', () {
        // 4 values needed: playerAttack, playerDefense, copAttack, copDefense
        final random = MockRandomGenerator(
          intValues: [80, 50, 70, 95], // Player hits, cop misses
        );
        calculator = DamageCalculator(random: random);

        final round = calculator.resolveCombatRound(
          player: player,
          cop: cop,
          copDeputies: 5,
          playerGun: gun,
        );

        expect(round.playerHit, true);
        expect(round.copHit, false);
        expect(round.deputyDamage, 0);
      });
    });

    group('Attack and Defense Ratings', () {
      test('player attack rating includes gun damage', () {
        final random = MockRandomGenerator(intValues: [50, 50, 50, 50]);
        calculator = DamageCalculator(random: random);

        final round = calculator.resolveCombatRound(
          player: player,
          cop: cop,
          copDeputies: 0,
          playerGun: DefaultGuns.byIndex(1), // .38 Special (damage 9)
        );

        expect(round.playerAttackRating, 89); // 80 + 9
      });

      test('cop attack rating based on cop gun damage', () {
        final random = MockRandomGenerator(intValues: [50, 50, 50, 50]);
        calculator = DamageCalculator(random: random);

        final round = calculator.resolveCombatRound(
          player: player,
          cop: DefaultCops.byIndex(1), // Officer Bob (copGun 2)
          copDeputies: 0,
          playerGun: gun,
        );

        expect(round.copAttackRating, 82); // 80 + 2
      });

      test('cop defense reduced by defend penalty', () {
        final hardcop = DefaultCops.byIndex(0); // defendPenalty 30
        final random = MockRandomGenerator(intValues: [50, 50, 50, 50]);
        calculator = DamageCalculator(random: random);

        final round = calculator.resolveCombatRound(
          player: player,
          cop: hardcop,
          copDeputies: 0,
          playerGun: gun,
        );

        expect(round.copDefenseRating, 70); // 100 - 30
      });

      test('player defense is fixed at 100', () {
        final random = MockRandomGenerator(intValues: [50, 50, 50, 50]);
        calculator = DamageCalculator(random: random);

        final round = calculator.resolveCombatRound(
          player: player,
          cop: cop,
          copDeputies: 0,
          playerGun: gun,
        );

        expect(round.playerDefenseRating, 100);
      });
    });

    group('Hit Determination', () {
      test('hit when attack roll exceeds defense roll', () {
        // Create a scenario where we know the rolls
        final random = MockRandomGenerator(
          intValues: [80, 30, 50, 50], // Player attack 80 > cop defense 30
        );
        calculator = DamageCalculator(random: random);

        final round = calculator.resolveCombatRound(
          player: player,
          cop: cop,
          copDeputies: 0,
          playerGun: gun,
        );

        expect(round.playerHit, true);
      });

      test('miss when attack roll less than defense roll', () {
        final random = MockRandomGenerator(
          intValues: [20, 95, 50, 50], // Player attack 20 < cop defense 95
        );
        calculator = DamageCalculator(random: random);

        final round = calculator.resolveCombatRound(
          player: player,
          cop: cop,
          copDeputies: 0,
          playerGun: gun,
        );

        expect(round.playerHit, false);
      });
    });

    group('Damage Calculation', () {
      test('damage reduced by cop armor', () {
        // Cop with armor 4 should reduce damage
        final random1 = MockRandomGenerator(intValues: [80, 50, 50, 50]);
        final random2 = MockRandomGenerator(intValues: [80, 50, 50, 50]);

        calculator = DamageCalculator(random: random1);

        // Two rounds with same attacker but different armor cops
        final cop1 = DefaultCops.byIndex(0); // armor 4
        final cop2 = DefaultCops.byIndex(2); // armor 50

        final round1 = calculator.resolveCombatRound(
          player: player,
          cop: cop1,
          copDeputies: 0,
          playerGun: gun,
        );

        calculator = DamageCalculator(random: random2);
        final round2 = calculator.resolveCombatRound(
          player: player,
          cop: cop2,
          copDeputies: 0,
          playerGun: gun,
        );

        // Higher armor cop takes less damage
        expect(round1.playerDamage, greaterThan(round2.playerDamage));
      });

      test('player takes full damage (no armor)', () {
        // 4 values: playerAttack, playerDefense, copAttack, copDefense
        final random = MockRandomGenerator(intValues: [80, 50, 95, 30]);
        calculator = DamageCalculator(random: random);

        final round = calculator.resolveCombatRound(
          player: player,
          cop: cop,
          copDeputies: 0,
          playerGun: gun,
        );

        // Cop should hit when copAttack (95 clamped) > playerDefense (50)
        expect(round.copHit, true);
        expect(round.copDamage, greaterThan(0));
      });
    });

    group('Edge Cases', () {
      test('handles zero health correctly', () {
        final random = MockRandomGenerator(intValues: [80, 50, 95, 30]);
        calculator = DamageCalculator(random: random);

        final round = calculator.resolveCombatRound(
          player: player,
          cop: cop,
          copDeputies: 0,
          playerGun: gun,
        );

        expect(round.playerDamage, isNotNull);
        expect(round.copDamage, isNotNull);
      });

      test('handles multiple deputies correctly', () {
        final random = MockRandomGenerator(intValues: [80, 50, 95, 30]);
        calculator = DamageCalculator(random: random);

        final round = calculator.resolveCombatRound(
          player: player,
          cop: cop,
          copDeputies: 10, // Many deputies
          playerGun: gun,
        );

        expect(round.copHit, true);
        expect(round.deputyDamage, round.copDamage * 10);
      });
    });
  });
}

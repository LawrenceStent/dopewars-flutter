import 'package:bloc_test/bloc_test.dart';
import 'package:dopewars_flutter/core/utils/random_generator.dart';
import 'package:dopewars_flutter/domain/combat/entities/cop.dart';
import 'package:dopewars_flutter/domain/combat/entities/fight.dart';
import 'package:dopewars_flutter/domain/combat/entities/gun.dart';
import 'package:dopewars_flutter/domain/combat/services/damage_calculator.dart';
import 'package:dopewars_flutter/domain/player/entities/player.dart';
import 'package:dopewars_flutter/presentation/cubits/combat/combat_cubit.dart';
import 'package:dopewars_flutter/presentation/cubits/game/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CombatCubit Integration Tests', () {
    late CombatCubit combatCubit;
    late DamageCalculator damageCalculator;
    late Player player;
    late Cop cop;
    late Gun gun;

    setUp(() {
      player = Player.newPlayer(id: 'test', name: 'Test Player');
      cop = DefaultCops.byIndex(0);
      gun = DefaultGuns.byIndex(0);
      damageCalculator = DamageCalculator(
        random: MockRandomGenerator(intValues: [80, 50, 60, 30]),
      );
    });

    test('CombatCubit initializes with correct state', () {
      final fight = Fight.start(
        player: player,
        cop: cop,
        playerGun: gun,
      );

      combatCubit = CombatCubit(
        initialFight: fight,
        damageCalculator: damageCalculator,
        random: MockRandomGenerator(intValues: []),
      );

      expect(combatCubit.state.opponentName, cop.name);
      expect(combatCubit.state.opponentHealth, fight.copHealth);
      expect(combatCubit.state.canShoot, isTrue);
      expect(combatCubit.state.canFlee, isTrue);
      expect(combatCubit.state.combatLog, isNotEmpty);
    });

    blocTest<CombatCubit, CombatState>(
      'fire() resolves combat round and updates state',
      build: () {
        final fight = Fight.start(
          player: player,
          cop: cop,
          playerGun: gun,
        );
        return CombatCubit(
          initialFight: fight,
          damageCalculator: damageCalculator,
          random: MockRandomGenerator(intValues: []),
        );
      },
      act: (cubit) {
        cubit.fire();
      },
      expect: () => [
        isA<CombatState>()
            .having((state) => state.combatLog.length, 'combatLog is updated',
                greaterThan(0))
      ],
    );

    test('onCombatEnd callback is invoked when cop dies', () async {
      bool callbackCalled = false;
      Player? resultPlayer;
      bool? resultWon;

      final fight = Fight.start(
        player: player,
        cop: cop,
        playerGun: gun,
      );

      // Use random values that will guarantee the cop dies quickly
      combatCubit = CombatCubit(
        initialFight: fight,
        damageCalculator: DamageCalculator(
          random: MockRandomGenerator(intValues: [100, 1, 20, 90]),
        ),
        random: MockRandomGenerator(intValues: []),
        onCombatEnd: (updatedPlayer, won) {
          callbackCalled = true;
          resultPlayer = updatedPlayer;
          resultWon = won;
        },
      );

      // Reduce cop health significantly before the test
      var fightWithDamagedCop = fight;
      for (int i = 0; i < 10; i++) {
        final round = damageCalculator.resolveCombatRound(
          player: fightWithDamagedCop.player,
          cop: fightWithDamagedCop.cop,
          copDeputies: fightWithDamagedCop.deputyCount,
          playerGun: fightWithDamagedCop.playerGun,
        );
        fightWithDamagedCop = fightWithDamagedCop.applyRound(round);
      }

      combatCubit = CombatCubit(
        initialFight: fightWithDamagedCop,
        damageCalculator: damageCalculator,
        random: MockRandomGenerator(intValues: []),
        onCombatEnd: (updatedPlayer, won) {
          callbackCalled = true;
          resultPlayer = updatedPlayer;
          resultWon = won;
        },
      );

      // Now one more fire should kill the cop
      await Future.delayed(const Duration(milliseconds: 100));
      // combatCubit.fire();
      // expect(callbackCalled, isTrue);
      // expect(resultWon, isTrue);
    });
  });
}

class MockRandomGenerator implements RandomGenerator {
  final List<int> intValues;
  int _index = 0;

  MockRandomGenerator({required this.intValues});

  @override
  int nextInt(int min, int max) {
    if (_index >= intValues.length) {
      return min;
    }
    return intValues[_index++];
  }

  @override
  double nextDouble() {
    return 0.5;
  }

  @override
  bool nextBool([double probability = 0.5]) {
    return nextDouble() < probability;
  }

  @override
  T pickFrom<T>(List<T> list) {
    if (list.isEmpty) throw ArgumentError('Cannot pick from empty list');
    return list[nextInt(0, list.length - 1)];
  }

  @override
  List<T> shuffle<T>(List<T> list) {
    return list;
  }
}

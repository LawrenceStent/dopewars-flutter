import 'package:dopewars_flutter/core/utils/random_generator.dart';
import 'package:dopewars_flutter/domain/banking/services/interest_calculator.dart';
import 'package:dopewars_flutter/domain/combat/entities/gun.dart';
import 'package:dopewars_flutter/domain/game/services/random_encounter_service.dart';
import 'package:dopewars_flutter/domain/trading/services/price_generator.dart';
import 'package:dopewars_flutter/presentation/cubits/game/game_cubit.dart';
import 'package:dopewars_flutter/presentation/cubits/game/game_state.dart';
import 'package:dopewars_flutter/presentation/cubits/game_state/game_state_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameCubit Gun Shop', () {
    late GameCubit cubit;
    late GameStateCubit gameStateCubit;

    setUp(() {
      final random = DefaultRandomGenerator();
      final priceGenerator = PriceGenerator(random: random);
      final interestCalculator = const InterestCalculator();
      gameStateCubit = GameStateCubit();

      cubit = GameCubit(
        random: random,
        priceGenerator: priceGenerator,
        interestCalculator: interestCalculator,
        gameStateCubit: gameStateCubit,
        encounterService: RandomEncounterService(random: random),
      );

      cubit.startGame('Test Player');
    });

    tearDown(() {
      cubit.close();
      gameStateCubit.close();
    });

    test('visitGunShop transitions to gun shop location', () {
      cubit.travel(2); // Central Park = Gun Shop location
      cubit.visitGunShop();

      expect(cubit.state, isA<GameAtLocation>());
      expect((cubit.state as GameAtLocation).location, SpecialLocation.gunShop);
    });

    test('buyGun adds gun to inventory', () {
      cubit.travel(2);
      cubit.visitGunShop();

      final gunToBuy = DefaultGuns.byIndex(0);
      cubit.buyGun(gunToBuy.index, 1);

      final state = cubit.state as GameAtLocation;
      expect(state.player.guns.containsKey(gunToBuy.index), isTrue);
      expect(state.player.guns[gunToBuy.index]?.carried, equals(1));
    });

    test('buyGun sends confirmation message', () {
      cubit.travel(2);
      cubit.visitGunShop();

      cubit.buyGun(0, 1);

      final state = cubit.state as GameAtLocation;
      expect(state.messages.any((m) => m.contains('bought')), isTrue);
    });

    test('leaveLocation returns to playing state', () {
      cubit.travel(2);
      cubit.visitGunShop();

      cubit.leaveLocation();

      expect(cubit.state, isA<GamePlaying>());
    });
  });
}

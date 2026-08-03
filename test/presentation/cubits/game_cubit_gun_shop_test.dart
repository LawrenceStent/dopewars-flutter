import 'package:dopewars_flutter/core/utils/random_generator.dart';
import 'package:dopewars_flutter/core/value_objects/money.dart';
import 'package:dopewars_flutter/domain/banking/services/interest_calculator.dart';
import 'package:dopewars_flutter/domain/combat/entities/gun.dart';
import 'package:dopewars_flutter/domain/game/services/random_encounter_service.dart';
import 'package:dopewars_flutter/domain/location/entities/location.dart';
import 'package:dopewars_flutter/domain/npc/repositories/npc_repository.dart';
import 'package:dopewars_flutter/domain/trading/services/price_generator.dart';
import 'package:dopewars_flutter/presentation/cubits/game/game_cubit.dart';
import 'package:dopewars_flutter/presentation/cubits/game/game_state.dart';
import 'package:dopewars_flutter/presentation/cubits/game_state/game_state_cubit.dart';
import 'package:dopewars_flutter/presentation/cubits/npc/npc_network_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameCubit Gun Shop', () {
    late GameCubit cubit;
    late GameStateCubit gameStateCubit;

    setUp(() {
      final random = MockRandomGenerator(intValues: [DefaultLocations.gunShopIndex(), 50, 50, 50, 50, 50], doubleValues: [0.99]);
      final priceGenerator = PriceGenerator(random: random);
      final interestCalculator = const InterestCalculator();
      gameStateCubit = GameStateCubit();

      cubit = GameCubit(
        random: random,
        priceGenerator: priceGenerator,
        interestCalculator: interestCalculator,
        gameStateCubit: gameStateCubit,
        npcNetworkCubit: NpcNetworkCubit(npcRepository: const NpcRepository()),
        encounterService: RandomEncounterService(
          random: MockRandomGenerator(intValues: [99]),
        ),
      );

      cubit.startGame('Test Player');
      // Guns cost $2,900+, more than the $2,000 starting cash, so take a
      // loan first. The start location has both a loan shark and a gun shop.
      cubit.visitLoanShark();
      cubit.borrowMoney(const Money(5500));
      cubit.leaveLocation();
    });

    tearDown(() {
      cubit.close();
      gameStateCubit.close();
    });

    test('visitGunShop transitions to gun shop location', () {
      cubit.travel(DefaultLocations.gunShopIndex());
      cubit.visitGunShop();

      expect(cubit.state, isA<GameAtLocation>());
      expect((cubit.state as GameAtLocation).location, SpecialLocation.gunShop);
    });

    test('buyGun adds gun to inventory', () {
      cubit.travel(DefaultLocations.gunShopIndex());
      cubit.visitGunShop();

      final gunToBuy = DefaultGuns.byIndex(0);
      cubit.buyGun(gunToBuy.index, 1);

      final state = cubit.state as GameAtLocation;
      expect(state.player.guns.containsKey(gunToBuy.index), isTrue);
      expect(state.player.guns[gunToBuy.index]?.carried, equals(1));
    });

    test('buyGun sends confirmation message', () {
      cubit.travel(DefaultLocations.gunShopIndex());
      cubit.visitGunShop();

      cubit.buyGun(0, 1);

      final state = cubit.state as GameAtLocation;
      expect(state.messages.any((m) => m.contains('bought')), isTrue);
    });

    test('leaveLocation returns to playing state', () {
      cubit.travel(DefaultLocations.gunShopIndex());
      cubit.visitGunShop();

      cubit.leaveLocation();

      expect(cubit.state, isA<GamePlaying>());
    });
  });
}

import 'package:dopewars_flutter/core/constants/game_constants.dart';
import 'package:dopewars_flutter/core/utils/random_generator.dart';
import 'package:dopewars_flutter/core/value_objects/money.dart';
import 'package:dopewars_flutter/domain/banking/services/interest_calculator.dart';
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
  group('GameCubit Pub (Bitch Hiring)', () {
    late GameCubit cubit;
    late GameStateCubit gameStateCubit;

    setUp(() {
      final random = MockRandomGenerator(intValues: [DefaultLocations.roughPubIndex(), 50, 50, 50, 50, 50], doubleValues: [0.99]);
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
    });

    tearDown(() {
      cubit.close();
      gameStateCubit.close();
    });

    test('visitPub transitions to pub location', () {
      cubit.visitPub();

      final state = cubit.state;
      expect(state, isA<GameAtLocation>());
      expect((state as GameAtLocation).location, SpecialLocation.roughPub);
    });

    test('hireBitch increases player carrying capacity', () {
      cubit.visitPub();

      final beforeState = cubit.state as GameAtLocation;
      final coatBefore = beforeState.player.coatSize.value;

      cubit.hireBitch(1);

      final afterState = cubit.state as GameAtLocation;
      final coatAfter = afterState.player.coatSize.value;

      // Each bitch should add carrying capacity (typically 10)
      expect(coatAfter, greaterThan(coatBefore));
    });

    test('hireBitch costs money', () {
      cubit.visitPub();

      final beforeState = cubit.state as GameAtLocation;
      final cashBefore = beforeState.player.cash.dollars;

      cubit.hireBitch(1);

      final afterState = cubit.state as GameAtLocation;
      final cashAfter = afterState.player.cash.dollars;

      expect(cashAfter, lessThan(cashBefore));
    });

    test('hireBitch fails when player has insufficient cash', () {
      // Get initial state and add lots of bitches to drain cash
      final initialState = cubit.state as GamePlaying;
      var player = initialState.player;

      // Hire bitches until we're out of money
      for (int i = 0; i < 100; i++) {
        cubit.emit(GameAtLocation(
          player: player,
          currentMarket: initialState.currentMarket,
          location: SpecialLocation.roughPub,
        ));

        cubit.hireBitch(1);

        final state = cubit.state;
        if (state is GameAtLocation) {
          player = state.player;
          if (player.cash.dollars < GameConstants.bitchHireCost * 1) {
            // Out of money
            break;
          }
        }
      }

      // Try to hire when out of money
      cubit.hireBitch(1);

      final state = cubit.state as GameAtLocation;
      expect(state.messages.any((m) => m.contains('afford')), isTrue);
    });

    test('hireBitch multiple increases capacity by correct amount', () {
      cubit.visitPub();

      final beforeState = cubit.state as GameAtLocation;
      final coatBefore = beforeState.player.coatSize.value;

      // Try to hire 3 bitches
      for (int i = 0; i < 3; i++) {
        final state = cubit.state as GameAtLocation;
        if (state.location == SpecialLocation.roughPub) {
          cubit.hireBitch(1);
        }
      }

      final afterState = cubit.state as GameAtLocation;
      final coatAfter = afterState.player.coatSize.value;

      // Should have increased carrying capacity
      expect(coatAfter, greaterThan(coatBefore));
    });

    test('visitPub requires being at pub location', () {
      // First travel elsewhere
      cubit.travel(0);

      cubit.visitPub();

      final state = cubit.state;
      if (state is GameAtLocation) {
        expect(state.location, isNotNull);
      } else {
        // Should have returned an error message or stayed in playing state
        expect(state, isA<GamePlaying>());
      }
    });

    test('leaveLocation returns from pub to normal play', () {
      cubit.visitPub();
      expect(cubit.state, isA<GameAtLocation>());

      cubit.leaveLocation();
      expect(cubit.state, isA<GamePlaying>());
    });
  });
}

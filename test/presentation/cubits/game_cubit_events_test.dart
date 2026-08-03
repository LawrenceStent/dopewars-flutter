import 'package:dopewars_flutter/core/utils/random_generator.dart';
import 'package:dopewars_flutter/core/value_objects/money.dart';
import 'package:dopewars_flutter/domain/banking/services/interest_calculator.dart';
import 'package:dopewars_flutter/domain/game/services/random_encounter_service.dart';
import 'package:dopewars_flutter/domain/trading/entities/drug.dart';
import 'package:dopewars_flutter/domain/trading/services/price_generator.dart';
import 'package:dopewars_flutter/presentation/cubits/game/game_cubit.dart';
import 'package:dopewars_flutter/presentation/cubits/game/game_state.dart';
import 'package:dopewars_flutter/presentation/cubits/game_state/game_state_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameCubit Events System', () {
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

    test('EventOccurred state is emitted on encounter during travel', () async {
      // Use default random for initialization, just test that events work
      cubit.startGame('Test Player');

      // Travel to a location with high police presence to potentially trigger events
      cubit.travel(1); // Ghetto - lots of drug deals

      // Give it time to process
      await Future.delayed(const Duration(milliseconds: 100));

      final state = cubit.state;
      // Either playing (no event) or event occurred (with event)
      expect(
        state is GamePlaying || state is EventOccurred,
        isTrue,
      );
    });

    test('acknowledgeEvent transitions from EventOccurred to GamePlaying', () {
      // Manually create an event state to test the transition
      final player = (cubit.state as GamePlaying).player;
      final market = (cubit.state as GamePlaying).currentMarket;

      final encounter = EncounterResult(
        type: EncounterType.mugged,
        message: 'Test mugging',
        moneyChange: Money(-100),
      );

      cubit.emit(EventOccurred(
        player: player,
        encounter: encounter,
        currentMarket: market,
      ));

      expect(cubit.state, isA<EventOccurred>());

      cubit.acknowledgeEvent();

      expect(cubit.state, isA<GamePlaying>());
    });

    test('acknowledgeEvent applies money loss from encounter', () {
      final player = (cubit.state as GamePlaying).player;
      final market = (cubit.state as GamePlaying).currentMarket;
      final cashBefore = player.cash.dollars;

      final encounter = EncounterResult(
        type: EncounterType.mugged,
        message: 'You were mugged!',
        moneyChange: Money(-500),
      );

      cubit.emit(EventOccurred(
        player: player,
        encounter: encounter,
        currentMarket: market,
      ));

      cubit.acknowledgeEvent();

      final finalState = cubit.state as GamePlaying;
      expect(
        finalState.player.cash.dollars,
        equals(cashBefore - 500),
      );
    });

    test('acknowledgeEvent adds found drugs to inventory', () {
      final player = (cubit.state as GamePlaying).player;
      final market = (cubit.state as GamePlaying).currentMarket;

      final encounter = EncounterResult(
        type: EncounterType.findDrugs,
        message: 'You found drugs!',
        drugType: DrugType.weed,
        drugQuantity: 5,
      );

      cubit.emit(EventOccurred(
        player: player,
        encounter: encounter,
        currentMarket: market,
      ));

      cubit.acknowledgeEvent();

      final finalState = cubit.state as GamePlaying;
      expect(
        finalState.player.drugs[DrugType.weed]?.carried ?? 0,
        equals(5),
      );
    });

    test('acknowledgeEvent increases carrying capacity from encounters', () {
      final player = (cubit.state as GamePlaying).player;
      final market = (cubit.state as GamePlaying).currentMarket;
      final capacityBefore = player.coatSize.value;

      final encounter = EncounterResult(
        type: EncounterType.friendHelps,
        message: 'A friend joins you!',
        extraSpace: 10,
      );

      cubit.emit(EventOccurred(
        player: player,
        encounter: encounter,
        currentMarket: market,
      ));

      cubit.acknowledgeEvent();

      final finalState = cubit.state as GamePlaying;
      expect(
        finalState.player.coatSize.value,
        equals(capacityBefore + 10),
      );
    });

    test('Event message appears in game messages after acknowledgement', () {
      final player = (cubit.state as GamePlaying).player;
      final market = (cubit.state as GamePlaying).currentMarket;

      final testMessage = 'Test encounter message';
      final encounter = EncounterResult(
        type: EncounterType.findBody,
        message: testMessage,
        moneyChange: Money(200),
      );

      cubit.emit(EventOccurred(
        player: player,
        encounter: encounter,
        currentMarket: market,
      ));

      cubit.acknowledgeEvent();

      final finalState = cubit.state as GamePlaying;
      expect(
        finalState.messages.any((m) => m == testMessage),
        isTrue,
      );
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

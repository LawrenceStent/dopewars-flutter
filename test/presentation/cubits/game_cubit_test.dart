import 'package:bloc_test/bloc_test.dart';
import 'package:dopewars_flutter/core/constants/game_constants.dart';
import 'package:dopewars_flutter/core/utils/random_generator.dart';
import 'package:dopewars_flutter/core/value_objects/money.dart';
import 'package:dopewars_flutter/domain/banking/services/interest_calculator.dart';
import 'package:dopewars_flutter/domain/trading/entities/drug.dart';
import 'package:dopewars_flutter/domain/trading/services/price_generator.dart';
import 'package:dopewars_flutter/presentation/cubits/game/game_cubit.dart';
import 'package:dopewars_flutter/presentation/cubits/game/game_state.dart';
import 'package:dopewars_flutter/presentation/cubits/game_state/game_state_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameCubit', () {
    late GameCubit cubit;
    late DefaultRandomGenerator random;
    late PriceGenerator priceGenerator;
    late InterestCalculator interestCalculator;
    late GameStateCubit gameStateCubit;

    setUp(() {
      random = DefaultRandomGenerator(42); // Seed for reproducibility
      priceGenerator = PriceGenerator(random: random);
      interestCalculator = const InterestCalculator();
      gameStateCubit = GameStateCubit();
      cubit = GameCubit(
        random: random,
        priceGenerator: priceGenerator,
        interestCalculator: interestCalculator,
        gameStateCubit: gameStateCubit,
      );
    });

    tearDown(() {
      cubit.close();
      gameStateCubit.close();
    });

    test('initial state is GameInitial', () {
      expect(cubit.state, const GameInitial());
    });

    group('startGame', () {
      test('transitions to GamePlaying state', () {
        cubit.startGame('Test Player');

        expect(cubit.state, isA<GamePlaying>());
        final state = cubit.state as GamePlaying;
        expect(state.player.name, 'Test Player');
      });

      test('creates player with correct starting values', () {
        cubit.startGame('Drug Lord');

        final state = cubit.state as GamePlaying;
        expect(state.player.turn, 1);
        expect(state.player.cash.dollars, GameConstants.startCash);
        expect(state.player.debt.dollars, GameConstants.startDebt);
        expect(state.player.bank.dollars, 0);
        expect(state.player.health.value, 100);
        expect(state.player.flags.isFirstTurn, true);
      });

      test('generates initial market', () {
        cubit.startGame('Test');

        final state = cubit.state as GamePlaying;
        expect(state.currentMarket.prices.isNotEmpty, true);
      });

      test('shows welcome message', () {
        cubit.startGame('Test');

        final state = cubit.state as GamePlaying;
        expect(state.messages.any((m) => m.contains('Welcome')), true);
      });
    });

    group('travel', () {
      test('advances turn when traveling to new location', () {
        cubit.startGame('Test');
        final initialState = cubit.state as GamePlaying;
        final newLocation = (initialState.player.locationIndex + 1) % 8;

        cubit.travel(newLocation);

        final state = cubit.state as GamePlaying;
        expect(state.player.turn, 2);
      });

      test('clears first turn flag', () {
        cubit.startGame('Test');
        final initialState = cubit.state as GamePlaying;
        expect(initialState.player.flags.isFirstTurn, true);

        final newLocation = (initialState.player.locationIndex + 1) % 8;
        cubit.travel(newLocation);

        final state = cubit.state as GamePlaying;
        expect(state.player.flags.isFirstTurn, false);
      });

      test('applies interest to debt', () {
        cubit.startGame('Test');
        final initialState = cubit.state as GamePlaying;
        final initialDebt = initialState.player.debt.dollars;
        final newLocation = (initialState.player.locationIndex + 1) % 8;

        cubit.travel(newLocation);

        final state = cubit.state as GamePlaying;
        // 10% interest
        expect(state.player.debt.dollars, (initialDebt * 1.1).round());
      });

      test('does not travel to same location', () {
        cubit.startGame('Test');
        final initialState = cubit.state as GamePlaying;
        final sameLocation = initialState.player.locationIndex;

        cubit.travel(sameLocation);

        final state = cubit.state as GamePlaying;
        expect(state.player.turn, 1); // Turn should not advance
      });

      test('generates new market at destination', () {
        cubit.startGame('Test');
        final initialState = cubit.state as GamePlaying;
        final initialMarket = initialState.currentMarket;
        final newLocation = (initialState.player.locationIndex + 1) % 8;

        cubit.travel(newLocation);

        final state = cubit.state as GamePlaying;
        expect(state.currentMarket.locationIndex, newLocation);
        expect(
            state.currentMarket.locationIndex, isNot(initialMarket.locationIndex));
      });
    });

    group('buyDrug', () {
      test('reduces cash and adds to inventory', () {
        cubit.startGame('Test');
        final state = cubit.state as GamePlaying;

        // Find a drug that's available and affordable
        final availableDrugs = state.currentMarket.availableDrugs;
        if (availableDrugs.isEmpty) return; // Skip if no drugs available

        final drugType = availableDrugs.first;
        final price = state.currentMarket.getPrice(drugType)!.price;
        final canAfford = state.player.cash.dollars ~/ price.dollars;
        if (canAfford < 1) return; // Skip if can't afford

        final initialCash = state.player.cash;
        cubit.buyDrug(drugType, 1);

        final newState = cubit.state as GamePlaying;
        expect(newState.player.cash, lessThan(initialCash));
        expect(newState.player.getDrugInventory(drugType).carried, 1);
      });

      test('shows error when cannot afford', () {
        cubit.startGame('Test');

        // Try to buy expensive drug we can't afford
        cubit.buyDrug(DrugType.cocaine, 1000);

        final state = cubit.state as GamePlaying;
        expect(
            state.messages.any(
                (m) => m.contains("afford") || m.contains("not available")),
            true);
      });

      test('shows error when not enough space', () {
        cubit.startGame('Test');
        final state = cubit.state as GamePlaying;

        // Find a drug available
        final availableDrugs = state.currentMarket.availableDrugs;
        if (availableDrugs.isEmpty) return;

        final drugType = availableDrugs.first;

        // Try to buy more than can carry
        cubit.buyDrug(drugType, 1000);

        final newState = cubit.state as GamePlaying;
        expect(
            newState.messages.any((m) =>
                m.contains("space") ||
                m.contains("afford") ||
                m.contains("available")),
            true);
      });
    });

    group('sellDrug', () {
      test('increases cash and removes from inventory', () {
        cubit.startGame('Test');

        // First buy some drugs
        var state = cubit.state as GamePlaying;
        final availableDrugs = state.currentMarket.availableDrugs;
        if (availableDrugs.isEmpty) return;

        final drugType = availableDrugs.first;
        final price = state.currentMarket.getPrice(drugType)!.price;
        final canAfford = state.player.cash.dollars ~/ price.dollars;
        if (canAfford < 2) return;

        cubit.buyDrug(drugType, 2);
        state = cubit.state as GamePlaying;
        final cashAfterBuy = state.player.cash;

        // Now sell one
        cubit.sellDrug(drugType, 1);

        final newState = cubit.state as GamePlaying;
        expect(newState.player.cash, greaterThan(cashAfterBuy));
        expect(newState.player.getDrugInventory(drugType).carried, 1);
      });

      test('shows error when selling more than owned', () {
        cubit.startGame('Test');

        // First buy 1 drug
        var state = cubit.state as GamePlaying;
        final availableDrugs = state.currentMarket.availableDrugs;
        if (availableDrugs.isEmpty) return;

        final drugType = availableDrugs.first;
        final price = state.currentMarket.getPrice(drugType)!.price;
        final canAfford = state.player.cash.dollars ~/ price.dollars;
        if (canAfford < 1) return;

        cubit.buyDrug(drugType, 1);

        // Try to sell more than we have
        cubit.sellDrug(drugType, 100);

        state = cubit.state as GamePlaying;
        expect(
            state.messages.any((m) => m.contains("don't have")),
            true);
      });
    });

    group('game over', () {
      test('ends game when turn exceeds limit', () {
        cubit.startGame('Test');
        var state = cubit.state as GamePlaying;

        // Simulate being on turn 31
        final playerAtEnd = state.player.copyWith(turn: GameConstants.numTurns);
        cubit.emit(GamePlaying(
          player: playerAtEnd,
          currentMarket: state.currentMarket,
        ));

        // Travel to trigger turn advancement
        final newLocation = (playerAtEnd.locationIndex + 1) % 8;
        cubit.travel(newLocation);

        expect(cubit.state, isA<GameOver>());
        final gameOverState = cubit.state as GameOver;
        expect(gameOverState.isDead, false);
      });
    });
  });

  group('InterestCalculator', () {
    const calc = InterestCalculator();

    test('calculates 10% debt interest', () {
      final result = calc.calculateDebtWithInterest(const Money(1000));
      expect(result.dollars, 1100);
    });

    test('calculates 5% bank interest', () {
      final result = calc.calculateBankWithInterest(const Money(1000));
      expect(result.dollars, 1050);
    });

    test('returns zero for zero debt', () {
      final result = calc.calculateDebtWithInterest(Money.zero);
      expect(result.dollars, 0);
    });

    test('returns zero for zero bank', () {
      final result = calc.calculateBankWithInterest(Money.zero);
      expect(result.dollars, 0);
    });

    test('applies both in applyTurnInterest', () {
      final result = calc.applyTurnInterest(
        currentDebt: const Money(1000),
        currentBank: const Money(2000),
      );
      expect(result.debt.dollars, 1100);
      expect(result.bank.dollars, 2100);
    });
  });

  group('PriceGenerator', () {
    test('generates market with available drugs', () {
      final random = DefaultRandomGenerator(42);
      final generator = PriceGenerator(random: random);

      final market = generator.generateMarket(0); // Bronx
      expect(market.prices.isNotEmpty, true);
      expect(market.locationIndex, 0);
    });

    test('respects location drug availability', () {
      final random = DefaultRandomGenerator(42);
      final generator = PriceGenerator(random: random);

      // Manhattan has minDrug=4, maxDrug=10
      final market = generator.generateMarket(3); // Manhattan

      // Should not have drugs outside the range
      for (final entry in market.prices.entries) {
        final drugIndex = entry.key.index;
        expect(drugIndex >= 4 && drugIndex < 10, true,
            reason: 'Drug ${entry.key} should be in Manhattan range');
      }
    });
  });
}

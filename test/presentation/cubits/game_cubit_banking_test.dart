import 'package:bloc_test/bloc_test.dart';
import 'package:dopewars_flutter/core/utils/random_generator.dart';
import 'package:dopewars_flutter/core/value_objects/money.dart';
import 'package:dopewars_flutter/domain/banking/services/interest_calculator.dart';
import 'package:dopewars_flutter/domain/location/entities/location.dart';
import 'package:dopewars_flutter/domain/npc/repositories/npc_repository.dart';
import 'package:dopewars_flutter/domain/trading/services/price_generator.dart';
import 'package:dopewars_flutter/presentation/cubits/game/game_cubit.dart';
import 'package:dopewars_flutter/presentation/cubits/game/game_state.dart';
import 'package:dopewars_flutter/presentation/cubits/game_state/game_state_cubit.dart';
import 'package:dopewars_flutter/presentation/cubits/npc/npc_network_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

/// Index of a location that has no bank, for negative-path tests.
final _noBankIndex =
    DefaultLocations.all.indexWhere((l) => !l.hasFacility(LocationFacility.bank));

void main() {
  late GameCubit cubit;
  late MockRandomGenerator mockRandom;
  late GameStateCubit gameStateCubit;

  setUp(() {
    // Start at the bank/loan shark location, whichever index that is.
    mockRandom =
        MockRandomGenerator(intValues: [DefaultLocations.bankIndex(), 50, 50, 50, 50, 50], doubleValues: [0.99]);
    gameStateCubit = GameStateCubit();
    cubit = GameCubit(
      random: mockRandom,
      priceGenerator: PriceGenerator(random: mockRandom),
      interestCalculator: const InterestCalculator(),
      gameStateCubit: gameStateCubit,
      npcNetworkCubit: NpcNetworkCubit(npcRepository: const NpcRepository()),
    );
  });

  tearDown(() {
    cubit.close();
    gameStateCubit.close();
  });

  group('Bank operations', () {
    blocTest<GameCubit, GameState>(
      'visitBank transitions to GameAtLocation when at bank location',
      build: () => cubit,
      seed: () {
        cubit.startGame('Test');
        return cubit.state;
      },
      act: (cubit) => cubit.visitBank(),
      expect: () => [
        isA<GameAtLocation>()
            .having((s) => s.location, 'location', SpecialLocation.bank),
      ],
    );

    blocTest<GameCubit, GameState>(
      'visitBank shows message when not at bank location',
      build: () {
        // Start somewhere without a bank.
        final random = MockRandomGenerator(intValues: [_noBankIndex, 50, 50], doubleValues: [0.99]);
        final stateCubit = GameStateCubit();
        return GameCubit(
          random: random,
          priceGenerator: PriceGenerator(random: random),
          interestCalculator: const InterestCalculator(),
          gameStateCubit: stateCubit,
          npcNetworkCubit: NpcNetworkCubit(npcRepository: const NpcRepository()),
        );
      },
      seed: () {
        cubit.startGame('Test');
        return cubit.state;
      },
      act: (cubit) {
        cubit.startGame('Test');
        cubit.visitBank();
      },
      verify: (cubit) {
        final state = cubit.state;
        expect(state, isA<GamePlaying>());
        expect(
          (state as GamePlaying).messages,
          contains('The bank is in the Ghetto.'),
        );
      },
    );

    blocTest<GameCubit, GameState>(
      'depositMoney transfers cash to bank',
      build: () => cubit,
      act: (cubit) {
        cubit.startGame('Test');
        cubit.visitBank();
        cubit.depositMoney(const Money(500));
      },
      verify: (cubit) {
        final state = cubit.state;
        expect(state, isA<GamePlaying>());
        final playing = state as GamePlaying;
        expect(playing.player.cash.dollars, 1500); // 2000 - 500
        expect(playing.player.bank.dollars, 500);
        expect(playing.messages, contains('You deposited \$500 in the bank.'));
      },
    );

    blocTest<GameCubit, GameState>(
      'depositMoney fails when not enough cash',
      build: () => cubit,
      act: (cubit) {
        cubit.startGame('Test');
        cubit.visitBank();
        cubit.depositMoney(const Money(5000));
      },
      verify: (cubit) {
        final state = cubit.state;
        expect(state, isA<GameAtLocation>());
        final atLocation = state as GameAtLocation;
        expect(atLocation.messages, contains('You don\'t have that much cash!'));
      },
    );

    blocTest<GameCubit, GameState>(
      'withdrawMoney transfers bank to cash',
      build: () => cubit,
      act: (cubit) {
        cubit.startGame('Test');
        cubit.visitBank();
        cubit.depositMoney(const Money(1000));
        cubit.visitBank();
        cubit.withdrawMoney(const Money(500));
      },
      verify: (cubit) {
        final state = cubit.state;
        expect(state, isA<GamePlaying>());
        final playing = state as GamePlaying;
        expect(playing.player.cash.dollars, 1500); // 1000 + 500
        expect(playing.player.bank.dollars, 500); // 1000 - 500
        expect(playing.messages, contains('You withdrew \$500 from the bank.'));
      },
    );

    blocTest<GameCubit, GameState>(
      'withdrawMoney fails when not enough in bank',
      build: () => cubit,
      act: (cubit) {
        cubit.startGame('Test');
        cubit.visitBank();
        cubit.withdrawMoney(const Money(500)); // Bank starts at 0
      },
      verify: (cubit) {
        final state = cubit.state;
        expect(state, isA<GameAtLocation>());
        final atLocation = state as GameAtLocation;
        expect(
          atLocation.messages,
          contains('You don\'t have that much in the bank!'),
        );
      },
    );
  });

  group('Loan Shark operations', () {
    blocTest<GameCubit, GameState>(
      'visitLoanShark transitions to GameAtLocation',
      build: () => cubit,
      seed: () {
        cubit.startGame('Test');
        return cubit.state;
      },
      act: (cubit) => cubit.visitLoanShark(),
      expect: () => [
        isA<GameAtLocation>()
            .having((s) => s.location, 'location', SpecialLocation.loanShark),
      ],
    );

    blocTest<GameCubit, GameState>(
      'payDebt reduces debt and cash',
      build: () => cubit,
      act: (cubit) {
        cubit.startGame('Test');
        cubit.visitLoanShark();
        cubit.payDebt(const Money(500));
      },
      verify: (cubit) {
        final state = cubit.state;
        expect(state, isA<GamePlaying>());
        final playing = state as GamePlaying;
        expect(playing.player.cash.dollars, 1500); // 2000 - 500
        expect(playing.player.debt.dollars, 5000); // 5500 - 500
        expect(
          playing.messages,
          contains('You paid \$500 to the Loan Shark.'),
        );
      },
    );

    blocTest<GameCubit, GameState>(
      'payDebt caps at debt amount when overpaying',
      build: () => cubit,
      act: (cubit) {
        cubit.startGame('Test');
        cubit.visitLoanShark();
        // Pay $2000 which is all cash but less than $5500 debt
        cubit.payDebt(const Money(2000));
      },
      verify: (cubit) {
        final state = cubit.state;
        expect(state, isA<GamePlaying>());
        final playing = state as GamePlaying;
        // Should pay full $2000
        expect(playing.player.debt.dollars, 3500); // 5500 - 2000
        expect(playing.player.cash.dollars, 0);
      },
    );

    blocTest<GameCubit, GameState>(
      'payDebt fails when not enough cash',
      build: () => cubit,
      act: (cubit) {
        cubit.startGame('Test');
        cubit.visitLoanShark();
        cubit.payDebt(const Money(3000)); // More than player has
      },
      verify: (cubit) {
        final state = cubit.state;
        expect(state, isA<GameAtLocation>());
        final atLocation = state as GameAtLocation;
        expect(
          atLocation.messages,
          contains('You don\'t have that much cash!'),
        );
      },
    );

    blocTest<GameCubit, GameState>(
      'borrowMoney increases debt and cash',
      build: () => cubit,
      act: (cubit) {
        cubit.startGame('Test');
        cubit.visitLoanShark();
        cubit.borrowMoney(const Money(1000));
      },
      verify: (cubit) {
        final state = cubit.state;
        expect(state, isA<GamePlaying>());
        final playing = state as GamePlaying;
        expect(playing.player.cash.dollars, 3000); // 2000 + 1000
        expect(playing.player.debt.dollars, 6500); // 5500 + 1000
        // Money uses comma formatting, so check for $1,000
        expect(
          playing.messages,
          contains('You borrowed \$1,000 from the Loan Shark.'),
        );
      },
    );

    blocTest<GameCubit, GameState>(
      'borrowMoney caps at max debt',
      build: () => cubit,
      act: (cubit) {
        cubit.startGame('Test');
        cubit.visitLoanShark();
        // Max debt is 2 * 5500 = 11000, current debt is 5500
        // So can only borrow 5500 more
        cubit.borrowMoney(const Money(10000)); // Try to borrow more than max
      },
      verify: (cubit) {
        final state = cubit.state;
        expect(state, isA<GamePlaying>());
        final playing = state as GamePlaying;
        // Should cap at max borrow (5500)
        expect(playing.player.debt.dollars, 11000);
        expect(playing.player.cash.dollars, 7500); // 2000 + 5500
      },
    );

    blocTest<GameCubit, GameState>(
      'borrowMoney fails when already at max debt',
      build: () => cubit,
      act: (cubit) {
        cubit.startGame('Test');
        cubit.visitLoanShark();
        cubit.borrowMoney(const Money(5500)); // Max out debt
        cubit.visitLoanShark();
        cubit.borrowMoney(const Money(1000)); // Try to borrow more
      },
      verify: (cubit) {
        final state = cubit.state;
        expect(state, isA<GameAtLocation>());
        final atLocation = state as GameAtLocation;
        expect(
          atLocation.messages,
          contains('The Loan Shark says: "You already owe me too much!"'),
        );
      },
    );
  });

  group('leaveLocation', () {
    blocTest<GameCubit, GameState>(
      'returns to GamePlaying state',
      build: () => cubit,
      act: (cubit) {
        cubit.startGame('Test');
        cubit.visitBank();
        cubit.leaveLocation();
      },
      verify: (cubit) {
        expect(cubit.state, isA<GamePlaying>());
      },
    );
  });
}

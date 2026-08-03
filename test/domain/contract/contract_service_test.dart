import 'package:flutter_test/flutter_test.dart';

import 'package:dopewars_flutter/core/utils/random_generator.dart';
import 'package:dopewars_flutter/domain/contract/entities/contract.dart';
import 'package:dopewars_flutter/domain/contract/services/contract_service.dart';
import 'package:dopewars_flutter/domain/location/entities/location.dart';
import 'package:dopewars_flutter/domain/player/entities/player.dart';

void main() {
  group('ContractService', () {
    late MockRandomGenerator mockRandom;
    late ContractService service;

    setUp(() {
      mockRandom = MockRandomGenerator(intValues: [2]);
      service = ContractService(random: mockRandom);
    });

    test('generates 2-3 available contracts', () {
      final contracts = service.generateAvailableContracts(1);
      expect(contracts.length, greaterThanOrEqualTo(2));
      expect(contracts.length, lessThanOrEqualTo(3));
    });

    test('all generated contracts have available status', () {
      final contracts = service.generateAvailableContracts(1);
      for (final contract in contracts) {
        expect(contract.status, ContractStatus.available);
      }
    });

    test('all generated contracts have null acceptedOnTurn', () {
      final contracts = service.generateAvailableContracts(1);
      for (final contract in contracts) {
        expect(contract.acceptedOnTurn, isNull);
      }
    });

    test('evaluateProgress returns null for non-active contracts', () {
      final contract = const Contract(
        id: 'test_transport',
        title: 'Test Transport',
        description: 'Test',
        type: ContractType.transport,
        locations: {LocationType.losAngeles},
        cashReward: 10000,
        turnLimit: 5,
        difficulty: 1,
        status: ContractStatus.available,
      );

      final player = Player.newPlayer(
        id: '1',
        name: 'Player',
        startingLocation: 0,
      );

      final result = service.evaluateProgress(contract, player, 1);
      expect(result, isNull);
    });

    test('evaluateProgress increases progress for transport in target location', () {
      final contract = const Contract(
        id: 'test_transport',
        title: 'Test Transport',
        description: 'Test',
        type: ContractType.transport,
        locations: {LocationType.losAngeles},
        cashReward: 10000,
        turnLimit: 5,
        difficulty: 1,
        status: ContractStatus.active,
        acceptedOnTurn: 1,
        progress: 0,
      );

      // Create player at Los Angeles
      final player = Player.newPlayer(
        id: '1',
        name: 'Player',
        startingLocation: 0, // Los Angeles
      );

      final result = service.evaluateProgress(contract, player, 1);
      expect(result, isNotNull);
      expect(result!.progress, greaterThan(0));
    });

    test('checkCompletion returns false for expired contract', () {
      final contract = const Contract(
        id: 'test',
        title: 'Test',
        description: 'Test',
        type: ContractType.transport,
        locations: {},
        cashReward: 10000,
        turnLimit: 5,
        difficulty: 1,
        status: ContractStatus.active,
        acceptedOnTurn: 1,
        progress: 100,
      );

      final player = Player.newPlayer(
        id: '1',
        name: 'Player',
        startingLocation: 0,
      );

      // Check at turn 10 (expired: 10 - 1 = 9 > 5)
      final isCompleted = service.checkCompletion(contract, player, 10);
      expect(isCompleted, false);
    });

    test('checkCompletion returns true for completed transport', () {
      final contract = const Contract(
        id: 'test',
        title: 'Test',
        description: 'Test',
        type: ContractType.transport,
        locations: {LocationType.losAngeles},
        cashReward: 10000,
        turnLimit: 10,
        difficulty: 1,
        status: ContractStatus.active,
        acceptedOnTurn: 1,
        progress: 100,
      );

      final player = Player.newPlayer(
        id: '1',
        name: 'Player',
        startingLocation: 0,
      );

      // Check at turn 5 (not expired: 5 - 1 = 4 <= 10)
      final isCompleted = service.checkCompletion(contract, player, 5);
      expect(isCompleted, true);
    });
  });
}

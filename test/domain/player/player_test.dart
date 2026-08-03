import 'package:dopewars_flutter/core/constants/game_constants.dart';
import 'package:dopewars_flutter/core/value_objects/health.dart';
import 'package:dopewars_flutter/core/value_objects/money.dart';
import 'package:dopewars_flutter/domain/game/entities/game_event.dart';
import 'package:dopewars_flutter/domain/player/entities/player.dart';
import 'package:dopewars_flutter/domain/player/value_objects/player_flags.dart';
import 'package:dopewars_flutter/domain/trading/entities/drug.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Player', () {
    late Player player;

    setUp(() {
      player = Player.newPlayer(
        id: 'test-id',
        name: 'Test Player',
      );
    });

    group('new player creation', () {
      test('creates player with correct starting values', () {
        expect(player.name, 'Test Player');
        expect(player.turn, 1);
        expect(player.cash.dollars, GameConstants.startCash);
        expect(player.debt.dollars, GameConstants.startDebt);
        expect(player.bank.dollars, 0);
        expect(player.health.value, 100);
        expect(player.coatSize.value, GameConstants.startCoatSize);
        expect(player.locationIndex, 0);
        expect(player.bitches, 0);
        expect(player.copIndex, 0);
        expect(player.currentEvent, GameEvent.none);
      });

      test('starts with first turn flag set', () {
        expect(player.flags.isFirstTurn, true);
      });

      test('starts with correct date', () {
        expect(player.date.year, GameConstants.startYear);
        expect(player.date.month, GameConstants.startMonth);
        expect(player.date.day, GameConstants.startDay);
      });

      test('starts with empty inventory', () {
        expect(player.drugs.isEmpty, true);
        expect(player.guns.isEmpty, true);
        expect(player.totalDrugsCarried, 0);
        expect(player.totalGunsCarried, 0);
      });

      test('can set custom starting location', () {
        final customPlayer = Player.newPlayer(
          id: 'test',
          name: 'Test',
          startingLocation: 5,
        );
        expect(customPlayer.locationIndex, 5);
      });
    });

    group('state checks', () {
      test('isAlive when health is positive', () {
        expect(player.isAlive, true);
        expect(player.isDead, false);
      });

      test('isDead when health is zero', () {
        final deadPlayer = player.copyWith(health: Health.dead);
        expect(deadPlayer.isDead, true);
        expect(deadPlayer.isAlive, false);
      });

      test('isGameOver when dead', () {
        final deadPlayer = player.copyWith(health: Health.dead);
        expect(deadPlayer.isGameOver, true);
      });

      test('isGameOver when exceeded turns', () {
        final finishedPlayer = player.copyWith(turn: GameConstants.numTurns + 1);
        expect(finishedPlayer.isGameOver, true);
      });

      test('not game over during normal play', () {
        expect(player.isGameOver, false);
      });

      test('isInCombat when fighting flag set', () {
        final fightingPlayer = player.copyWith(
          flags: player.flags.withFlag(PlayerFlag.fighting),
        );
        expect(fightingPlayer.isInCombat, true);
        expect(player.isInCombat, false);
      });
    });

    group('net worth calculation', () {
      test('calculates basic net worth', () {
        // Starting: cash=2000, debt=5500, bank=0
        // Net worth = 2000 + 0 - 5500 = -3500
        expect(player.netWorth.dollars, -3500);
      });

      test('includes bank balance', () {
        final playerWithBank = player.copyWith(bank: const Money(1000));
        // 2000 + 1000 - 5500 = -2500
        expect(playerWithBank.netWorth.dollars, -2500);
      });

      test('includes drug inventory value', () {
        var playerWithDrugs = player.addDrug(DrugType.weed, 10, const Money(100));
        // 2000 + 0 - 5500 + 1000 (10 * 100) = -2500
        expect(playerWithDrugs.netWorth.dollars, -2500);
      });
    });

    group('carrying capacity', () {
      test('starts with full capacity', () {
        expect(player.availableSpace, GameConstants.startCoatSize);
      });

      test('drug reduces available space', () {
        final playerWithDrugs = player.addDrug(DrugType.weed, 10, const Money(100));
        expect(playerWithDrugs.availableSpace, GameConstants.startCoatSize - 10);
      });

      test('gun reduces available space', () {
        // Each gun takes 4 space
        final playerWithGun = player.addGun(0, const Money(3000));
        expect(playerWithGun.availableSpace, GameConstants.startCoatSize - 4);
      });

      test('canCarry checks capacity', () {
        expect(player.canCarry(50), true);
        expect(player.canCarry(100), true);
        expect(player.canCarry(101), false);
      });
    });

    group('drug inventory management', () {
      test('addDrug adds drugs to inventory', () {
        final updated = player.addDrug(DrugType.weed, 10, const Money(100));
        expect(updated.getDrugInventory(DrugType.weed).carried, 10);
        expect(updated.totalDrugsCarried, 10);
      });

      test('addDrug calculates average price', () {
        var updated = player.addDrug(DrugType.weed, 10, const Money(100));
        updated = updated.addDrug(DrugType.weed, 10, const Money(200));
        // Average of 100 and 200 = 150
        expect(updated.getDrugInventory(DrugType.weed).price.dollars, 150);
        expect(updated.getDrugInventory(DrugType.weed).carried, 20);
      });

      test('removeDrug removes drugs from inventory', () {
        var updated = player.addDrug(DrugType.weed, 10, const Money(100));
        updated = updated.removeDrug(DrugType.weed, 5);
        expect(updated.getDrugInventory(DrugType.weed).carried, 5);
      });

      test('removeDrug clears inventory when all removed', () {
        var updated = player.addDrug(DrugType.weed, 10, const Money(100));
        updated = updated.removeDrug(DrugType.weed, 10);
        expect(updated.getDrugInventory(DrugType.weed).isEmpty, true);
        expect(updated.drugs.containsKey(DrugType.weed), false);
      });

      test('removeDrug throws if not enough', () {
        final updated = player.addDrug(DrugType.weed, 5, const Money(100));
        expect(
          () => updated.removeDrug(DrugType.weed, 10),
          throwsArgumentError,
        );
      });
    });

    group('gun inventory management', () {
      test('addGun adds gun to inventory', () {
        final updated = player.addGun(0, const Money(3000));
        expect(updated.getGunInventory(0).carried, 1);
        expect(updated.totalGunsCarried, 1);
      });

      test('can add multiple guns of same type', () {
        var updated = player.addGun(0, const Money(3000));
        updated = updated.addGun(0, const Money(3000));
        expect(updated.getGunInventory(0).carried, 2);
      });

      test('removeGun removes gun from inventory', () {
        var updated = player.addGun(0, const Money(3000));
        updated = updated.addGun(0, const Money(3000));
        updated = updated.removeGun(0);
        expect(updated.getGunInventory(0).carried, 1);
      });

      test('removeGun throws if none available', () {
        expect(
          () => player.removeGun(0),
          throwsArgumentError,
        );
      });
    });

    group('copyWith', () {
      test('copies with new cash', () {
        final updated = player.copyWith(cash: const Money(5000));
        expect(updated.cash.dollars, 5000);
        expect(updated.name, player.name); // Other fields unchanged
      });

      test('copies with new location', () {
        final updated = player.copyWith(locationIndex: 5);
        expect(updated.locationIndex, 5);
      });

      test('copies with new flags', () {
        final updated = player.copyWith(
          flags: player.flags.withFlag(PlayerFlag.fighting),
        );
        expect(updated.flags.isFighting, true);
        expect(player.flags.isFighting, false); // Original unchanged
      });
    });

    group('equality', () {
      test('players with same state are equal', () {
        final player1 = Player.newPlayer(id: 'test', name: 'Test');
        final player2 = Player.newPlayer(id: 'test', name: 'Test');
        expect(player1, equals(player2));
      });

      test('players with different state are not equal', () {
        final player1 = Player.newPlayer(id: 'test1', name: 'Test');
        final player2 = Player.newPlayer(id: 'test2', name: 'Test');
        expect(player1, isNot(equals(player2)));
      });
    });
  });
}

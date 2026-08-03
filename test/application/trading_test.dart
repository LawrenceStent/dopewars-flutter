import 'package:dopewars_flutter/application/trading/buy_drug.dart';
import 'package:dopewars_flutter/application/trading/sell_drug.dart';
import 'package:dopewars_flutter/application/trading/trading_result.dart';
import 'package:dopewars_flutter/core/value_objects/money.dart';
import 'package:dopewars_flutter/domain/player/entities/player.dart';
import 'package:dopewars_flutter/domain/trading/entities/drug.dart';
import 'package:dopewars_flutter/domain/trading/entities/drug_market.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Player player;
  late DrugMarket market;

  setUp(() {
    player = Player.newPlayer(id: 'test', name: 'Test Player');
    // Create a market with known prices
    market = DrugMarket(
      locationIndex: 0,
      prices: {
        DrugType.weed: const DrugPrice(
          drugType: DrugType.weed,
          price: Money(500),
          dealType: DealType.normal,
        ),
        DrugType.ludes: const DrugPrice(
          drugType: DrugType.ludes,
          price: Money(30),
          dealType: DealType.normal,
        ),
        DrugType.cocaine: const DrugPrice(
          drugType: DrugType.cocaine,
          price: Money(20000),
          dealType: DealType.normal,
        ),
      },
    );
  });

  group('BuyDrug', () {
    const buyDrug = BuyDrug();

    test('successfully buys drugs', () {
      final result = buyDrug.execute(
        player: player,
        market: market,
        drugType: DrugType.weed,
        quantity: 3,
      );

      expect(result, isA<TradeSuccess>());
      final success = result as TradeSuccess;
      expect(success.drugType, DrugType.weed);
      expect(success.quantity, 3);
      expect(success.totalAmount.dollars, 1500); // 3 * 500
      expect(success.updatedPlayer.getDrugInventory(DrugType.weed).carried, 3);
      expect(success.updatedPlayer.cash.dollars, 500); // 2000 - 1500
    });

    test('fails when drug not available', () {
      final result = buyDrug.execute(
        player: player,
        market: market,
        drugType: DrugType.heroin, // Not in market
        quantity: 1,
      );

      expect(result, isA<TradeFailure>());
      final failure = result as TradeFailure;
      expect(failure.error, TradeError.drugNotAvailable);
    });

    test('fails when cannot afford', () {
      final result = buyDrug.execute(
        player: player,
        market: market,
        drugType: DrugType.cocaine, // 20000 each, player has 2000
        quantity: 1,
      );

      expect(result, isA<TradeFailure>());
      final failure = result as TradeFailure;
      expect(failure.error, TradeError.insufficientFunds);
    });

    test('fails when not enough space', () {
      // Give player lots of cash so they can afford it
      final richPlayer = player.copyWith(cash: const Money(10000));

      // Player has 100 space, trying to buy 101
      final result = buyDrug.execute(
        player: richPlayer,
        market: market,
        drugType: DrugType.ludes, // Cheap, can afford many
        quantity: 101,
      );

      expect(result, isA<TradeFailure>());
      final failure = result as TradeFailure;
      expect(failure.error, TradeError.insufficientSpace);
    });

    test('fails when quantity is zero or negative', () {
      var result = buyDrug.execute(
        player: player,
        market: market,
        drugType: DrugType.weed,
        quantity: 0,
      );
      expect(result, isA<TradeFailure>());
      expect((result as TradeFailure).error, TradeError.invalidQuantity);

      result = buyDrug.execute(
        player: player,
        market: market,
        drugType: DrugType.weed,
        quantity: -5,
      );
      expect(result, isA<TradeFailure>());
      expect((result as TradeFailure).error, TradeError.invalidQuantity);
    });

    test('calculates maxBuyable correctly', () {
      // Player has $2000, weed costs $500
      // Can afford 4, but has 100 space
      var max = buyDrug.maxBuyable(
        player: player,
        market: market,
        drugType: DrugType.weed,
      );
      expect(max, 4); // Limited by cash

      // Ludes cost $30, player has $2000
      // Can afford 66, but has 100 space
      max = buyDrug.maxBuyable(
        player: player,
        market: market,
        drugType: DrugType.ludes,
      );
      expect(max, 66); // Limited by cash (2000 / 30 = 66)
    });
  });

  group('SellDrug', () {
    const sellDrug = SellDrug();

    test('successfully sells drugs', () {
      // First give player some drugs
      final playerWithDrugs = player.addDrug(DrugType.weed, 10, const Money(400));

      final result = sellDrug.execute(
        player: playerWithDrugs,
        market: market,
        drugType: DrugType.weed,
        quantity: 5,
      );

      expect(result, isA<TradeSuccess>());
      final success = result as TradeSuccess;
      expect(success.drugType, DrugType.weed);
      expect(success.quantity, 5);
      expect(success.totalAmount.dollars, 2500); // 5 * 500
      expect(success.updatedPlayer.getDrugInventory(DrugType.weed).carried, 5);
      expect(success.updatedPlayer.cash.dollars, 4500); // 2000 + 2500
    });

    test('calculates profit correctly', () {
      // Buy at 400, sell at 500 = profit of 100 per unit
      final playerWithDrugs = player.addDrug(DrugType.weed, 10, const Money(400));

      final result = sellDrug.execute(
        player: playerWithDrugs,
        market: market,
        drugType: DrugType.weed,
        quantity: 10, // Sell all to get profit message
      );

      expect(result, isA<TradeSuccess>());
      final success = result as TradeSuccess;
      expect(success.profit!.dollars, 1000); // 10 * (500 - 400)
      expect(success.message.contains('profit'), true);
    });

    test('shows loss when selling for less than bought', () {
      // Buy at 600, sell at 500 = loss of 100 per unit
      final playerWithDrugs = player.addDrug(DrugType.weed, 10, const Money(600));

      final result = sellDrug.execute(
        player: playerWithDrugs,
        market: market,
        drugType: DrugType.weed,
        quantity: 10,
      );

      expect(result, isA<TradeSuccess>());
      final success = result as TradeSuccess;
      expect(success.profit!.dollars, -1000); // 10 * (500 - 600)
      expect(success.message.contains('lost'), true);
    });

    test('fails when drug not available at market', () {
      final playerWithDrugs = player.addDrug(DrugType.heroin, 10, const Money(5000));

      final result = sellDrug.execute(
        player: playerWithDrugs,
        market: market,
        drugType: DrugType.heroin, // Not in market
        quantity: 5,
      );

      expect(result, isA<TradeFailure>());
      final failure = result as TradeFailure;
      expect(failure.error, TradeError.drugNotAvailable);
    });

    test('fails when player has none to sell', () {
      final result = sellDrug.execute(
        player: player,
        market: market,
        drugType: DrugType.weed,
        quantity: 5,
      );

      expect(result, isA<TradeFailure>());
      final failure = result as TradeFailure;
      expect(failure.error, TradeError.insufficientInventory);
    });

    test('fails when selling more than owned', () {
      final playerWithDrugs = player.addDrug(DrugType.weed, 5, const Money(400));

      final result = sellDrug.execute(
        player: playerWithDrugs,
        market: market,
        drugType: DrugType.weed,
        quantity: 10, // Only has 5
      );

      expect(result, isA<TradeFailure>());
      final failure = result as TradeFailure;
      expect(failure.error, TradeError.insufficientInventory);
    });

    test('fails when quantity is zero or negative', () {
      final playerWithDrugs = player.addDrug(DrugType.weed, 10, const Money(400));

      var result = sellDrug.execute(
        player: playerWithDrugs,
        market: market,
        drugType: DrugType.weed,
        quantity: 0,
      );
      expect(result, isA<TradeFailure>());
      expect((result as TradeFailure).error, TradeError.invalidQuantity);

      result = sellDrug.execute(
        player: playerWithDrugs,
        market: market,
        drugType: DrugType.weed,
        quantity: -5,
      );
      expect(result, isA<TradeFailure>());
      expect((result as TradeFailure).error, TradeError.invalidQuantity);
    });

    test('calculates maxSellable correctly', () {
      final playerWithDrugs = player.addDrug(DrugType.weed, 25, const Money(400));

      final max = sellDrug.maxSellable(
        player: playerWithDrugs,
        market: market,
        drugType: DrugType.weed,
      );
      expect(max, 25);
    });
  });
}

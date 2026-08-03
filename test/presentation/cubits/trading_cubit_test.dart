import 'package:dopewars_flutter/application/trading/trading_result.dart';
import 'package:dopewars_flutter/core/value_objects/money.dart';
import 'package:dopewars_flutter/domain/player/entities/player.dart';
import 'package:dopewars_flutter/domain/trading/entities/drug.dart';
import 'package:dopewars_flutter/domain/trading/entities/drug_market.dart';
import 'package:dopewars_flutter/presentation/cubits/trading/trading_cubit.dart';
import 'package:dopewars_flutter/presentation/cubits/trading/trading_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Player player;
  late DrugMarket market;
  late TradingCubit cubit;
  Player? lastUpdatedPlayer;

  setUp(() {
    lastUpdatedPlayer = null;
    player = Player.newPlayer(id: 'test', name: 'Test Player');
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
          dealType: DealType.cheap,
          message: 'Cheap ludes!',
        ),
      },
    );
    cubit = TradingCubit(
      player: player,
      market: market,
      onPlayerUpdated: (p) => lastUpdatedPlayer = p,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('TradingCubit', () {
    test('initial state has player and market', () {
      expect(cubit.state.player, player);
      expect(cubit.state.market, market);
      expect(cubit.state.selectedDrug, null);
      expect(cubit.state.mode, TradeMode.none);
      expect(cubit.state.quantity, 1);
    });

    group('drug selection', () {
      test('selectDrug updates selected drug', () {
        cubit.selectDrug(DrugType.weed);

        expect(cubit.state.selectedDrug, DrugType.weed);
        expect(cubit.state.quantity, 1);
      });

      test('clearSelection clears drug and resets state', () {
        cubit.selectDrug(DrugType.weed);
        cubit.setMode(TradeMode.buy);
        cubit.setQuantity(5);

        cubit.clearSelection();

        expect(cubit.state.selectedDrug, null);
        expect(cubit.state.mode, TradeMode.none);
        expect(cubit.state.quantity, 1);
      });
    });

    group('trade mode', () {
      test('setMode updates mode', () {
        cubit.selectDrug(DrugType.weed);
        cubit.setMode(TradeMode.buy);

        expect(cubit.state.mode, TradeMode.buy);
      });

      test('setMode resets quantity to 1', () {
        cubit.selectDrug(DrugType.weed);
        cubit.setMode(TradeMode.buy);
        cubit.setQuantity(5);
        cubit.setMode(TradeMode.sell);

        expect(cubit.state.quantity, 1);
      });
    });

    group('quantity management', () {
      test('setQuantity clamps to valid range for buy', () {
        cubit.selectDrug(DrugType.weed);
        cubit.setMode(TradeMode.buy);

        // Max buyable is 4 (2000 / 500)
        cubit.setQuantity(10);
        expect(cubit.state.quantity, 4);

        cubit.setQuantity(-5);
        expect(cubit.state.quantity, 0);
      });

      test('incrementQuantity increases by amount', () {
        cubit.selectDrug(DrugType.weed);
        cubit.setMode(TradeMode.buy);

        cubit.incrementQuantity();
        expect(cubit.state.quantity, 2);

        cubit.incrementQuantity(2);
        expect(cubit.state.quantity, 4); // Clamped to max
      });

      test('decrementQuantity decreases by amount', () {
        cubit.selectDrug(DrugType.weed);
        cubit.setMode(TradeMode.buy);
        cubit.setQuantity(3);

        cubit.decrementQuantity();
        expect(cubit.state.quantity, 2);

        cubit.decrementQuantity(5);
        expect(cubit.state.quantity, 0); // Clamped to 0
      });

      test('setMaxQuantity sets to maximum', () {
        cubit.selectDrug(DrugType.weed);
        cubit.setMode(TradeMode.buy);

        cubit.setMaxQuantity();
        expect(cubit.state.quantity, 4); // 2000 / 500
      });
    });

    group('buying', () {
      test('executeBuy succeeds with valid selection', () {
        cubit.selectDrug(DrugType.weed);
        cubit.setMode(TradeMode.buy);
        cubit.setQuantity(2);

        cubit.executeBuy();

        expect(cubit.state.lastResult, isA<TradeSuccess>());
        expect(cubit.state.player.getDrugInventory(DrugType.weed).carried, 2);
        expect(cubit.state.player.cash.dollars, 1000); // 2000 - 1000
        expect(lastUpdatedPlayer, isNotNull);
      });

      test('quickBuy performs buy in one action', () {
        cubit.quickBuy(DrugType.weed, 3);

        expect(cubit.state.lastResult, isA<TradeSuccess>());
        expect(cubit.state.player.getDrugInventory(DrugType.weed).carried, 3);
        expect(cubit.state.player.cash.dollars, 500); // 2000 - 1500
      });

      test('executeBuy clears selection after success', () {
        cubit.selectDrug(DrugType.weed);
        cubit.setMode(TradeMode.buy);
        cubit.setQuantity(1);

        cubit.executeBuy();

        expect(cubit.state.selectedDrug, null);
        expect(cubit.state.mode, TradeMode.none);
        expect(cubit.state.quantity, 1);
      });

      test('quickBuy shows error on failure', () {
        // Use quickBuy which bypasses quantity clamping
        // Try to buy a drug not available in the market
        cubit.quickBuy(DrugType.heroin, 1);

        expect(cubit.state.lastResult, isA<TradeFailure>());
        expect(cubit.state.messages.isNotEmpty, true);
      });
    });

    group('selling', () {
      late Player playerWithDrugs;

      setUp(() {
        playerWithDrugs = player.addDrug(DrugType.weed, 10, const Money(400));
        cubit = TradingCubit(
          player: playerWithDrugs,
          market: market,
          onPlayerUpdated: (p) => lastUpdatedPlayer = p,
        );
      });

      test('executeSell succeeds with valid selection', () {
        cubit.selectDrug(DrugType.weed);
        cubit.setMode(TradeMode.sell);
        cubit.setQuantity(5);

        cubit.executeSell();

        expect(cubit.state.lastResult, isA<TradeSuccess>());
        expect(cubit.state.player.getDrugInventory(DrugType.weed).carried, 5);
        // 2000 + (5 * 500) = 4500
        expect(cubit.state.player.cash.dollars, 4500);
      });

      test('quickSell performs sell in one action', () {
        cubit.quickSell(DrugType.weed, 3);

        expect(cubit.state.lastResult, isA<TradeSuccess>());
        expect(cubit.state.player.getDrugInventory(DrugType.weed).carried, 7);
        // 2000 + (3 * 500) = 3500
        expect(cubit.state.player.cash.dollars, 3500);
      });

      test('executeSell calculates profit', () {
        cubit.selectDrug(DrugType.weed);
        cubit.setMode(TradeMode.sell);
        cubit.setQuantity(10); // Sell all

        cubit.executeSell();

        final result = cubit.state.lastResult as TradeSuccess;
        // Bought at 400, selling at 500, 10 units = 1000 profit
        expect(result.profit!.dollars, 1000);
      });
    });

    group('state calculations', () {
      test('maxBuyable calculated correctly', () {
        cubit.selectDrug(DrugType.weed);
        cubit.setMode(TradeMode.buy);

        expect(cubit.state.maxBuyable, 4); // 2000 / 500
      });

      test('maxSellable calculated correctly', () {
        final playerWithDrugs = player.addDrug(DrugType.weed, 15, const Money(400));
        cubit = TradingCubit(player: playerWithDrugs, market: market);

        cubit.selectDrug(DrugType.weed);
        cubit.setMode(TradeMode.sell);

        expect(cubit.state.maxSellable, 15);
      });

      test('totalBuyCost calculated correctly', () {
        cubit.selectDrug(DrugType.weed);
        cubit.setMode(TradeMode.buy);
        cubit.setQuantity(3);

        expect(cubit.state.totalBuyCost.dollars, 1500);
      });

      test('totalSellValue calculated correctly', () {
        final playerWithDrugs = player.addDrug(DrugType.weed, 10, const Money(400));
        cubit = TradingCubit(player: playerWithDrugs, market: market);

        cubit.selectDrug(DrugType.weed);
        cubit.setMode(TradeMode.sell);
        cubit.setQuantity(5);

        expect(cubit.state.totalSellValue.dollars, 2500);
      });

      test('canBuy is true when valid', () {
        cubit.selectDrug(DrugType.weed);
        cubit.setMode(TradeMode.buy);
        cubit.setQuantity(2);

        expect(cubit.state.canBuy, true);
      });

      test('canBuy is false when invalid', () {
        cubit.selectDrug(DrugType.weed);
        cubit.setMode(TradeMode.sell); // Wrong mode

        expect(cubit.state.canBuy, false);
      });
    });

    group('helper methods', () {
      test('getAvailableDrugsSortedByPrice sorts ascending', () {
        final sorted = cubit.getAvailableDrugsSortedByPrice(ascending: true);

        expect(sorted.first, DrugType.ludes); // 30
        expect(sorted.last, DrugType.weed); // 500
      });

      test('getAvailableDrugsSortedByPrice sorts descending', () {
        final sorted = cubit.getAvailableDrugsSortedByPrice(ascending: false);

        expect(sorted.first, DrugType.weed); // 500
        expect(sorted.last, DrugType.ludes); // 30
      });

      test('getPlayerDrugsWithInventory returns owned drugs', () {
        final playerWithDrugs = player
            .addDrug(DrugType.weed, 10, const Money(400))
            .addDrug(DrugType.ludes, 5, const Money(20));

        cubit = TradingCubit(player: playerWithDrugs, market: market);

        final owned = cubit.getPlayerDrugsWithInventory();
        expect(owned.length, 2);
        expect(owned.contains(DrugType.weed), true);
        expect(owned.contains(DrugType.ludes), true);
      });
    });

    group('updateState', () {
      test('updates player and market', () {
        final newPlayer = player.copyWith(cash: const Money(5000));
        final newMarket = DrugMarket(
          locationIndex: 1,
          prices: {
            DrugType.cocaine: const DrugPrice(
              drugType: DrugType.cocaine,
              price: Money(25000),
              dealType: DealType.normal,
            ),
          },
        );

        cubit.updateState(player: newPlayer, market: newMarket);

        expect(cubit.state.player.cash.dollars, 5000);
        expect(cubit.state.market.locationIndex, 1);
      });
    });
  });
}

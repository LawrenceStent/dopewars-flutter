import 'package:dopewars_flutter/core/value_objects/money.dart';
import 'package:dopewars_flutter/domain/player/entities/player.dart';
import 'package:dopewars_flutter/domain/trading/entities/drug.dart';
import 'package:dopewars_flutter/domain/trading/entities/drug_market.dart';
import 'package:dopewars_flutter/presentation/widgets/inventory_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Player emptyPlayer;
  late Player playerWithDrugs;
  late DrugMarket market;

  setUp(() {
    emptyPlayer = Player.newPlayer(id: 'test', name: 'Test Player');
    playerWithDrugs = emptyPlayer
        .addDrug(DrugType.weed, 10, const Money(400))
        .addDrug(DrugType.cocaine, 5, const Money(15000));
    market = DrugMarket(
      locationIndex: 0,
      prices: {
        DrugType.weed: const DrugPrice(
          drugType: DrugType.weed,
          price: Money(500),
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

  Widget buildTestWidget({
    required Player player,
    DrugMarket? market,
    void Function(DrugType, int)? onSell,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: InventoryWidget(
          player: player,
          market: market,
          onSell: onSell,
        ),
      ),
    );
  }

  group('InventoryWidget', () {
    testWidgets('shows empty state when player has no drugs', (tester) async {
      await tester.pumpWidget(buildTestWidget(player: emptyPlayer));

      expect(find.text('Your pockets are empty'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('shows drugs in inventory', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(player: playerWithDrugs, market: market),
      );

      expect(find.text('Weed'), findsOneWidget);
      expect(find.text('Cocaine'), findsOneWidget);
    });

    testWidgets('shows quantity and average price', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(player: playerWithDrugs, market: market),
      );

      // Check for quantity display
      expect(find.textContaining('Qty: 10'), findsOneWidget);
      expect(find.textContaining('Qty: 5'), findsOneWidget);
    });

    testWidgets('shows current market price when available', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(player: playerWithDrugs, market: market),
      );

      // Should show current price from market
      expect(find.textContaining('Now:'), findsNWidgets(2));
    });

    testWidgets('shows SELL button when market available', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          player: playerWithDrugs,
          market: market,
          onSell: (type, qty) {},
        ),
      );

      expect(find.text('SELL'), findsNWidgets(2));
    });

    testWidgets('shows "No buyers here" when drug not in market',
        (tester) async {
      final playerWithHeroin =
          emptyPlayer.addDrug(DrugType.heroin, 5, const Money(5000));

      await tester.pumpWidget(
        buildTestWidget(
          player: playerWithHeroin,
          market: market,
          onSell: (type, qty) {},
        ),
      );

      expect(find.text('No buyers here'), findsOneWidget);
    });

    testWidgets('shows profit indicator for profitable sale', (tester) async {
      // Player bought weed at 400, market price is 500 = profit
      await tester.pumpWidget(
        buildTestWidget(player: playerWithDrugs, market: market),
      );

      // Should show positive profit indicator
      expect(find.textContaining('+\$100/unit'), findsOneWidget);
    });

    testWidgets('shows loss indicator when selling at loss', (tester) async {
      // Player bought cocaine at 15000, market price is 20000 = profit
      // Let's create a scenario with a loss
      final playerWithLoss =
          emptyPlayer.addDrug(DrugType.weed, 5, const Money(600));
      final lowPriceMarket = DrugMarket(
        locationIndex: 0,
        prices: {
          DrugType.weed: const DrugPrice(
            drugType: DrugType.weed,
            price: Money(400),
            dealType: DealType.cheap,
          ),
        },
      );

      await tester.pumpWidget(
        buildTestWidget(player: playerWithLoss, market: lowPriceMarket),
      );

      // Should show negative profit indicator
      expect(find.textContaining('-\$200/unit'), findsOneWidget);
    });

    testWidgets('opens sell dialog when SELL pressed', (tester) async {
      // Use a player with only one drug to avoid multiple SELL buttons
      final singleDrugPlayer =
          emptyPlayer.addDrug(DrugType.weed, 10, const Money(400));

      await tester.pumpWidget(
        buildTestWidget(
          player: singleDrugPlayer,
          market: market,
          onSell: (type, qty) {},
        ),
      );

      // Tap the SELL button
      await tester.tap(find.text('SELL'));
      await tester.pumpAndSettle();

      // Dialog should appear with the drug name in the title
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
    });

    testWidgets('sell dialog shows quantity controls', (tester) async {
      final singleDrugPlayer =
          emptyPlayer.addDrug(DrugType.weed, 10, const Money(400));

      await tester.pumpWidget(
        buildTestWidget(
          player: singleDrugPlayer,
          market: market,
          onSell: (type, qty) {},
        ),
      );

      await tester.tap(find.text('SELL'));
      await tester.pumpAndSettle();

      // Should have increment/decrement buttons
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);

      // Should have quick select buttons
      expect(find.text('ALL'), findsOneWidget);
    });

    testWidgets('sell dialog calls onSell with quantity', (tester) async {
      DrugType? soldType;
      int? soldQuantity;

      final singleDrugPlayer =
          emptyPlayer.addDrug(DrugType.weed, 10, const Money(400));

      await tester.pumpWidget(
        buildTestWidget(
          player: singleDrugPlayer,
          market: market,
          onSell: (type, qty) {
            soldType = type;
            soldQuantity = qty;
          },
        ),
      );

      await tester.tap(find.text('SELL'));
      await tester.pumpAndSettle();

      // Find the SELL button inside the dialog (AlertDialog's actions)
      final dialogSellButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, 'SELL'),
      );
      await tester.tap(dialogSellButton);
      await tester.pumpAndSettle();

      expect(soldType, DrugType.weed);
      expect(soldQuantity, 1);
    });

    testWidgets('sell dialog increments quantity', (tester) async {
      DrugType? soldType;
      int? soldQuantity;

      final singleDrugPlayer =
          emptyPlayer.addDrug(DrugType.weed, 10, const Money(400));

      await tester.pumpWidget(
        buildTestWidget(
          player: singleDrugPlayer,
          market: market,
          onSell: (type, qty) {
            soldType = type;
            soldQuantity = qty;
          },
        ),
      );

      await tester.tap(find.text('SELL'));
      await tester.pumpAndSettle();

      // Tap increment
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Confirm sell via dialog button
      final dialogSellButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, 'SELL'),
      );
      await tester.tap(dialogSellButton);
      await tester.pumpAndSettle();

      expect(soldType, DrugType.weed);
      expect(soldQuantity, 3);
    });

    testWidgets('sell dialog ALL button sets max quantity', (tester) async {
      DrugType? soldType;
      int? soldQuantity;

      final singleDrugPlayer =
          emptyPlayer.addDrug(DrugType.weed, 10, const Money(400));

      await tester.pumpWidget(
        buildTestWidget(
          player: singleDrugPlayer,
          market: market,
          onSell: (type, qty) {
            soldType = type;
            soldQuantity = qty;
          },
        ),
      );

      await tester.tap(find.text('SELL'));
      await tester.pumpAndSettle();

      // Tap ALL
      await tester.tap(find.text('ALL'));
      await tester.pumpAndSettle();

      // Confirm sell via dialog button
      final dialogSellButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, 'SELL'),
      );
      await tester.tap(dialogSellButton);
      await tester.pumpAndSettle();

      expect(soldType, DrugType.weed);
      expect(soldQuantity, 10);
    });

    testWidgets('cancel button closes dialog without selling', (tester) async {
      bool sellCalled = false;

      final singleDrugPlayer =
          emptyPlayer.addDrug(DrugType.weed, 10, const Money(400));

      await tester.pumpWidget(
        buildTestWidget(
          player: singleDrugPlayer,
          market: market,
          onSell: (type, qty) => sellCalled = true,
        ),
      );

      await tester.tap(find.text('SELL'));
      await tester.pumpAndSettle();

      // Cancel
      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(sellCalled, false);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}

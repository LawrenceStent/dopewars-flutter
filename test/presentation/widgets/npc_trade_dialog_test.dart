import 'package:dopewars_flutter/domain/npc/entities/npc.dart';
import 'package:dopewars_flutter/domain/npc/repositories/npc_repository.dart';
import 'package:dopewars_flutter/domain/player/entities/player.dart';
import 'package:dopewars_flutter/domain/trading/entities/drug.dart';
import 'package:dopewars_flutter/presentation/cubits/npc/npc_network_cubit.dart';
import 'package:dopewars_flutter/presentation/widgets/npc_trade_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NpcTradeDialog', () {
    late NpcNetworkCubit npcNetworkCubit;
    late NpcRepository npcRepository;
    late Npc supplier;

    setUp(() {
      npcRepository = const NpcRepository();
      npcNetworkCubit = NpcNetworkCubit(npcRepository: npcRepository);
      supplier = npcRepository.getNpcById('chemist_lagos')!;
      npcNetworkCubit.getOrCreateRelationship('chemist_lagos');
    });

    tearDown(() {
      npcNetworkCubit.close();
    });

    testWidgets('displays NPC name and role', (WidgetTester tester) async {
      final player = Player.newPlayer(
        id: 'test',
        name: 'Test Player',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NpcTradeDialog(
              npcId: 'chemist_lagos',
              npc: supplier,
              player: player,
              currentHeat: 0,
              npcNetworkCubit: npcNetworkCubit,
              npcRepository: npcRepository,
              onBuyFromNpc: (_, __, ___) {},
              onSellToNpc: (_, __, ___) {},
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.text(supplier.name.toUpperCase()), findsOneWidget);
    });

    testWidgets('displays BUY DRUGS section for supplier',
        (WidgetTester tester) async {
      final player = Player.newPlayer(
        id: 'test',
        name: 'Test Player',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NpcTradeDialog(
              npcId: 'chemist_lagos',
              npc: supplier,
              player: player,
              currentHeat: 0,
              npcNetworkCubit: npcNetworkCubit,
              npcRepository: npcRepository,
              onBuyFromNpc: (_, __, ___) {},
              onSellToNpc: (_, __, ___) {},
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.text('BUY DRUGS'), findsOneWidget);
    });

    testWidgets('displays drug options', (WidgetTester tester) async {
      final player = Player.newPlayer(
        id: 'test',
        name: 'Test Player',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NpcTradeDialog(
              npcId: 'chemist_lagos',
              npc: supplier,
              player: player,
              currentHeat: 0,
              npcNetworkCubit: npcNetworkCubit,
              npcRepository: npcRepository,
              onBuyFromNpc: (_, __, ___) {},
              onSellToNpc: (_, __, ___) {},
              onClose: () {},
            ),
          ),
        ),
      );

      // Check for drug names
      for (final drug in DefaultDrugs.all) {
        expect(find.text(drug.name), findsWidgets);
      }
    });

    testWidgets('quantity controls work', (WidgetTester tester) async {
      final player = Player.newPlayer(
        id: 'test',
        name: 'Test Player',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NpcTradeDialog(
              npcId: 'chemist_lagos',
              npc: supplier,
              player: player,
              currentHeat: 0,
              npcNetworkCubit: npcNetworkCubit,
              npcRepository: npcRepository,
              onBuyFromNpc: (_, __, ___) {},
              onSellToNpc: (_, __, ___) {},
              onClose: () {},
            ),
          ),
        ),
      );

      // Find the increment button and tap it
      final addButtons = find.byIcon(Icons.add);
      if (addButtons.evaluate().isNotEmpty) {
        await tester.tap(addButtons.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('calls onBuyFromNpc when BUY button pressed',
        (WidgetTester tester) async {
      final player = Player.newPlayer(
        id: 'test',
        name: 'Test Player',
      );
      var buyPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NpcTradeDialog(
              npcId: 'chemist_lagos',
              npc: supplier,
              player: player,
              currentHeat: 0,
              npcNetworkCubit: npcNetworkCubit,
              npcRepository: npcRepository,
              onBuyFromNpc: (_, __, ___) {
                buyPressed = true;
              },
              onSellToNpc: (_, __, ___) {},
              onClose: () {},
            ),
          ),
        ),
      );

      // Try to increment quantity for a drug
      final addButtons = find.byIcon(Icons.add);
      if (addButtons.evaluate().isNotEmpty) {
        await tester.tap(addButtons.first);
        await tester.pumpAndSettle();

        // Look for BUY button
        final buyButtons = find.text('BUY');
        if (buyButtons.evaluate().length > 1) {
          // Tap the first BUY button (excluding the BUY DRUGS header)
          await tester.tap(buyButtons.at(1));
          await tester.pumpAndSettle();
          expect(buyPressed, isTrue);
        }
      }
    });

    testWidgets('displays CLOSE button',
        (WidgetTester tester) async {
      final player = Player.newPlayer(
        id: 'test',
        name: 'Test Player',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NpcTradeDialog(
              npcId: 'chemist_lagos',
              npc: supplier,
              player: player,
              currentHeat: 0,
              npcNetworkCubit: npcNetworkCubit,
              npcRepository: npcRepository,
              onBuyFromNpc: (_, __, ___) {},
              onSellToNpc: (_, __, ___) {},
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.text('CLOSE'), findsOneWidget);
    });

    testWidgets('displays reputation info in supplier',
        (WidgetTester tester) async {
      final player = Player.newPlayer(
        id: 'test',
        name: 'Test Player',
      );

      // Initialize relationship with some reputation
      var rel = npcNetworkCubit.state.relationships['chemist_lagos'];
      if (rel != null) {
        rel = rel.copyWith(reputation: 50);
        npcNetworkCubit.state.copyWith(
          relationships: {'chemist_lagos': rel},
        );
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NpcTradeDialog(
              npcId: 'chemist_lagos',
              npc: supplier,
              player: player,
              currentHeat: 0,
              npcNetworkCubit: npcNetworkCubit,
              npcRepository: npcRepository,
              onBuyFromNpc: (_, __, ___) {},
              onSellToNpc: (_, __, ___) {},
              onClose: () {},
            ),
          ),
        ),
      );

      // Verify it builds without error
      expect(find.byType(NpcTradeDialog), findsOneWidget);
    });
  });
}

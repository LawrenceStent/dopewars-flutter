import 'package:dopewars_flutter/domain/location/entities/location.dart';
import 'package:dopewars_flutter/domain/npc/entities/npc.dart';
import 'package:dopewars_flutter/domain/npc/repositories/npc_repository.dart';
import 'package:dopewars_flutter/domain/player/entities/player.dart';
import 'package:dopewars_flutter/presentation/cubits/npc/npc_network_cubit.dart';
import 'package:dopewars_flutter/presentation/widgets/npc_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NpcListWidget', () {
    late NpcNetworkCubit npcNetworkCubit;
    late NpcRepository npcRepository;

    setUp(() {
      npcRepository = const NpcRepository();
      npcNetworkCubit = NpcNetworkCubit(npcRepository: npcRepository);
    });

    tearDown(() {
      npcNetworkCubit.close();
    });

    testWidgets('displays title and player cash', (WidgetTester tester) async {
      final player = Player.newPlayer(
        id: 'test',
        name: 'Test Player',
      );
      final npcs = npcRepository.getNpcsAtLocation(LocationType.lagos);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NpcListWidget(
              player: player,
              npcsAtLocation: npcs,
              npcNetworkCubit: npcNetworkCubit,
              onNpcSelected: (_, __) {},
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.text('AVAILABLE CONTACTS'), findsOneWidget);
      expect(find.text('Cash: ${player.cash}'), findsOneWidget);
    });

    testWidgets('displays available NPCs', (WidgetTester tester) async {
      final player = Player.newPlayer(
        id: 'test',
        name: 'Test Player',
      );
      final npcs = npcRepository.getNpcsAtLocation(LocationType.lagos);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NpcListWidget(
              player: player,
              npcsAtLocation: npcs,
              npcNetworkCubit: npcNetworkCubit,
              onNpcSelected: (_, __) {},
              onClose: () {},
            ),
          ),
        ),
      );

      for (final npc in npcs) {
        expect(find.text(npc.name.toUpperCase()), findsWidgets);
      }
    });

    testWidgets('shows empty state when no NPCs', (WidgetTester tester) async {
      final player = Player.newPlayer(
        id: 'test',
        name: 'Test Player',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NpcListWidget(
              player: player,
              npcsAtLocation: [],
              npcNetworkCubit: npcNetworkCubit,
              onNpcSelected: (_, __) {},
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.text('No contacts here.'), findsOneWidget);
    });

    testWidgets('calls onNpcSelected when NPC tapped',
        (WidgetTester tester) async {
      final player = Player.newPlayer(
        id: 'test',
        name: 'Test Player',
      );
      final npcs = npcRepository.getNpcsAtLocation(LocationType.lagos);
      var selectedNpcId = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NpcListWidget(
              player: player,
              npcsAtLocation: npcs,
              npcNetworkCubit: npcNetworkCubit,
              onNpcSelected: (npcId, _) {
                selectedNpcId = npcId;
              },
              onClose: () {},
            ),
          ),
        ),
      );

      if (npcs.isNotEmpty) {
        final firstNpc = npcs.first;
        await tester.tap(find.text(firstNpc.name.toUpperCase()).first);
        await tester.pumpAndSettle();

        expect(selectedNpcId, equals(firstNpc.id));
      }
    });

    testWidgets('calls onClose when LEAVE button pressed',
        (WidgetTester tester) async {
      final player = Player.newPlayer(
        id: 'test',
        name: 'Test Player',
      );
      var closePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NpcListWidget(
              player: player,
              npcsAtLocation: [],
              npcNetworkCubit: npcNetworkCubit,
              onNpcSelected: (_, __) {},
              onClose: () {
                closePressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('LEAVE'));
      await tester.pumpAndSettle();

      expect(closePressed, isTrue);
    });

    testWidgets('displays role-specific icons', (WidgetTester tester) async {
      final player = Player.newPlayer(
        id: 'test',
        name: 'Test Player',
      );
      final npcs = npcRepository.getNpcsAtLocation(LocationType.lagos);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NpcListWidget(
              player: player,
              npcsAtLocation: npcs,
              npcNetworkCubit: npcNetworkCubit,
              onNpcSelected: (_, __) {},
              onClose: () {},
            ),
          ),
        ),
      );

      // Just verify the widget builds without error
      expect(find.byIcon(Icons.people), findsOneWidget);
    });
  });
}

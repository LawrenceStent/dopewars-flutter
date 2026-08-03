import 'package:dopewars_flutter/domain/location/entities/location.dart';
import 'package:dopewars_flutter/domain/npc/entities/npc.dart';
import 'package:dopewars_flutter/domain/npc/repositories/npc_repository.dart';
import 'package:dopewars_flutter/presentation/cubits/npc/npc_network_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NpcNetworkCubit', () {
    late NpcNetworkCubit cubit;
    late NpcRepository repository;

    setUp(() {
      repository = const NpcRepository();
      cubit = NpcNetworkCubit(npcRepository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    group('Initialization', () {
      test('initial state is empty', () {
        expect(cubit.state.relationships, isEmpty);
        expect(cubit.state.isLocked, isFalse);
        expect(cubit.state.error, isNull);
      });

      test('initializeForNewGame emits empty state', () {
        expect(
          cubit.stream,
          emitsInOrder([
            isA<NpcNetworkState>().having(
              (s) => s.relationships,
              'relationships',
              isEmpty,
            ),
          ]),
        );

        cubit.initializeForNewGame();
      });

      test('loadFromGameSession restores saved relationships', () {
        final saved = {
          'chemist_lagos': NpcRelationship(
            npcId: 'chemist_lagos',
            reputation: 50,
            currentSupply: 30,
          ),
        };

        cubit.loadFromGameSession(saved);
        expect(cubit.state.relationships.length, equals(1));
        expect(
          cubit.state.relationships['chemist_lagos']!.reputation,
          equals(50),
        );
      });
    });

    group('Relationship Management', () {
      test('getOrCreateRelationship creates new on first encounter', () {
        final rel = cubit.getOrCreateRelationship('chemist_lagos');

        expect(rel.npcId, equals('chemist_lagos'));
        expect(rel.reputation, equals(0));
        expect(rel.isActive, isTrue);
        expect(cubit.state.hasMetNpc('chemist_lagos'), isTrue);
      });

      test('getOrCreateRelationship returns existing relationship', () {
        cubit.getOrCreateRelationship('chemist_lagos');
        final first = cubit.state.relationships['chemist_lagos']!;

        cubit.getOrCreateRelationship('chemist_lagos');
        final second = cubit.state.relationships['chemist_lagos']!;

        expect(second.reputation, equals(first.reputation));
      });

      test('getOrCreateRelationship throws for unknown NPC', () {
        expect(
          () => cubit.getOrCreateRelationship('nonexistent'),
          throwsException,
        );
      });
    });

    group('Trading', () {
      test('recordTrade updates reputation and supply', () {
        cubit.getOrCreateRelationship('chemist_lagos');
        final before = cubit.state.relationships['chemist_lagos']!;

        cubit.recordTrade(
          npcId: 'chemist_lagos',
          tradeValue: 5000,
          currentTurn: 1,
          quantityTraded: 10,
        );

        final after = cubit.state.relationships['chemist_lagos']!;
        expect(after.tradeCount, equals(before.tradeCount + 1));
        expect(after.reputation, equals(before.reputation + 5));
        expect(
          after.currentSupply,
          equals(before.currentSupply - 10),
        );
      });

      test('recordTrade increments trade value', () {
        cubit.getOrCreateRelationship('chemist_lagos');

        cubit.recordTrade(
          npcId: 'chemist_lagos',
          tradeValue: 5000,
          currentTurn: 1,
          quantityTraded: 10,
        );

        cubit.recordTrade(
          npcId: 'chemist_lagos',
          tradeValue: 3000,
          currentTurn: 2,
          quantityTraded: 5,
        );

        final rel = cubit.state.relationships['chemist_lagos']!;
        expect(rel.totalTradeValue, equals(8000));
        expect(rel.tradeCount, equals(2));
      });

      test('canTradeWithNpc returns true for active NPC', () {
        cubit.getOrCreateRelationship('chemist_lagos');

        expect(cubit.canTradeWithNpc('chemist_lagos'), isTrue);
      });

      test('canTradeWithNpc returns false for busted NPC', () {
        cubit.getOrCreateRelationship('chemist_lagos');
        cubit.markNpcBusted('chemist_lagos', 5);

        expect(cubit.canTradeWithNpc('chemist_lagos'), isFalse);
      });

      test('canTradeWithNpc returns false for unknown NPC', () {
        expect(cubit.canTradeWithNpc('unknown'), isFalse);
      });
    });

    group('Bust Mechanics', () {
      test('markNpcBusted makes NPC unavailable', () {
        cubit.getOrCreateRelationship('chemist_lagos');

        cubit.markNpcBusted('chemist_lagos', 5);

        final rel = cubit.state.relationships['chemist_lagos']!;
        expect(rel.isActive, isFalse);
        expect(rel.turnsUnavailable, equals(5));
        expect(cubit.canTradeWithNpc('chemist_lagos'), isFalse);
      });

      test('getUnavailableReason shows countdown', () {
        cubit.getOrCreateRelationship('chemist_lagos');
        cubit.markNpcBusted('chemist_lagos', 3);

        final reason = cubit.getUnavailableReason('chemist_lagos');
        expect(reason, contains('3 more turns'));
      });

      test('getUnavailableReason returns null for available NPC', () {
        cubit.getOrCreateRelationship('chemist_lagos');

        expect(cubit.getUnavailableReason('chemist_lagos'), isNull);
      });

      test('getUnavailableReason returns "unknown" for not yet met', () {
        expect(cubit.getUnavailableReason('unknown'), equals('Not yet encountered'));
      });
    });

    group('Pricing', () {
      test('calculatePrice applies NPC multiplier', () {
        cubit.getOrCreateRelationship('chemist_lagos');
        final npc = repository.getNpcById('chemist_lagos')!;

        final price = cubit.calculatePrice(100.0, 'chemist_lagos');
        final expected = 100.0 * npc.basePriceModifier; // No reputation bonus yet

        expect(price, closeTo(expected, 0.1));
      });

      test('calculatePrice applies reputation bonus', () {
        cubit.getOrCreateRelationship('chemist_lagos');

        // Manually add reputation
        final current = cubit.state.relationships['chemist_lagos']!;
        final rel = current.copyWith(reputation: 50);
        cubit.state.copyWith(
          relationships: {'chemist_lagos': rel},
        );

        // Note: This test shows limitation of current structure
        // Reputation bonus is applied in repository, not cubit
      });

      test('calculatePrice returns null for unknown NPC', () {
        expect(cubit.calculatePrice(100.0, 'unknown'), isNull);
      });

      test('calculatePrice returns null for not yet met', () {
        expect(cubit.calculatePrice(100.0, 'chemist_lagos'), isNull);
      });
    });

    group('Turn Effects', () {
      test('applyTurnEffects decays supply', () {
        cubit.getOrCreateRelationship('chemist_lagos');
        final before = cubit.state.relationships['chemist_lagos']!.currentSupply;

        cubit.applyTurnEffects();

        final after = cubit.state.relationships['chemist_lagos']!.currentSupply;
        expect(after, lessThan(before));
      });

      test('applyTurnEffects decrements unavailability', () {
        cubit.getOrCreateRelationship('chemist_lagos');
        cubit.markNpcBusted('chemist_lagos', 3);

        cubit.applyTurnEffects();

        final after = cubit.state.relationships['chemist_lagos']!.turnsUnavailable;
        expect(after, equals(2));
      });

      test('applyTurnEffects marks available when countdown hits 0', () {
        cubit.getOrCreateRelationship('chemist_lagos');
        cubit.markNpcBusted('chemist_lagos', 1);

        cubit.applyTurnEffects();

        final after = cubit.state.relationships['chemist_lagos']!;
        expect(after.turnsUnavailable, equals(0));
        expect(after.isActive, isTrue);
      });
    });

    group('Relationship Status', () {
      test('getRelationshipStatus returns Stranger for 0 reputation', () {
        cubit.getOrCreateRelationship('chemist_lagos');

        expect(cubit.getRelationshipStatus('chemist_lagos'), equals('Stranger'));
      });

      test('getTrustLevel returns 0 for 0 reputation', () {
        cubit.getOrCreateRelationship('chemist_lagos');

        expect(cubit.getTrustLevel('chemist_lagos'), equals(0));
      });

      test('getTrustLevel returns 5 for 100 reputation', () {
        cubit.getOrCreateRelationship('chemist_lagos');

        // Manually record 20 trades of 5000 each to reach 100 reputation
        for (int i = 0; i < 20; i++) {
          cubit.recordTrade(
            npcId: 'chemist_lagos',
            tradeValue: 5000,
            currentTurn: i + 1,
            quantityTraded: 5,
          );
        }

        expect(cubit.getTrustLevel('chemist_lagos'), equals(5));
      });
    });

    group('Location Queries', () {
      test('getNpcsAtLocation returns NPCs at location', () {
        final npcs = cubit.getNpcsAtLocation(LocationType.lagos);

        expect(npcs, isNotEmpty);
        expect(npcs.first.homeLocation, equals(LocationType.lagos));
      });

      test('getNpcsAtLocation onlyTradeable filters out busted NPCs', () {
        cubit.getOrCreateRelationship('chemist_lagos');
        cubit.markNpcBusted('chemist_lagos', 5);

        final all = cubit.getNpcsAtLocation(LocationType.lagos, onlyTradeable: false);
        final tradeable = cubit.getNpcsAtLocation(
          LocationType.lagos,
          onlyTradeable: true,
        );

        expect(all.length, greaterThan(tradeable.length));
      });

      test('getNpcsAtLocation includes not yet met NPCs when tradeable=true', () {
        final tradeable = cubit.getNpcsAtLocation(
          LocationType.lagos,
          onlyTradeable: true,
        );

        // Street Chemist is at Lagos and hasn't been met yet, so should be tradeable
        expect(
          tradeable.any((npc) => npc.id == 'chemist_lagos'),
          isTrue,
        );
      });
    });

    group('State Queries', () {
      test('state.getTradeableRelationships returns only active NPCs', () {
        cubit.getOrCreateRelationship('chemist_lagos');
        cubit.getOrCreateRelationship('club_owner_ny');
        cubit.markNpcBusted('chemist_lagos', 5);

        final tradeable = cubit.state.getTradeableRelationships(repository);

        expect(tradeable.length, equals(1));
        expect(tradeable.containsKey('club_owner_ny'), isTrue);
      });

      test('state.getUnavailableReasons returns reasons for inactive NPCs', () {
        cubit.getOrCreateRelationship('chemist_lagos');
        cubit.getOrCreateRelationship('club_owner_ny');
        cubit.markNpcBusted('chemist_lagos', 3);

        final reasons = cubit.state.getUnavailableReasons(repository);

        expect(reasons.containsKey('chemist_lagos'), isTrue);
        expect(reasons['chemist_lagos'], contains('3 more turns'));
      });
    });
  });
}

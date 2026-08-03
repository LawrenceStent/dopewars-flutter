import 'package:dopewars_flutter/domain/location/entities/location.dart';
import 'package:dopewars_flutter/domain/npc/entities/npc.dart';
import 'package:dopewars_flutter/domain/npc/repositories/npc_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NPC Repository', () {
    late NpcRepository repository;

    setUp(() {
      repository = const NpcRepository();
    });

    group('NPC Lookup', () {
      test('getAllNpcs returns all NPCs', () {
        final npcs = repository.getAllNpcs();
        expect(npcs.length, equals(6));
      });

      test('getNpcById returns correct NPC', () {
        final npc = repository.getNpcById('chemist_lagos');
        expect(npc, isNotNull);
        expect(npc!.name, equals('Street Chemist'));
      });

      test('getNpcById returns null for unknown NPC', () {
        final npc = repository.getNpcById('nonexistent');
        expect(npc, isNull);
      });

      test('getNpcsAtLocation returns NPCs at location', () {
        final npcs = repository.getNpcsAtLocation(LocationType.lagos);
        expect(npcs.length, greaterThan(0));
        expect(npcs.first.homeLocation, equals(LocationType.lagos));
      });

      test('getNpcsAtLocation returns empty for location without NPCs', () {
        final npcs = repository.getNpcsAtLocation(LocationType.barcelona);
        expect(npcs, isEmpty);
      });
    });

    group('Relationship Management', () {
      test('initializeRelationship creates new relationship', () {
        final npc = repository.getNpcById('chemist_lagos')!;
        final rel = repository.initializeRelationship('chemist_lagos', npc);

        expect(rel.npcId, equals('chemist_lagos'));
        expect(rel.reputation, equals(0));
        expect(rel.isActive, isTrue);
        expect(rel.currentSupply, equals(npc.initialSupplyPerTurn));
      });

      test('getOrCreateRelationship returns existing if present', () {
        final existing = {
          'chemist_lagos': NpcRelationship(
            npcId: 'chemist_lagos',
            reputation: 50,
          ),
        };

        final rel = repository.getOrCreateRelationship('chemist_lagos', existing);
        expect(rel.reputation, equals(50));
      });

      test('getOrCreateRelationship creates new if missing', () {
        final existing = <String, NpcRelationship>{};

        final rel = repository.getOrCreateRelationship('chemist_lagos', existing);
        expect(rel.npcId, equals('chemist_lagos'));
        expect(rel.reputation, equals(0));
      });

      test('getOrCreateRelationship throws for unknown NPC', () {
        expect(
          () => repository.getOrCreateRelationship('unknown', {}),
          throwsException,
        );
      });
    });

    group('Trade Mechanics', () {
      test('canTrade returns true for active NPC', () {
        const rel = NpcRelationship(
          npcId: 'test',
          isActive: true,
          turnsUnavailable: 0,
        );

        expect(repository.canTrade(rel), isTrue);
      });

      test('canTrade returns false for busted NPC', () {
        final rel = NpcRelationship(
          npcId: 'test',
          isActive: false,
          turnsUnavailable: 5,
        );

        expect(repository.canTrade(rel), isFalse);
      });

      test('getUnavailableReason provides reason when applicable', () {
        final rel = NpcRelationship(
          npcId: 'test',
          isActive: false,
          turnsUnavailable: 3,
        );

        expect(repository.getUnavailableReason(rel), isNotNull);
        expect(
          repository.getUnavailableReason(rel),
          contains('3 more turns'),
        );
      });

      test('getUnavailableReason returns null when available', () {
        const rel = NpcRelationship(
          npcId: 'test',
          isActive: true,
          turnsUnavailable: 0,
        );

        expect(repository.getUnavailableReason(rel), isNull);
      });
    });

    group('Pricing', () {
      test('calculateNpcPrice applies NPC multiplier', () {
        final npc = Npc(
          id: 'test',
          name: 'Test',
          role: NpcRole.supplier,
          homeLocation: LocationType.lagos,
          maxQuantityPerTurn: 50,
          basePriceModifier: 0.8, // 20% discount
        );

        const rel = NpcRelationship(
          npcId: 'test',
          reputation: 0,
        );

        final price = repository.calculateNpcPrice(100.0, npc, rel);
        expect(price, equals(80.0)); // 100 * 0.8
      });

      test('calculateNpcPrice applies reputation bonus for suppliers', () {
        final npc = Npc(
          id: 'test',
          name: 'Test',
          role: NpcRole.supplier,
          homeLocation: LocationType.lagos,
          maxQuantityPerTurn: 50,
          basePriceModifier: 1.0,
        );

        final rel = NpcRelationship(
          npcId: 'test',
          reputation: 50, // 50% reputation
        );

        final price = repository.calculateNpcPrice(100.0, npc, rel);
        // 100 * 1.0 * (1 - 0.5 * 0.3) = 100 * 0.85 = 85
        expect(price, closeTo(85.0, 0.1));
      });

      test('calculateNpcPrice with max reputation gives max discount', () {
        final npc = Npc(
          id: 'test',
          name: 'Test',
          role: NpcRole.supplier,
          homeLocation: LocationType.lagos,
          maxQuantityPerTurn: 50,
          basePriceModifier: 1.0,
        );

        final rel = NpcRelationship(
          npcId: 'test',
          reputation: 100, // Max reputation
        );

        final price = repository.calculateNpcPrice(100.0, npc, rel);
        // 100 * 1.0 * (1 - 1.0 * 0.3) = 100 * 0.7 = 70
        expect(price, closeTo(70.0, 0.1));
      });
    });

    group('Turn Effects', () {
      test('applyTurnEffects decays supply', () {
        final rels = {
          'chemist_lagos': NpcRelationship(
            npcId: 'chemist_lagos',
            currentSupply: 100,
          ),
        };

        final updated = repository.applyTurnEffects(rels);
        expect(updated['chemist_lagos']!.currentSupply, equals(80)); // 20% decay
      });

      test('applyTurnEffects decrements unavailability', () {
        final rels = {
          'test': NpcRelationship(
            npcId: 'test',
            turnsUnavailable: 5,
          ),
        };

        final updated = repository.applyTurnEffects(rels);
        expect(updated['test']!.turnsUnavailable, equals(4));
      });

      test('applyTurnEffects marks NPC available when countdown ends', () {
        final rels = {
          'test': NpcRelationship(
            npcId: 'test',
            isActive: false,
            turnsUnavailable: 1,
          ),
        };

        final updated = repository.applyTurnEffects(rels);
        expect(updated['test']!.turnsUnavailable, equals(0));
        expect(updated['test']!.isActive, isTrue);
      });
    });

    group('Status Display', () {
      test('getRelationshipStatus returns correct status', () {
        expect(
          repository.getRelationshipStatus(
            NpcRelationship(npcId: 'test', reputation: 0),
          ),
          equals('Stranger'),
        );

        expect(
          repository.getRelationshipStatus(
            NpcRelationship(npcId: 'test', reputation: 30),
          ),
          equals('Regular'),
        );

        expect(
          repository.getRelationshipStatus(
            NpcRelationship(npcId: 'test', reputation: 60),
          ),
          equals('Friend'),
        );

        expect(
          repository.getRelationshipStatus(
            NpcRelationship(npcId: 'test', reputation: 90),
          ),
          equals('Trusted'),
        );
      });

      test('getTrustLevel returns correct star count', () {
        expect(
          repository.getTrustLevel(NpcRelationship(npcId: 'test', reputation: 0)),
          equals(0),
        );

        expect(
          repository.getTrustLevel(NpcRelationship(npcId: 'test', reputation: 50)),
          equals(2),
        );

        expect(
          repository.getTrustLevel(NpcRelationship(npcId: 'test', reputation: 100)),
          equals(5),
        );
      });
    });
  });
}

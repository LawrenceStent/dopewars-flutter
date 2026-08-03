import 'package:dopewars_flutter/domain/location/entities/location.dart';
import 'package:dopewars_flutter/domain/npc/entities/npc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NPC Entity Tests', () {
    group('Npc Model', () {
      test('creates NPC with all attributes', () {
        const npc = Npc(
          id: 'test_supplier',
          name: 'Test Supplier',
          role: NpcRole.supplier,
          homeLocation: LocationType.lagos,
          maxQuantityPerTurn: 50,
          basePriceModifier: 0.85,
          bustChance: 0.05,
          initialSupplyPerTurn: 50,
        );

        expect(npc.id, equals('test_supplier'));
        expect(npc.name, equals('Test Supplier'));
        expect(npc.role, equals(NpcRole.supplier));
        expect(npc.basePriceModifier, equals(0.85));
        expect(npc.initialSupplyPerTurn, equals(50));
      });

      test('equality works correctly', () {
        const npc1 = Npc(
          id: 'supplier1',
          name: 'Supplier',
          role: NpcRole.supplier,
          homeLocation: LocationType.lagos,
          maxQuantityPerTurn: 50,
          initialSupplyPerTurn: 50,
        );

        const npc2 = Npc(
          id: 'supplier1',
          name: 'Supplier',
          role: NpcRole.supplier,
          homeLocation: LocationType.lagos,
          maxQuantityPerTurn: 50,
          initialSupplyPerTurn: 50,
        );

        expect(npc1, equals(npc2));
      });
    });

    group('NpcRelationship Model', () {
      test('creates relationship with default values', () {
        const rel = NpcRelationship(npcId: 'test_npc');

        expect(rel.npcId, equals('test_npc'));
        expect(rel.reputation, equals(0));
        expect(rel.tradeCount, equals(0));
        expect(rel.isActive, isTrue);
        expect(rel.canTrade, isTrue);
      });

      test('copyWith updates specific fields', () {
        const rel = NpcRelationship(npcId: 'test', reputation: 10);
        final updated = rel.copyWith(reputation: 50);

        expect(updated.reputation, equals(50));
        expect(updated.npcId, equals('test'));
      });

      test('addReputation clamps to 0-100', () {
        const rel = NpcRelationship(npcId: 'test', reputation: 90);

        final increased = rel.addReputation(50); // 140 clamped to 100
        expect(increased.reputation, equals(100));

        final decreased = rel.addReputation(-100); // -10 clamped to 0
        expect(decreased.reputation, equals(0));
      });

      test('recordTrade increments counters', () {
        const rel = NpcRelationship(npcId: 'test');

        final traded = rel.recordTrade(5000, 1);
        expect(traded.tradeCount, equals(1));
        expect(traded.totalTradeValue, equals(5000));
        expect(traded.lastTradeTurn, equals(1));
      });

      test('useSupply reduces current supply', () {
        final rel = NpcRelationship(
          npcId: 'test',
          currentSupply: 50,
        );

        final used = rel.useSupply(15);
        expect(used.currentSupply, equals(35));
      });

      test('applySupplyDecay reduces supply by 20%', () {
        final rel = NpcRelationship(
          npcId: 'test',
          currentSupply: 100,
        );

        final decayed = rel.applySupplyDecay(100);
        expect(decayed.currentSupply, equals(80)); // 100 * 0.8
      });

      test('applySupplyDecay restocks when depleted', () {
        final rel = NpcRelationship(
          npcId: 'test',
          currentSupply: 0,
        );

        final restocked = rel.applySupplyDecay(100);
        expect(restocked.currentSupply, equals(100));
        expect(restocked.turnsSinceRestock, equals(0));
      });

      test('markBusted makes NPC unavailable', () {
        const rel = NpcRelationship(npcId: 'test', reputation: 80);

        final busted = rel.markBusted(10); // Unavailable for 10 turns
        expect(busted.isActive, isFalse);
        expect(busted.turnsUnavailable, equals(10));
        expect(busted.canTrade, isFalse);
        // Reputation hit: 80 - 20 = 60
        expect(busted.reputation, equals(60));
      });

      test('decrementUnavailability counts down', () {
        final rel = NpcRelationship(
          npcId: 'test',
          turnsUnavailable: 5,
          isActive: false,
        );

        final decremented = rel.decrementUnavailability();
        expect(decremented.turnsUnavailable, equals(4));

        final fullDecrement = decremented
            .copyWith(turnsUnavailable: 1)
            .decrementUnavailability();
        expect(fullDecrement.turnsUnavailable, equals(0));
        expect(fullDecrement.isActive, isTrue);
      });
    });

    group('DefaultNpcs', () {
      test('has 6 starter NPCs', () {
        expect(DefaultNpcs.count, equals(6));
      });

      test('all NPCs have unique IDs', () {
        final ids = DefaultNpcs.all.map((npc) => npc.id).toList();
        expect(ids.length, equals(ids.toSet().length));
      });

      test('byId retrieves NPC correctly', () {
        final npc = DefaultNpcs.byId('chemist_lagos');
        expect(npc, isNotNull);
        expect(npc!.name, equals('Street Chemist'));
        expect(npc.role, equals(NpcRole.supplier));
      });

      test('byId returns null for unknown NPC', () {
        final npc = DefaultNpcs.byId('nonexistent');
        expect(npc, isNull);
      });

      test('atLocation returns NPCs at specific location', () {
        final lagoNpcs = DefaultNpcs.atLocation(LocationType.lagos);
        expect(lagoNpcs, isNotEmpty);
        expect(lagoNpcs.first.name, equals('Street Chemist'));
      });

      test('atLocation returns empty for location with no NPCs', () {
        final nyNpcs = DefaultNpcs.atLocation(LocationType.barcelona);
        expect(nyNpcs, isEmpty);
      });

      test('all roles are represented', () {
        final roles = DefaultNpcs.all.map((npc) => npc.role).toSet();
        expect(roles.contains(NpcRole.supplier), isTrue);
        expect(roles.contains(NpcRole.buyer), isTrue);
        expect(roles.contains(NpcRole.fixer), isTrue);
        expect(roles.contains(NpcRole.doctor), isTrue);
        expect(roles.contains(NpcRole.lawyer), isTrue);
      });
    });
  });
}

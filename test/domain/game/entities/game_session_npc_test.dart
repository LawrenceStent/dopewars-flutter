import 'package:dopewars_flutter/domain/game/entities/game_session.dart';
import 'package:dopewars_flutter/domain/npc/entities/npc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameSession with NPC Persistence', () {
    test('creates GameSession with empty NPC relationships', () {
      final session = GameSession(
        id: 'test_session',
        playerName: 'Test Player',
        turn: 1,
        netWorth: 1000000,
        locationIndex: 0,
        savedAt: DateTime.now(),
      );

      expect(session.npcRelationships, isEmpty);
    });

    test('creates GameSession with NPC relationships', () {
      final npcRelationships = {
        'chemist_lagos': NpcRelationship(
          npcId: 'chemist_lagos',
          reputation: 50,
          tradeCount: 3,
        ),
        'club_owner_ny': NpcRelationship(
          npcId: 'club_owner_ny',
          reputation: 25,
        ),
      };

      final session = GameSession(
        id: 'test_session',
        playerName: 'Test Player',
        turn: 5,
        netWorth: 5000000,
        locationIndex: 1,
        savedAt: DateTime.now(),
        npcRelationships: npcRelationships,
      );

      expect(session.npcRelationships.length, equals(2));
      expect(session.npcRelationships['chemist_lagos']!.reputation, equals(50));
      expect(session.npcRelationships['club_owner_ny']!.reputation, equals(25));
    });

    test('serializes to JSON with NPC relationships', () {
      final now = DateTime.now();
      final npcRelationships = {
        'chemist_lagos': NpcRelationship(
          npcId: 'chemist_lagos',
          reputation: 50,
          tradeCount: 3,
          totalTradeValue: 15000,
          lastTradeTurn: 3,
          isActive: true,
          currentSupply: 40,
          turnsSinceRestock: 1,
          turnsUnavailable: 0,
        ),
      };

      final session = GameSession(
        id: 'test_session',
        playerName: 'Test Player',
        turn: 5,
        netWorth: 5000000,
        locationIndex: 1,
        savedAt: now,
        npcRelationships: npcRelationships,
      );

      final json = session.toJson();

      expect(json['id'], equals('test_session'));
      expect(json['playerName'], equals('Test Player'));
      expect(json['turn'], equals(5));
      expect(json['npcRelationships'], isNotEmpty);
      expect(json['npcRelationships']['chemist_lagos']['reputation'], equals(50));
      expect(json['npcRelationships']['chemist_lagos']['tradeCount'], equals(3));
      expect(json['npcRelationships']['chemist_lagos']['currentSupply'], equals(40));
    });

    test('deserializes from JSON with NPC relationships', () {
      final now = DateTime.now();
      final json = {
        'id': 'test_session',
        'playerName': 'Test Player',
        'turn': 5,
        'netWorth': 5000000,
        'locationIndex': 1,
        'savedAt': now.toIso8601String(),
        'npcRelationships': {
          'chemist_lagos': {
            'npcId': 'chemist_lagos',
            'reputation': 50,
            'tradeCount': 3,
            'totalTradeValue': 15000,
            'lastTradeTurn': 3,
            'isActive': true,
            'currentSupply': 40,
            'turnsSinceRestock': 1,
            'turnsUnavailable': 0,
          },
        },
      };

      final session = GameSession.fromJson(json);

      expect(session.id, equals('test_session'));
      expect(session.playerName, equals('Test Player'));
      expect(session.turn, equals(5));
      expect(session.npcRelationships.length, equals(1));
      expect(session.npcRelationships['chemist_lagos']!.reputation, equals(50));
      expect(session.npcRelationships['chemist_lagos']!.tradeCount, equals(3));
      expect(session.npcRelationships['chemist_lagos']!.currentSupply, equals(40));
    });

    test('round-trip serialization preserves all NPC data', () {
      final now = DateTime.now();
      final original = GameSession(
        id: 'test_session',
        playerName: 'Test Player',
        turn: 10,
        netWorth: 10000000,
        locationIndex: 3,
        savedAt: now,
        npcRelationships: {
          'chemist_lagos': NpcRelationship(
            npcId: 'chemist_lagos',
            reputation: 75,
            tradeCount: 5,
            totalTradeValue: 50000,
            lastTradeTurn: 9,
            isActive: true,
            currentSupply: 30,
            turnsSinceRestock: 2,
            turnsUnavailable: 0,
          ),
          'club_owner_ny': NpcRelationship(
            npcId: 'club_owner_ny',
            reputation: 10,
            isActive: false,
            turnsUnavailable: 3,
          ),
        },
      );

      final json = original.toJson();
      final restored = GameSession.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.playerName, equals(original.playerName));
      expect(restored.turn, equals(original.turn));
      expect(restored.npcRelationships.length, equals(2));
      expect(
        restored.npcRelationships['chemist_lagos']!.reputation,
        equals(original.npcRelationships['chemist_lagos']!.reputation),
      );
      expect(
        restored.npcRelationships['club_owner_ny']!.turnsUnavailable,
        equals(3),
      );
    });

    test('handles missing NPC relationships gracefully', () {
      final json = {
        'id': 'test_session',
        'playerName': 'Test Player',
        'turn': 5,
        'netWorth': 5000000,
        'locationIndex': 1,
        'savedAt': DateTime.now().toIso8601String(),
        // No npcRelationships key
      };

      final session = GameSession.fromJson(json);
      expect(session.npcRelationships, isEmpty);
    });

    test('equality works with NPC relationships', () {
      final now = DateTime.now();
      final rel = NpcRelationship(npcId: 'chemist_lagos', reputation: 50);

      final session1 = GameSession(
        id: 'test',
        playerName: 'Test',
        turn: 1,
        netWorth: 1000,
        locationIndex: 0,
        savedAt: now,
        npcRelationships: {'chemist_lagos': rel},
      );

      final session2 = GameSession(
        id: 'test',
        playerName: 'Test',
        turn: 1,
        netWorth: 1000,
        locationIndex: 0,
        savedAt: now,
        npcRelationships: {'chemist_lagos': rel},
      );

      expect(session1, equals(session2));
    });
  });
}

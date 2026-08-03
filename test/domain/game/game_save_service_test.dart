import 'package:dopewars_flutter/domain/game/entities/game_session.dart';
import 'package:dopewars_flutter/domain/game/services/game_save_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GameSaveService', () {
    late SharedPreferences prefs;
    late GameSaveService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = GameSaveService(prefs: prefs);
    });

    test('getSaves returns empty list when no saves exist', () async {
      final saves = await service.getSaves();
      expect(saves, isEmpty);
    });

    test('saveGame saves a game session', () async {
      final session = GameSession(
        id: 'test-save-1',
        playerName: 'TestPlayer',
        turn: 15,
        netWorth: 50000,
        locationIndex: 3,
        savedAt: DateTime.now(),
      );

      final success = await service.saveGame(session);
      expect(success, isTrue);

      final saves = await service.getSaves();
      expect(saves.length, 1);
      expect(saves[0].playerName, 'TestPlayer');
    });

    test('saveGame overwrites existing save with same ID', () async {
      final session1 = GameSession(
        id: 'test-save-1',
        playerName: 'TestPlayer',
        turn: 15,
        netWorth: 50000,
        locationIndex: 3,
        savedAt: DateTime.now(),
      );

      await service.saveGame(session1);

      final session2 = GameSession(
        id: 'test-save-1',
        playerName: 'TestPlayer',
        turn: 20,
        netWorth: 60000,
        locationIndex: 5,
        savedAt: DateTime.now(),
      );

      await service.saveGame(session2);

      final saves = await service.getSaves();
      expect(saves.length, 1);
      expect(saves[0].turn, 20);
      expect(saves[0].netWorth, 60000);
    });

    test('getSaves returns saves sorted by most recent first', () async {
      final now = DateTime.now();

      final session1 = GameSession(
        id: 'save-1',
        playerName: 'Player1',
        turn: 10,
        netWorth: 10000,
        locationIndex: 0,
        savedAt: now.subtract(const Duration(minutes: 10)),
      );

      final session2 = GameSession(
        id: 'save-2',
        playerName: 'Player2',
        turn: 20,
        netWorth: 20000,
        locationIndex: 1,
        savedAt: now,
      );

      await service.saveGame(session1);
      await service.saveGame(session2);

      final saves = await service.getSaves();
      expect(saves[0].playerName, 'Player2'); // Most recent
      expect(saves[1].playerName, 'Player1'); // Older
    });

    test('loadGame returns correct game session', () async {
      final session = GameSession(
        id: 'test-save-1',
        playerName: 'TestPlayer',
        turn: 15,
        netWorth: 50000,
        locationIndex: 3,
        savedAt: DateTime.now(),
      );

      await service.saveGame(session);

      final loaded = await service.loadGame('test-save-1');
      expect(loaded, isNotNull);
      expect(loaded!.playerName, 'TestPlayer');
      expect(loaded.turn, 15);
    });

    test('loadGame returns null for non-existent save', () async {
      final loaded = await service.loadGame('non-existent');
      expect(loaded, isNull);
    });

    test('getLastSave returns most recent save', () async {
      final session1 = GameSession(
        id: 'save-1',
        playerName: 'Player1',
        turn: 10,
        netWorth: 10000,
        locationIndex: 0,
        savedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      final session2 = GameSession(
        id: 'save-2',
        playerName: 'Player2',
        turn: 20,
        netWorth: 20000,
        locationIndex: 1,
        savedAt: DateTime.now(),
      );

      await service.saveGame(session1);
      await service.saveGame(session2);

      final lastSave = await service.getLastSave();
      expect(lastSave, isNotNull);
      expect(lastSave!.playerName, 'Player2');
    });

    test('deleteSave removes a game save', () async {
      final session = GameSession(
        id: 'test-save-1',
        playerName: 'TestPlayer',
        turn: 15,
        netWorth: 50000,
        locationIndex: 3,
        savedAt: DateTime.now(),
      );

      await service.saveGame(session);
      expect((await service.getSaves()).length, 1);

      final success = await service.deleteSave('test-save-1');
      expect(success, isTrue);
      expect((await service.getSaves()).length, 0);
    });

    test('deleteSave clears storage when last save is deleted', () async {
      final session = GameSession(
        id: 'test-save-1',
        playerName: 'TestPlayer',
        turn: 15,
        netWorth: 50000,
        locationIndex: 3,
        savedAt: DateTime.now(),
      );

      await service.saveGame(session);
      await service.deleteSave('test-save-1');

      final saves = await service.getSaves();
      expect(saves, isEmpty);
    });

    test('clearSaves removes all saves', () async {
      for (int i = 0; i < 3; i++) {
        await service.saveGame(GameSession(
          id: 'save-$i',
          playerName: 'Player$i',
          turn: 10 + i,
          netWorth: 10000 + (i * 1000),
          locationIndex: i,
          savedAt: DateTime.now(),
        ));
      }

      expect((await service.getSaves()).length, 3);

      await service.clearSaves();

      expect((await service.getSaves()).length, 0);
      expect(await service.getLastSave(), isNull);
    });
  });
}

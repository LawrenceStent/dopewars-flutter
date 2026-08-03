import 'package:dopewars_flutter/domain/game/entities/high_score.dart';
import 'package:dopewars_flutter/domain/game/services/high_score_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HighScoreService', () {
    late SharedPreferences prefs;
    late HighScoreService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = HighScoreService(prefs: prefs);
    });

    test('getHighScores returns empty list when no scores saved', () async {
      final scores = await service.getHighScores();
      expect(scores, isEmpty);
    });

    test('addHighScore saves a score when list is not full', () async {
      final score = HighScore(
        playerName: 'TestPlayer',
        netWorth: 10000,
        turn: 30,
        date: DateTime.now(),
      );

      final added = await service.addHighScore(score);
      expect(added, isTrue);

      final scores = await service.getHighScores();
      expect(scores.length, 1);
      expect(scores[0].playerName, 'TestPlayer');
    });

    test('addHighScore returns false when score is below minimum', () async {
      // Fill list to max capacity
      for (int i = 0; i < HighScoreService.maxHighScores; i++) {
        await service.addHighScore(HighScore(
          playerName: 'Player$i',
          netWorth: 1000 + (i * 100),
          turn: 30,
          date: DateTime.now(),
        ));
      }

      // Try to add a score below the minimum
      final lowScore = HighScore(
        playerName: 'LowScore',
        netWorth: 500,
        turn: 30,
        date: DateTime.now(),
      );

      final added = await service.addHighScore(lowScore);
      expect(added, isFalse);

      final scores = await service.getHighScores();
      expect(scores.length, HighScoreService.maxHighScores);
    });

    test('addHighScore maintains sorted order by net worth', () async {
      await service.addHighScore(HighScore(
        playerName: 'Player1',
        netWorth: 5000,
        turn: 30,
        date: DateTime.now(),
      ));

      await service.addHighScore(HighScore(
        playerName: 'Player2',
        netWorth: 10000,
        turn: 30,
        date: DateTime.now(),
      ));

      await service.addHighScore(HighScore(
        playerName: 'Player3',
        netWorth: 7500,
        turn: 30,
        date: DateTime.now(),
      ));

      final scores = await service.getHighScores();
      expect(scores[0].netWorth, 10000); // Highest first
      expect(scores[1].netWorth, 7500);
      expect(scores[2].netWorth, 5000); // Lowest last
    });

    test('addHighScore trims list to maxHighScores', () async {
      // Add more than max scores
      for (int i = 0; i < HighScoreService.maxHighScores + 5; i++) {
        await service.addHighScore(HighScore(
          playerName: 'Player$i',
          netWorth: 10000 - i,
          turn: 30,
          date: DateTime.now(),
        ));
      }

      final scores = await service.getHighScores();
      expect(scores.length, HighScoreService.maxHighScores);
    });

    test('isHighScore returns true when list is not full', () async {
      final isHigh = await service.isHighScore(1000);
      expect(isHigh, isTrue);
    });

    test('isHighScore returns true for score above minimum', () async {
      // Fill list with some scores
      for (int i = 0; i < 5; i++) {
        await service.addHighScore(HighScore(
          playerName: 'Player$i',
          netWorth: 1000 + (i * 100),
          turn: 30,
          date: DateTime.now(),
        ));
      }

      // Score higher than the lowest should qualify
      final isHigh = await service.isHighScore(2000);
      expect(isHigh, isTrue);
    });

    test('isHighScore returns false for score below minimum', () async {
      // Fill list
      for (int i = 0; i < HighScoreService.maxHighScores; i++) {
        await service.addHighScore(HighScore(
          playerName: 'Player$i',
          netWorth: 2000 + (i * 100),
          turn: 30,
          date: DateTime.now(),
        ));
      }

      final isHigh = await service.isHighScore(500);
      expect(isHigh, isFalse);
    });

    test('getRank returns correct rank for high score', () async {
      await service.addHighScore(HighScore(
        playerName: 'Player1',
        netWorth: 5000,
        turn: 30,
        date: DateTime.now(),
      ));

      await service.addHighScore(HighScore(
        playerName: 'Player2',
        netWorth: 10000,
        turn: 30,
        date: DateTime.now(),
      ));

      final rank = await service.getRank(8000);
      expect(rank, 2); // Between 10000 and 5000, so rank 2
    });

    test('getRank returns 0 for score not in list', () async {
      await service.addHighScore(HighScore(
        playerName: 'Player1',
        netWorth: 5000,
        turn: 30,
        date: DateTime.now(),
      ));

      final rank = await service.getRank(1000);
      expect(rank, 0);
    });

    test('clearHighScores removes all scores', () async {
      await service.addHighScore(HighScore(
        playerName: 'Player1',
        netWorth: 5000,
        turn: 30,
        date: DateTime.now(),
      ));

      await service.clearHighScores();

      final scores = await service.getHighScores();
      expect(scores, isEmpty);
    });
  });
}

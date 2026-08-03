import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../entities/high_score.dart';

/// Service for managing high scores with persistence.
class HighScoreService {
  static const String _highScoresKey = 'dopewars_high_scores';
  static const int maxHighScores = 18; // From GameConstants.numHiScore

  final SharedPreferences _prefs;

  const HighScoreService({required SharedPreferences prefs}) : _prefs = prefs;

  /// Get all high scores sorted by net worth (highest first).
  Future<List<HighScore>> getHighScores() async {
    final scoresJson = _prefs.getString(_highScoresKey);
    if (scoresJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(scoresJson) as List<dynamic>;
      final scores = decoded
          .map((item) => HighScore.fromJson(item as Map<String, dynamic>))
          .toList();

      // Sort by net worth (highest first)
      scores.sort((a, b) => b.netWorth.compareTo(a.netWorth));
      return scores;
    } catch (e) {
      return [];
    }
  }

  /// Add a new high score and save.
  Future<bool> addHighScore(HighScore score) async {
    final scores = await getHighScores();

    // Check if score makes the high score list
    if (scores.length >= maxHighScores &&
        score.netWorth <= scores.last.netWorth) {
      return false; // Didn't make the list
    }

    // Add the score
    scores.add(score);

    // Sort by net worth (highest first)
    scores.sort((a, b) => b.netWorth.compareTo(a.netWorth));

    // Keep only top scores
    final topScores = scores.take(maxHighScores).toList();

    // Save to preferences
    final scoresJson = jsonEncode(topScores.map((s) => s.toJson()).toList());
    await _prefs.setString(_highScoresKey, scoresJson);

    return true; // Score was added
  }

  /// Check if a score qualifies for high score list.
  Future<bool> isHighScore(int netWorth) async {
    final scores = await getHighScores();

    if (scores.length < maxHighScores) {
      return true; // Always qualifies if list not full
    }

    return netWorth > scores.last.netWorth;
  }

  /// Get rank of a score (1-based index, or 0 if not in list).
  Future<int> getRank(int netWorth) async {
    final scores = await getHighScores();

    for (int i = 0; i < scores.length; i++) {
      if (scores[i].netWorth <= netWorth) {
        return i + 1;
      }
    }

    return 0; // Not in list
  }

  /// Clear all high scores (for testing).
  Future<void> clearHighScores() async {
    await _prefs.remove(_highScoresKey);
  }
}

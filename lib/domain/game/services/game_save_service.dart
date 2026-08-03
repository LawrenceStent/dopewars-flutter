import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../entities/game_session.dart';

/// Service for managing game saves with persistence.
class GameSaveService {
  static const String _savesKey = 'dopewars_saves';
  static const String _lastSaveKey = 'dopewars_last_save';

  final SharedPreferences _prefs;

  const GameSaveService({required SharedPreferences prefs}) : _prefs = prefs;

  /// Get all saved games.
  Future<List<GameSession>> getSaves() async {
    final savesJson = _prefs.getString(_savesKey);
    if (savesJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(savesJson) as List<dynamic>;
      final saves = decoded
          .map((item) => GameSession.fromJson(item as Map<String, dynamic>))
          .toList();

      // Sort by saved time (most recent first)
      saves.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      return saves;
    } catch (e) {
      return [];
    }
  }

  /// Save a game session.
  Future<bool> saveGame(GameSession session) async {
    try {
      final saves = await getSaves();

      // Remove any existing save with the same ID
      saves.removeWhere((s) => s.id == session.id);

      // Add the new save
      saves.add(session);

      // Save to preferences
      final savesJson = jsonEncode(saves.map((s) => s.toJson()).toList());
      await _prefs.setString(_savesKey, savesJson);
      await _prefs.setString(_lastSaveKey, session.id);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Load a specific game session.
  Future<GameSession?> loadGame(String saveId) async {
    try {
      final saves = await getSaves();
      return saves.firstWhere(
        (s) => s.id == saveId,
        orElse: () => throw Exception('Save not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get the last save.
  Future<GameSession?> getLastSave() async {
    try {
      final lastSaveId = _prefs.getString(_lastSaveKey);
      if (lastSaveId == null) return null;
      return await loadGame(lastSaveId);
    } catch (e) {
      return null;
    }
  }

  /// Delete a game save.
  Future<bool> deleteSave(String saveId) async {
    try {
      final saves = await getSaves();
      saves.removeWhere((s) => s.id == saveId);

      if (saves.isEmpty) {
        await _prefs.remove(_savesKey);
      } else {
        final savesJson = jsonEncode(saves.map((s) => s.toJson()).toList());
        await _prefs.setString(_savesKey, savesJson);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all saves (for testing).
  Future<void> clearSaves() async {
    await _prefs.remove(_savesKey);
    await _prefs.remove(_lastSaveKey);
  }
}

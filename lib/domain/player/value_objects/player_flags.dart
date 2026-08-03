import 'package:equatable/equatable.dart';

/// Player flags representing various game states.
/// Ported from dopewars.h lines 142-151.
/// Uses bitwise operations like the original C code.
enum PlayerFlag {
  firstTurn(1 << 0), // 1 - First turn of the game
  deadHardass(1 << 1), // 2 - Killed Officer Hardass
  tippedOff(1 << 2), // 4 - Player has been tipped off
  spiedOn(1 << 3), // 8 - Being spied on by another player
  spyingOn(1 << 4), // 16 - Spying on another player
  fighting(1 << 5), // 32 - Currently in combat
  canShoot(1 << 6), // 64 - Can shoot this turn in combat
  trading(1 << 7), // 128 - Currently trading
  lawyerActive(1 << 8); // 256 - Lawyer protection active (one-time arrest conversion)

  final int value;
  const PlayerFlag(this.value);
}

/// Immutable value object for managing player flags.
class PlayerFlags extends Equatable {
  final int _flags;

  const PlayerFlags._(this._flags);

  /// Create with no flags set.
  const PlayerFlags.none() : _flags = 0;

  /// Create from raw integer value.
  const PlayerFlags.fromRaw(int flags) : _flags = flags;

  /// Create with initial first turn flag set.
  const PlayerFlags.initial() : _flags = 1; // FIRSTTURN

  /// Get raw integer value.
  int get raw => _flags;

  /// Check if a specific flag is set.
  bool has(PlayerFlag flag) => (_flags & flag.value) != 0;

  /// Check if player is on first turn.
  bool get isFirstTurn => has(PlayerFlag.firstTurn);

  /// Check if player killed Officer Hardass.
  bool get killedHardass => has(PlayerFlag.deadHardass);

  /// Check if player has been tipped off.
  bool get isTippedOff => has(PlayerFlag.tippedOff);

  /// Check if player is being spied on.
  bool get isSpiedOn => has(PlayerFlag.spiedOn);

  /// Check if player is spying on someone.
  bool get isSpyingOn => has(PlayerFlag.spyingOn);

  /// Check if player is in combat.
  bool get isFighting => has(PlayerFlag.fighting);

  /// Check if player can shoot.
  bool get canShoot => has(PlayerFlag.canShoot);

  /// Check if player is trading.
  bool get isTrading => has(PlayerFlag.trading);

  /// Check if player has lawyer protection active.
  bool get hasLawyer => has(PlayerFlag.lawyerActive);

  /// Set a flag (returns new instance).
  PlayerFlags withFlag(PlayerFlag flag) {
    return PlayerFlags._(_flags | flag.value);
  }

  /// Clear a flag (returns new instance).
  PlayerFlags withoutFlag(PlayerFlag flag) {
    return PlayerFlags._(_flags & ~flag.value);
  }

  /// Toggle a flag (returns new instance).
  PlayerFlags toggleFlag(PlayerFlag flag) {
    return PlayerFlags._(_flags ^ flag.value);
  }

  /// Set multiple flags at once.
  PlayerFlags withFlags(List<PlayerFlag> flags) {
    var newFlags = _flags;
    for (final flag in flags) {
      newFlags |= flag.value;
    }
    return PlayerFlags._(newFlags);
  }

  /// Clear multiple flags at once.
  PlayerFlags withoutFlags(List<PlayerFlag> flags) {
    var newFlags = _flags;
    for (final flag in flags) {
      newFlags &= ~flag.value;
    }
    return PlayerFlags._(newFlags);
  }

  /// Clear all flags.
  PlayerFlags clear() => const PlayerFlags.none();

  /// Get list of all set flags.
  List<PlayerFlag> get setFlags {
    return PlayerFlag.values.where((flag) => has(flag)).toList();
  }

  @override
  List<Object?> get props => [_flags];

  @override
  String toString() {
    final flags = setFlags;
    if (flags.isEmpty) return 'PlayerFlags(none)';
    return 'PlayerFlags(${flags.map((f) => f.name).join(', ')})';
  }
}

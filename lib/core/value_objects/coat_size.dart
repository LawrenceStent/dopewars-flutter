import 'package:equatable/equatable.dart';

import '../constants/game_constants.dart';

/// Value object representing carrying capacity (coat size).
/// Determines how many drugs the player can carry.
/// In the original game, this starts at 100 and can be increased
/// by hiring "bitches" who can carry additional items.
class CoatSize extends Equatable implements Comparable<CoatSize> {
  final int _value;

  const CoatSize._(this._value);

  /// Create CoatSize with validation (must be non-negative).
  factory CoatSize(int value) {
    if (value < 0) {
      throw ArgumentError('CoatSize cannot be negative: $value');
    }
    return CoatSize._(value);
  }

  /// Default starting coat size.
  static CoatSize get starting => CoatSize(GameConstants.startCoatSize);

  /// Get the raw value.
  int get value => _value;

  /// Check if there's any capacity.
  bool get hasCapacity => _value > 0;

  /// Check if empty.
  bool get isEmpty => _value == 0;

  /// Add capacity (e.g., from hiring a bitch).
  CoatSize add(int amount) {
    return CoatSize(_value + amount);
  }

  /// Remove capacity.
  CoatSize remove(int amount) {
    final newValue = _value - amount;
    if (newValue < 0) {
      throw ArgumentError('Cannot remove more capacity than available');
    }
    return CoatSize(newValue);
  }

  /// Check if can carry a certain amount.
  bool canCarry(int amount) => amount <= _value;

  @override
  int compareTo(CoatSize other) => _value.compareTo(other._value);

  bool operator >(CoatSize other) => _value > other._value;
  bool operator >=(CoatSize other) => _value >= other._value;
  bool operator <(CoatSize other) => _value < other._value;
  bool operator <=(CoatSize other) => _value <= other._value;

  @override
  List<Object?> get props => [_value];

  @override
  String toString() => '$_value';
}

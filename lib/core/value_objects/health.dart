import 'package:equatable/equatable.dart';

import '../constants/game_constants.dart';

/// Value object representing player health (0-100).
/// A health of 0 or less means death.
class Health extends Equatable implements Comparable<Health> {
  final int _value;

  const Health._(this._value);

  /// Create Health with validation (clamped to 0-100).
  factory Health(int value) {
    return Health._(value.clamp(0, 100));
  }

  /// Create Health without clamping (for calculations that may go negative).
  const Health.unclamped(int value) : _value = value;

  /// Full health (100).
  static const Health full = Health._(100);

  /// Dead (0).
  static const Health dead = Health._(0);

  /// Default starting health.
  static Health get starting => Health(GameConstants.startHealth);

  /// Get the raw value.
  int get value => _value;

  /// Check if the player is dead (health <= 0).
  bool get isDead => _value <= 0;

  /// Check if the player is alive (health > 0).
  bool get isAlive => _value > 0;

  /// Check if health is full.
  bool get isFull => _value >= 100;

  /// Get health as a percentage (0.0 to 1.0).
  double get percentage => _value / 100.0;

  /// Take damage (returns new Health, clamped to 0).
  Health takeDamage(int damage) {
    return Health(_value - damage);
  }

  /// Heal (returns new Health, clamped to 100).
  Health heal(int amount) {
    return Health(_value + amount);
  }

  /// Set to a specific value (clamped).
  Health setTo(int value) {
    return Health(value);
  }

  @override
  int compareTo(Health other) => _value.compareTo(other._value);

  bool operator >(Health other) => _value > other._value;
  bool operator >=(Health other) => _value >= other._value;
  bool operator <(Health other) => _value < other._value;
  bool operator <=(Health other) => _value <= other._value;

  @override
  List<Object?> get props => [_value];

  @override
  String toString() => '$_value%';
}

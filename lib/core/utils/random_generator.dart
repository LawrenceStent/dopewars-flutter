import 'dart:math';

/// Abstract interface for random number generation.
/// This abstraction allows for deterministic testing by injecting mock generators.
abstract class RandomGenerator {
  /// Generate a random integer in range [min, max] (inclusive).
  int nextInt(int min, int max);

  /// Generate a random double in range [0.0, 1.0).
  double nextDouble();

  /// Generate a random boolean with given probability of being true.
  bool nextBool([double probability = 0.5]);

  /// Pick a random element from a list.
  T pickFrom<T>(List<T> list);

  /// Shuffle a list (returns a new shuffled copy).
  List<T> shuffle<T>(List<T> list);
}

/// Default implementation using Dart's Random.
class DefaultRandomGenerator implements RandomGenerator {
  final Random _random;

  DefaultRandomGenerator([int? seed]) : _random = Random(seed);

  @override
  int nextInt(int min, int max) {
    if (min > max) {
      throw ArgumentError('min ($min) must be <= max ($max)');
    }
    if (min == max) return min;
    return min + _random.nextInt(max - min + 1);
  }

  @override
  double nextDouble() => _random.nextDouble();

  @override
  bool nextBool([double probability = 0.5]) {
    return _random.nextDouble() < probability;
  }

  @override
  T pickFrom<T>(List<T> list) {
    if (list.isEmpty) {
      throw ArgumentError('Cannot pick from empty list');
    }
    return list[_random.nextInt(list.length)];
  }

  @override
  List<T> shuffle<T>(List<T> list) {
    final result = List<T>.from(list);
    result.shuffle(_random);
    return result;
  }
}

/// Mock implementation for deterministic testing.
class MockRandomGenerator implements RandomGenerator {
  final List<int> _intValues;
  final List<double> _doubleValues;
  int _intIndex = 0;
  int _doubleIndex = 0;

  MockRandomGenerator({
    List<int>? intValues,
    List<double>? doubleValues,
  })  : _intValues = intValues ?? [],
        _doubleValues = doubleValues ?? [];

  @override
  int nextInt(int min, int max) {
    if (_intValues.isEmpty) {
      return min; // Default behavior if no values provided
    }
    final value = _intValues[_intIndex % _intValues.length];
    _intIndex++;
    // Clamp to range
    return value.clamp(min, max);
  }

  @override
  double nextDouble() {
    if (_doubleValues.isEmpty) {
      return 0.5; // Default behavior
    }
    final value = _doubleValues[_doubleIndex % _doubleValues.length];
    _doubleIndex++;
    return value.clamp(0.0, 1.0);
  }

  @override
  bool nextBool([double probability = 0.5]) {
    return nextDouble() < probability;
  }

  @override
  T pickFrom<T>(List<T> list) {
    if (list.isEmpty) {
      throw ArgumentError('Cannot pick from empty list');
    }
    return list[nextInt(0, list.length - 1)];
  }

  @override
  List<T> shuffle<T>(List<T> list) {
    // For mock, return as-is (deterministic)
    return List<T>.from(list);
  }

  /// Reset indices for reuse.
  void reset() {
    _intIndex = 0;
    _doubleIndex = 0;
  }
}

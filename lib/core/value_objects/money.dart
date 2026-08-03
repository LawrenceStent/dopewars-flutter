import 'package:equatable/equatable.dart';

/// Value object representing money in the game.
/// Uses int (cents) internally to avoid floating point precision issues.
/// The original C code uses price_t (long long) for money values.
class Money extends Equatable implements Comparable<Money> {
  final int _cents;

  const Money._(this._cents);

  /// Create Money from a dollar amount (integer).
  const Money(int dollars) : _cents = dollars * 100;

  /// Create Money from cents.
  const Money.fromCents(int cents) : _cents = cents;

  /// Zero money value.
  static const Money zero = Money._(0);

  /// Get the value in dollars (integer, truncated).
  int get dollars => _cents ~/ 100;

  /// Get the value in cents.
  int get cents => _cents;

  /// Check if this is zero or negative.
  bool get isZeroOrNegative => _cents <= 0;

  /// Check if this is positive.
  bool get isPositive => _cents > 0;

  /// Check if this is negative.
  bool get isNegative => _cents < 0;

  /// Add two Money values.
  Money operator +(Money other) => Money._(_cents + other._cents);

  /// Subtract two Money values.
  Money operator -(Money other) => Money._(_cents - other._cents);

  /// Multiply by a scalar (for interest calculations).
  Money operator *(num factor) => Money._((_cents * factor).round());

  /// Divide by a scalar.
  Money operator /(num divisor) => Money._((_cents / divisor).round());

  /// Integer division.
  Money integerDivide(int divisor) => Money._(_cents ~/ divisor);

  /// Check if greater than.
  bool operator >(Money other) => _cents > other._cents;

  /// Check if greater than or equal.
  bool operator >=(Money other) => _cents >= other._cents;

  /// Check if less than.
  bool operator <(Money other) => _cents < other._cents;

  /// Check if less than or equal.
  bool operator <=(Money other) => _cents <= other._cents;

  /// Negate the value.
  Money operator -() => Money._(-_cents);

  /// Get absolute value.
  Money abs() => Money._(_cents.abs());

  /// Apply interest rate (percentage as integer, e.g., 10 for 10%).
  Money applyInterest(int percentRate) {
    return this * (1.0 + percentRate / 100.0);
  }

  @override
  int compareTo(Money other) => _cents.compareTo(other._cents);

  @override
  List<Object?> get props => [_cents];

  @override
  String toString() {
    final isNeg = _cents < 0;
    final absCents = _cents.abs();
    final wholeDollars = absCents ~/ 100;
    final formatted = '\$${_formatWithCommas(wholeDollars)}';
    return isNeg ? '-$formatted' : formatted;
  }

  String _formatWithCommas(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

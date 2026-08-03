import 'package:dopewars_flutter/core/value_objects/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money', () {
    group('construction', () {
      test('creates from dollars', () {
        const money = Money(100);
        expect(money.dollars, 100);
        expect(money.cents, 10000);
      });

      test('creates from cents', () {
        const money = Money.fromCents(12345);
        expect(money.cents, 12345);
        expect(money.dollars, 123);
      });

      test('zero is properly defined', () {
        expect(Money.zero.dollars, 0);
        expect(Money.zero.cents, 0);
      });
    });

    group('arithmetic', () {
      test('adds two Money values', () {
        const a = Money(100);
        const b = Money(50);
        expect((a + b).dollars, 150);
      });

      test('subtracts two Money values', () {
        const a = Money(100);
        const b = Money(40);
        expect((a - b).dollars, 60);
      });

      test('multiplies by scalar', () {
        const money = Money(100);
        expect((money * 2).dollars, 200);
        expect((money * 1.5).dollars, 150);
      });

      test('divides by scalar', () {
        const money = Money(100);
        expect((money / 2).dollars, 50);
        expect((money / 4).dollars, 25);
      });

      test('integer divides', () {
        const money = Money(100);
        expect(money.integerDivide(3).dollars, 33);
      });

      test('negates value', () {
        const money = Money(100);
        expect((-money).dollars, -100);
      });

      test('absolute value', () {
        const negative = Money.fromCents(-5000);
        expect(negative.abs().dollars, 50);
      });
    });

    group('comparisons', () {
      test('greater than', () {
        const a = Money(100);
        const b = Money(50);
        expect(a > b, true);
        expect(b > a, false);
      });

      test('less than', () {
        const a = Money(50);
        const b = Money(100);
        expect(a < b, true);
        expect(b < a, false);
      });

      test('greater than or equal', () {
        const a = Money(100);
        const b = Money(100);
        const c = Money(50);
        expect(a >= b, true);
        expect(a >= c, true);
      });

      test('less than or equal', () {
        const a = Money(100);
        const b = Money(100);
        const c = Money(150);
        expect(a <= b, true);
        expect(a <= c, true);
      });

      test('equality', () {
        const a = Money(100);
        const b = Money(100);
        const c = Money(50);
        expect(a == b, true);
        expect(a == c, false);
      });
    });

    group('state checks', () {
      test('isZeroOrNegative', () {
        expect(Money.zero.isZeroOrNegative, true);
        expect(const Money.fromCents(-100).isZeroOrNegative, true);
        expect(const Money(100).isZeroOrNegative, false);
      });

      test('isPositive', () {
        expect(const Money(100).isPositive, true);
        expect(Money.zero.isPositive, false);
        expect(const Money.fromCents(-100).isPositive, false);
      });

      test('isNegative', () {
        expect(const Money.fromCents(-100).isNegative, true);
        expect(Money.zero.isNegative, false);
        expect(const Money(100).isNegative, false);
      });
    });

    group('interest calculation', () {
      test('applies 10% interest', () {
        const money = Money(1000);
        final withInterest = money.applyInterest(10);
        expect(withInterest.dollars, 1100);
      });

      test('applies 5% interest', () {
        const money = Money(2000);
        final withInterest = money.applyInterest(5);
        expect(withInterest.dollars, 2100);
      });
    });

    group('formatting', () {
      test('formats positive dollars', () {
        const money = Money(1234);
        expect(money.toString(), '\$1,234');
      });

      test('formats negative dollars', () {
        const money = Money.fromCents(-123400);
        expect(money.toString(), '-\$1,234');
      });

      test('formats zero', () {
        expect(Money.zero.toString(), '\$0');
      });

      test('formats large numbers with commas', () {
        const money = Money(1234567);
        expect(money.toString(), '\$1,234,567');
      });
    });

    group('game constants validation', () {
      test('starting cash is 2000', () {
        const startCash = Money(2000);
        expect(startCash.dollars, 2000);
      });

      test('starting debt is 5500', () {
        const startDebt = Money(5500);
        expect(startDebt.dollars, 5500);
      });
    });
  });
}

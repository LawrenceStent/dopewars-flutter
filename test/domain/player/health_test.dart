import 'package:dopewars_flutter/core/value_objects/health.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Health', () {
    group('construction', () {
      test('creates health with valid value', () {
        final health = Health(75);
        expect(health.value, 75);
      });

      test('clamps to 100 if exceeds', () {
        final health = Health(150);
        expect(health.value, 100);
      });

      test('clamps to 0 if negative', () {
        final health = Health(-50);
        expect(health.value, 0);
      });

      test('full health is 100', () {
        expect(Health.full.value, 100);
      });

      test('dead health is 0', () {
        expect(Health.dead.value, 0);
      });

      test('starting health is 100', () {
        expect(Health.starting.value, 100);
      });
    });

    group('state checks', () {
      test('isDead when health is 0', () {
        expect(Health.dead.isDead, true);
        expect(Health(0).isDead, true);
      });

      test('isAlive when health is positive', () {
        expect(Health.full.isAlive, true);
        expect(Health(1).isAlive, true);
        expect(Health.dead.isAlive, false);
      });

      test('isFull when health is 100', () {
        expect(Health.full.isFull, true);
        expect(Health(99).isFull, false);
      });

      test('percentage returns correct value', () {
        expect(Health.full.percentage, 1.0);
        expect(Health(50).percentage, 0.5);
        expect(Health.dead.percentage, 0.0);
      });
    });

    group('damage and healing', () {
      test('takeDamage reduces health', () {
        final health = Health(100);
        final damaged = health.takeDamage(30);
        expect(damaged.value, 70);
      });

      test('takeDamage clamps to 0', () {
        final health = Health(50);
        final damaged = health.takeDamage(100);
        expect(damaged.value, 0);
        expect(damaged.isDead, true);
      });

      test('heal increases health', () {
        final health = Health(50);
        final healed = health.heal(30);
        expect(healed.value, 80);
      });

      test('heal clamps to 100', () {
        final health = Health(90);
        final healed = health.heal(50);
        expect(healed.value, 100);
      });

      test('setTo sets specific value', () {
        final health = Health(50);
        final set = health.setTo(75);
        expect(set.value, 75);
      });
    });

    group('comparisons', () {
      test('greater than', () {
        expect(Health(100) > Health(50), true);
        expect(Health(50) > Health(100), false);
      });

      test('less than', () {
        expect(Health(50) < Health(100), true);
        expect(Health(100) < Health(50), false);
      });

      test('equality', () {
        expect(Health(50) == Health(50), true);
        expect(Health(50) == Health(60), false);
      });
    });

    group('formatting', () {
      test('toString shows percentage', () {
        expect(Health(75).toString(), '75%');
        expect(Health.full.toString(), '100%');
      });
    });
  });
}

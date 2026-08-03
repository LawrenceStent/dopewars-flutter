import 'package:equatable/equatable.dart';

import '../../../core/value_objects/money.dart';

/// Gun type enum.
enum GunType {
  baretta,
  special38,
  ruger,
  saturdayNightSpecial,
}

/// Represents a gun type with its properties.
/// Ported from struct GUN in dopewars.h lines 233-238.
class Gun extends Equatable {
  final GunType type;
  final String name;
  final Money price;

  /// Space taken in inventory (all guns take 4 in default config).
  final int space;

  /// Damage dealt per shot.
  final int damage;

  const Gun({
    required this.type,
    required this.name,
    required this.price,
    required this.space,
    required this.damage,
  });

  /// Get the index of this gun.
  int get index => type.index;

  @override
  List<Object?> get props => [type, name, price, space, damage];

  @override
  String toString() => 'Gun($name, damage: $damage)';
}

/// Default guns ported from dopewars.c lines 706-712.
class DefaultGuns {
  DefaultGuns._();

  static const List<Gun> all = [
    Gun(
      type: GunType.baretta,
      name: 'Baretta',
      price: Money(3000),
      space: 4,
      damage: 5,
    ),
    Gun(
      type: GunType.special38,
      name: '.38 Special',
      price: Money(3500),
      space: 4,
      damage: 9,
    ),
    Gun(
      type: GunType.ruger,
      name: 'Ruger',
      price: Money(2900),
      space: 4,
      damage: 4,
    ),
    Gun(
      type: GunType.saturdayNightSpecial,
      name: 'Saturday Night Special',
      price: Money(3100),
      space: 4,
      damage: 7,
    ),
  ];

  static Gun byType(GunType type) => all.firstWhere((g) => g.type == type);

  static Gun byIndex(int index) => all[index];

  static int get count => all.length;
}

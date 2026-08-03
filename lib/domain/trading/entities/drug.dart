import 'package:equatable/equatable.dart';

import '../../../core/value_objects/money.dart';

/// Drug index enum matching the original C code (dopewars.h lines 154-157).
enum DrugType {
  acid,
  cocaine,
  hashish,
  heroin,
  ludes,
  mda,
  opium,
  pcp,
  peyote,
  shrooms,
  speed,
  weed,
}

/// Represents a drug type with its properties.
/// Ported from struct DRUG in dopewars.h lines 255-260.
class Drug extends Equatable {
  final DrugType type;
  final String name;
  final Money minPrice;
  final Money maxPrice;
  final bool canBeCheap;
  final bool canBeExpensive;
  final String? cheapMessage;

  const Drug({
    required this.type,
    required this.name,
    required this.minPrice,
    required this.maxPrice,
    required this.canBeCheap,
    required this.canBeExpensive,
    this.cheapMessage,
  });

  @override
  List<Object?> get props => [
        type,
        name,
        minPrice,
        maxPrice,
        canBeCheap,
        canBeExpensive,
        cheapMessage,
      ];

  @override
  String toString() => 'Drug($name)';
}

/// Default drugs ported from dopewars.c lines 714-734.
class DefaultDrugs {
  DefaultDrugs._();

  static const List<Drug> all = [
    Drug(
      type: DrugType.acid,
      name: 'Acid',
      minPrice: Money(1000),
      maxPrice: Money(4400),
      canBeCheap: true,
      canBeExpensive: false,
      cheapMessage: 'The market is flooded with cheap home-made acid!',
    ),
    Drug(
      type: DrugType.cocaine,
      name: 'Cocaine',
      minPrice: Money(15000),
      maxPrice: Money(29000),
      canBeCheap: false,
      canBeExpensive: true,
    ),
    Drug(
      type: DrugType.hashish,
      name: 'Hashish',
      minPrice: Money(480),
      maxPrice: Money(1280),
      canBeCheap: true,
      canBeExpensive: false,
      cheapMessage: 'The Marrakesh Express has arrived!',
    ),
    Drug(
      type: DrugType.heroin,
      name: 'Heroin',
      minPrice: Money(5500),
      maxPrice: Money(13000),
      canBeCheap: false,
      canBeExpensive: true,
    ),
    Drug(
      type: DrugType.ludes,
      name: 'Ludes',
      minPrice: Money(11),
      maxPrice: Money(60),
      canBeCheap: true,
      canBeExpensive: false,
      cheapMessage:
          'Rival drug dealers raided a pharmacy and are selling cheap ludes!',
    ),
    Drug(
      type: DrugType.mda,
      name: 'MDA',
      minPrice: Money(1500),
      maxPrice: Money(4400),
      canBeCheap: false,
      canBeExpensive: false,
    ),
    Drug(
      type: DrugType.opium,
      name: 'Opium',
      minPrice: Money(540),
      maxPrice: Money(1250),
      canBeCheap: false,
      canBeExpensive: true,
    ),
    Drug(
      type: DrugType.pcp,
      name: 'PCP',
      minPrice: Money(1000),
      maxPrice: Money(2500),
      canBeCheap: false,
      canBeExpensive: false,
    ),
    Drug(
      type: DrugType.peyote,
      name: 'Peyote',
      minPrice: Money(220),
      maxPrice: Money(700),
      canBeCheap: false,
      canBeExpensive: false,
    ),
    Drug(
      type: DrugType.shrooms,
      name: 'Shrooms',
      minPrice: Money(630),
      maxPrice: Money(1300),
      canBeCheap: false,
      canBeExpensive: false,
    ),
    Drug(
      type: DrugType.speed,
      name: 'Speed',
      minPrice: Money(90),
      maxPrice: Money(250),
      canBeCheap: false,
      canBeExpensive: true,
    ),
    Drug(
      type: DrugType.weed,
      name: 'Weed',
      minPrice: Money(315),
      maxPrice: Money(890),
      canBeCheap: true,
      canBeExpensive: false,
      cheapMessage:
          'Colombian freighter dusted the Coast Guard! Weed prices have bottomed out!',
    ),
  ];

  static Drug byType(DrugType type) => all.firstWhere((d) => d.type == type);

  static int get count => all.length;
}

/// Messages for expensive drug events.
/// From dopewars.c lines 751-756.
class DrugMessages {
  DrugMessages._();

  static const String expensiveMessage1 =
      'Cops made a big %drug bust! Prices are outrageous!';
  static const String expensiveMessage2 =
      'Addicts are buying %drug at ridiculous prices!';
}

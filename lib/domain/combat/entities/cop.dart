import 'package:equatable/equatable.dart';

/// Cop level enum.
enum CopLevel {
  officerHardass,
  officerBob,
  agentSmith,
}

/// Represents a cop type with its properties.
/// Ported from struct COP in dopewars.h lines 223-230.
class Cop extends Equatable {
  final CopLevel level;
  final String name;
  final String deputyName;
  final String deputiesName;

  /// Armor value (higher = harder to damage).
  final int armor;

  /// Deputy armor value.
  final int deputyArmor;

  /// Penalty to player's attack rating.
  final int attackPenalty;

  /// Penalty to player's defense rating.
  final int defendPenalty;

  /// Minimum number of deputies.
  final int minDeputies;

  /// Maximum number of deputies.
  final int maxDeputies;

  /// Index of gun this cop uses.
  final int gunIndex;

  /// Cop's gun damage.
  final int copGun;

  /// Deputy's gun damage.
  final int deputyGun;

  const Cop({
    required this.level,
    required this.name,
    required this.deputyName,
    required this.deputiesName,
    required this.armor,
    required this.deputyArmor,
    required this.attackPenalty,
    required this.defendPenalty,
    required this.minDeputies,
    required this.maxDeputies,
    required this.gunIndex,
    required this.copGun,
    required this.deputyGun,
  });

  /// Get the index of this cop level.
  int get index => level.index;

  @override
  List<Object?> get props => [
        level,
        name,
        deputyName,
        deputiesName,
        armor,
        deputyArmor,
        attackPenalty,
        defendPenalty,
        minDeputies,
        maxDeputies,
        gunIndex,
        copGun,
        deputyGun,
      ];

  @override
  String toString() => 'Cop($name)';
}

/// Default cops ported from dopewars.c lines 693-704.
class DefaultCops {
  DefaultCops._();

  static const List<Cop> all = [
    Cop(
      level: CopLevel.officerHardass,
      name: 'Officer Hardass',
      deputyName: 'deputy',
      deputiesName: 'deputies',
      armor: 4,
      deputyArmor: 3,
      attackPenalty: 30,
      defendPenalty: 30,
      minDeputies: 2,
      maxDeputies: 8,
      gunIndex: 0,
      copGun: 1,
      deputyGun: 1,
    ),
    Cop(
      level: CopLevel.officerBob,
      name: 'Officer Bob',
      deputyName: 'deputy',
      deputiesName: 'deputies',
      armor: 15,
      deputyArmor: 4,
      attackPenalty: 30,
      defendPenalty: 20,
      minDeputies: 4,
      maxDeputies: 10,
      gunIndex: 0,
      copGun: 2,
      deputyGun: 1,
    ),
    Cop(
      level: CopLevel.agentSmith,
      name: 'Agent Smith',
      deputyName: 'cop',
      deputiesName: 'cops',
      armor: 50,
      deputyArmor: 6,
      attackPenalty: 20,
      defendPenalty: 20,
      minDeputies: 6,
      maxDeputies: 18,
      gunIndex: 1,
      copGun: 3,
      deputyGun: 2,
    ),
  ];

  static Cop byLevel(CopLevel level) => all.firstWhere((c) => c.level == level);

  static Cop byIndex(int index) => all[index];

  static int get count => all.length;
}

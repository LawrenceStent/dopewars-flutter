import 'package:equatable/equatable.dart';

import '../../../core/utils/random_generator.dart';
import '../../../core/value_objects/money.dart';
import '../../trading/entities/drug.dart';

/// Types of random encounters that can happen during travel.
enum EncounterType {
  /// Player finds drugs on the ground
  findDrugs,

  /// Player gets mugged (loses cash)
  mugged,

  /// A friend offers to help carry drugs
  friendHelps,

  /// Police dog sniffs drugs
  policeDogs,

  /// Find a dead body with cash
  findBody,

  /// Someone offers cheap drugs (special deal)
  cheapOffer,

  /// No encounter
  none,
}

/// Result of a random encounter.
class EncounterResult extends Equatable {
  final EncounterType type;
  final String message;

  /// Amount of money gained or lost (negative for loss).
  final Money? moneyChange;

  /// Drug type involved in the encounter.
  final DrugType? drugType;

  /// Quantity of drugs involved.
  final int? drugQuantity;

  /// Extra coat space gained (from bitch/friend).
  final int? extraSpace;

  const EncounterResult({
    required this.type,
    required this.message,
    this.moneyChange,
    this.drugType,
    this.drugQuantity,
    this.extraSpace,
  });

  const EncounterResult.none()
      : type = EncounterType.none,
        message = '',
        moneyChange = null,
        drugType = null,
        drugQuantity = null,
        extraSpace = null;

  bool get hasEncounter => type != EncounterType.none;

  @override
  List<Object?> get props =>
      [type, message, moneyChange, drugType, drugQuantity, extraSpace];
}

/// Service for generating random encounters during travel.
/// Ported from serverside.c RandomOffer() lines 3047-3152.
class RandomEncounterService {
  final RandomGenerator _random;

  /// Probability of each event (out of 100).
  static const int muggedChance = 10;
  static const int friendChance = 30;
  static const int policeDogsChance = 50;
  static const int findBodyChance = 60;
  static const int findDrugsChance = 40;

  const RandomEncounterService({required RandomGenerator random})
      : _random = random;

  /// Check for random encounter when traveling.
  /// Returns an encounter result (may be none).
  EncounterResult checkForEncounter({
    required Money playerCash,
    required int playerDrugCount,
    required int turn,
  }) {
    // Roll for each encounter type
    final roll = _random.nextInt(1, 100);

    // 10% chance to get mugged (only if carrying cash)
    if (roll <= muggedChance && playerCash.dollars > 0) {
      return _generateMugging(playerCash);
    }

    // 30% chance a friend increases coat size (early game bonus)
    if (roll <= friendChance && turn <= 10) {
      return _generateFriendHelp();
    }

    // 40% chance to find drugs on the ground
    if (roll <= findDrugsChance) {
      return _generateFindDrugs();
    }

    // 60% chance to find a dead body with cash
    if (roll <= findBodyChance) {
      return _generateFindBody();
    }

    return const EncounterResult.none();
  }

  /// Generate a mugging encounter.
  EncounterResult _generateMugging(Money playerCash) {
    // Lose 10-30% of cash
    final lossPercent = _random.nextInt(10, 30);
    final lossAmount = Money((playerCash.dollars * lossPercent) ~/ 100);

    return EncounterResult(
      type: EncounterType.mugged,
      message:
          'You were mugged in the subway! You lost \$${lossAmount.dollars}!',
      moneyChange: Money(-lossAmount.dollars),
    );
  }

  /// Generate a friend helping encounter.
  EncounterResult _generateFriendHelp() {
    final extraSpace = _random.nextInt(5, 15);

    return EncounterResult(
      type: EncounterType.friendHelps,
      message:
          'A friend with a big coat joins you! You can carry $extraSpace more.',
      extraSpace: extraSpace,
    );
  }

  /// Generate finding drugs on the ground.
  EncounterResult _generateFindDrugs() {
    // Pick a random cheap drug
    final cheapDrugs = [DrugType.weed, DrugType.ludes, DrugType.shrooms];
    final drugType = cheapDrugs[_random.nextInt(0, cheapDrugs.length - 1)];
    final drug = DefaultDrugs.byType(drugType);
    final quantity = _random.nextInt(2, 8);

    return EncounterResult(
      type: EncounterType.findDrugs,
      message:
          'You found $quantity units of ${drug.name} on the ground! Nice score!',
      drugType: drugType,
      drugQuantity: quantity,
    );
  }

  /// Generate finding a dead body.
  EncounterResult _generateFindBody() {
    final cashFound = Money(_random.nextInt(50, 500));

    return EncounterResult(
      type: EncounterType.findBody,
      message:
          'You stumble upon a dead body! You find \$${cashFound.dollars} in their pockets.',
      moneyChange: cashFound,
    );
  }

  /// Check if police encounter should happen based on location and player heat.
  /// Returns true if police should attack.
  ///
  /// Formula: roll <= (policePresence + heatModifier)
  /// heatModifier = (globalHeat / 10) for a 0-10 bonus at heat 0-100
  bool shouldPoliceAttack({
    required int policePresence,
    required int playerDrugCount,
    required int globalHeat,
  }) {
    if (playerDrugCount == 0) return false;

    // Calculate heat modifier (0-10 bonus based on heat level 0-100)
    final heatModifier = (globalHeat / 10).round();

    // Combine police presence with heat modifier
    final effectivePresence = policePresence + heatModifier;

    // Roll against combined presence
    final roll = _random.nextInt(1, 100);
    return roll <= effectivePresence.clamp(0, 100);
  }
}

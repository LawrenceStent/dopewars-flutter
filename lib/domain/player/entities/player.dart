import 'package:equatable/equatable.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/value_objects/coat_size.dart';
import '../../../core/value_objects/health.dart';
import '../../../core/value_objects/money.dart';
import '../../game/entities/game_event.dart';
import '../../trading/entities/drug.dart';
import '../value_objects/player_flags.dart';
import 'inventory.dart';

/// Main player entity containing all player state.
/// Ported from struct PLAYER_T in dopewars.h lines 290-322.
class Player extends Equatable {
  /// Unique player identifier.
  final String id;

  /// Player's display name.
  final String name;

  /// Current turn number (1-31 in default game).
  final int turn;

  /// Current game date.
  final DateTime date;

  /// Cash on hand.
  final Money cash;

  /// Debt owed to the loan shark.
  final Money debt;

  /// Money deposited in the bank.
  final Money bank;

  /// Player's health (0-100).
  final Health health;

  /// Carrying capacity (coat size).
  final CoatSize coatSize;

  /// Current location index.
  final int locationIndex;

  /// Player flags (bitwise state).
  final PlayerFlags flags;

  /// Gun inventory (keyed by gun index).
  final Map<int, Inventory> guns;

  /// Drug inventory (keyed by drug type).
  final Map<DrugType, Inventory> drugs;

  /// Number of bitches hired.
  final int bitches;

  /// Current event pending.
  final GameEvent currentEvent;

  /// Cop index for combat:
  /// - >0: This player is a cop (Cop[copIndex-1])
  /// - ==0: Normal player, has killed no cops
  /// - <0: Normal player who has killed cops up to Cop[-1-copIndex]
  final int copIndex;

  /// Doctor price if visiting doctor.
  final Money? doctorPrice;

  const Player({
    required this.id,
    required this.name,
    required this.turn,
    required this.date,
    required this.cash,
    required this.debt,
    required this.bank,
    required this.health,
    required this.coatSize,
    required this.locationIndex,
    required this.flags,
    required this.guns,
    required this.drugs,
    required this.bitches,
    required this.currentEvent,
    required this.copIndex,
    this.doctorPrice,
  });

  /// Create a new player with starting values.
  factory Player.newPlayer({
    required String id,
    required String name,
    int startingLocation = 0,
  }) {
    return Player(
      id: id,
      name: name,
      turn: 1,
      date: DateTime(
        GameConstants.startYear,
        GameConstants.startMonth,
        GameConstants.startDay,
      ),
      cash: const Money(GameConstants.startCash),
      debt: const Money(GameConstants.startDebt),
      bank: Money.zero,
      health: Health.full,
      coatSize: CoatSize.starting,
      locationIndex: startingLocation,
      flags: const PlayerFlags.initial(),
      guns: const {},
      drugs: const {},
      bitches: 0,
      currentEvent: GameEvent.none,
      copIndex: 0,
    );
  }

  /// Check if player is dead.
  bool get isDead => health.isDead;

  /// Check if player is alive.
  bool get isAlive => health.isAlive;

  /// Check if game is over (dead or finished all turns).
  bool get isGameOver => isDead || turn > GameConstants.numTurns;

  /// Check if player is in combat.
  bool get isInCombat => flags.isFighting;

  /// Check if this is the first turn.
  bool get isFirstTurn => flags.isFirstTurn;

  /// Get net worth (cash + bank - debt + inventory value).
  Money get netWorth {
    var total = cash + bank - debt;

    // Add gun values
    for (final entry in guns.entries) {
      total = total + entry.value.totalValue;
    }

    // Add drug values at average purchase price
    for (final entry in drugs.entries) {
      total = total + entry.value.totalValue;
    }

    return total;
  }

  /// Get total drugs carried.
  int get totalDrugsCarried {
    return drugs.values.fold(0, (sum, inv) => sum + inv.carried);
  }

  /// Get total guns carried.
  int get totalGunsCarried {
    return guns.values.fold(0, (sum, inv) => sum + inv.carried);
  }

  /// Get total space used by guns.
  int get gunSpaceUsed {
    // Each gun takes 4 space
    return totalGunsCarried * 4;
  }

  /// Get available carrying capacity.
  int get availableSpace {
    return coatSize.value - totalDrugsCarried - gunSpaceUsed;
  }

  /// Check if player can carry more items.
  bool canCarry(int amount) => availableSpace >= amount;

  /// Get drug inventory for a specific drug type.
  Inventory getDrugInventory(DrugType type) {
    return drugs[type] ?? Inventory.empty;
  }

  /// Get gun inventory for a specific gun index.
  Inventory getGunInventory(int gunIndex) {
    return guns[gunIndex] ?? Inventory.empty;
  }

  /// Copy with updated values.
  Player copyWith({
    String? id,
    String? name,
    int? turn,
    DateTime? date,
    Money? cash,
    Money? debt,
    Money? bank,
    Health? health,
    CoatSize? coatSize,
    int? locationIndex,
    PlayerFlags? flags,
    Map<int, Inventory>? guns,
    Map<DrugType, Inventory>? drugs,
    int? bitches,
    GameEvent? currentEvent,
    int? copIndex,
    Money? doctorPrice,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      turn: turn ?? this.turn,
      date: date ?? this.date,
      cash: cash ?? this.cash,
      debt: debt ?? this.debt,
      bank: bank ?? this.bank,
      health: health ?? this.health,
      coatSize: coatSize ?? this.coatSize,
      locationIndex: locationIndex ?? this.locationIndex,
      flags: flags ?? this.flags,
      guns: guns ?? this.guns,
      drugs: drugs ?? this.drugs,
      bitches: bitches ?? this.bitches,
      currentEvent: currentEvent ?? this.currentEvent,
      copIndex: copIndex ?? this.copIndex,
      doctorPrice: doctorPrice ?? this.doctorPrice,
    );
  }

  /// Add a drug to inventory.
  Player addDrug(DrugType type, int quantity, Money unitPrice) {
    final currentInv = getDrugInventory(type);
    final newInv = currentInv.add(quantity, unitPrice);
    final newDrugs = Map<DrugType, Inventory>.from(drugs);
    newDrugs[type] = newInv;
    return copyWith(drugs: newDrugs);
  }

  /// Remove a drug from inventory.
  Player removeDrug(DrugType type, int quantity) {
    final currentInv = getDrugInventory(type);
    if (currentInv.carried < quantity) {
      throw ArgumentError('Not enough $type to remove');
    }
    final newInv = currentInv.remove(quantity);
    final newDrugs = Map<DrugType, Inventory>.from(drugs);
    if (newInv.isEmpty) {
      newDrugs.remove(type);
    } else {
      newDrugs[type] = newInv;
    }
    return copyWith(drugs: newDrugs);
  }

  /// Add a gun to inventory.
  Player addGun(int gunIndex, Money unitPrice) {
    final currentInv = getGunInventory(gunIndex);
    final newInv = currentInv.add(1, unitPrice);
    final newGuns = Map<int, Inventory>.from(guns);
    newGuns[gunIndex] = newInv;
    return copyWith(guns: newGuns);
  }

  /// Remove a gun from inventory.
  Player removeGun(int gunIndex) {
    final currentInv = getGunInventory(gunIndex);
    if (currentInv.carried < 1) {
      throw ArgumentError('No gun of type $gunIndex to remove');
    }
    final newInv = currentInv.remove(1);
    final newGuns = Map<int, Inventory>.from(guns);
    if (newInv.isEmpty) {
      newGuns.remove(gunIndex);
    } else {
      newGuns[gunIndex] = newInv;
    }
    return copyWith(guns: newGuns);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        turn,
        date,
        cash,
        debt,
        bank,
        health,
        coatSize,
        locationIndex,
        flags,
        guns,
        drugs,
        bitches,
        currentEvent,
        copIndex,
        doctorPrice,
      ];

  @override
  String toString() =>
      'Player($name, turn: $turn, cash: $cash, health: $health)';
}

import 'package:equatable/equatable.dart';

import '../../player/entities/player.dart';
import '../services/damage_calculator.dart';
import 'cop.dart';
import 'gun.dart';

/// Represents the entire combat scenario.
/// Aggregates Player, Cop, and combat state.
class Fight extends Equatable {
  /// The player in combat
  final Player player;

  /// The cop the player is fighting
  final Cop cop;

  /// Cop's current health
  final int copHealth;

  /// Number of deputies assisting the cop
  final int deputyCount;

  /// Player's gun being used
  final Gun playerGun;

  /// Whether combat is ongoing
  final bool isActive;

  /// Whether player can shoot (for shoot check)
  final bool canShoot;

  /// Whether player can flee
  final bool canFlee;

  /// Combat history for display
  final List<String> combatLog;

  const Fight({
    required this.player,
    required this.cop,
    required this.copHealth,
    required this.deputyCount,
    required this.playerGun,
    this.isActive = true,
    this.canShoot = true,
    this.canFlee = true,
    this.combatLog = const [],
  });

  /// Check if cop is dead
  bool get isCopDead => copHealth <= 0;

  /// Check if player is dead
  bool get isPlayerDead => player.isDead;

  /// Check if combat is over
  bool get isOver => !isActive || isCopDead || isPlayerDead;

  /// Total damage cop has taken
  int get copDamageTaken {
    // Assume cop starts with some health based on level
    final startingHealth = _getCopStartingHealth();
    return startingHealth - copHealth;
  }

  /// Get cop's starting health based on level
  int _getCopStartingHealth() {
    // Cops have health based on armor and level
    // Use armor as base health + bonus
    return cop.armor + 50;
  }

  /// Create a new fight with initial conditions
  factory Fight.start({
    required Player player,
    required Cop cop,
    required Gun playerGun,
  }) {
    // Randomize deputy count within range
    // For now, use middle of range
    final deputyCount = (cop.minDeputies + cop.maxDeputies) ~/ 2;

    return Fight(
      player: player,
      cop: cop,
      copHealth: cop.armor + 50,
      deputyCount: deputyCount,
      playerGun: playerGun,
      combatLog: [
        'You encounter ${cop.name}!',
        '${cop.name} is backed by $deputyCount ${cop.deputiesName}!',
      ],
    );
  }

  /// Apply combat round results to create new Fight state
  Fight applyRound(CombatRound round) {
    var newCopHealth = copHealth;
    var newPlayerHealth = player.health;
    final log = <String>[...combatLog];

    // Update cop health
    if (round.playerHit) {
      newCopHealth -= round.playerDamage;
      log.add('You hit ${cop.name} for ${round.playerDamage} damage!');
    } else {
      log.add('Your shot misses ${cop.name}!');
    }

    // Update player health
    if (round.copHit) {
      final totalDamage = round.copDamage + round.deputyDamage;
      newPlayerHealth = newPlayerHealth.takeDamage(totalDamage);
      log.add('${cop.name} hits you for ${round.copDamage} damage!');
      if (round.deputyDamage > 0) {
        log.add('The ${cop.deputiesName} hit you for ${round.deputyDamage} damage!');
      }
    } else {
      log.add('${cop.name} misses you!');
    }

    return Fight(
      player: player.copyWith(health: newPlayerHealth),
      cop: cop,
      copHealth: newCopHealth,
      deputyCount: deputyCount,
      playerGun: playerGun,
      isActive: !isCopDead && !newPlayerHealth.isDead,
      combatLog: log,
    );
  }

  /// Player flees from combat
  Fight flee() {
    final log = <String>[...combatLog];
    log.add('You fled from ${cop.name}!');

    return Fight(
      player: player,
      cop: cop,
      copHealth: copHealth,
      deputyCount: deputyCount,
      playerGun: playerGun,
      isActive: false,
      canFlee: false,
      combatLog: log,
    );
  }

  /// Player dies in combat
  Fight playerDies() {
    final log = <String>[...combatLog];
    log.add('You have been shot! GAME OVER!');

    return Fight(
      player: player,
      cop: cop,
      copHealth: copHealth,
      deputyCount: deputyCount,
      playerGun: playerGun,
      isActive: false,
      combatLog: log,
    );
  }

  /// Cop dies in combat
  Fight copDies() {
    final log = <String>[...combatLog];
    log.add('You killed ${cop.name}!');

    return Fight(
      player: player,
      cop: cop,
      copHealth: 0,
      deputyCount: deputyCount,
      playerGun: playerGun,
      isActive: false,
      combatLog: log,
    );
  }

  @override
  List<Object?> get props => [
        player,
        cop,
        copHealth,
        deputyCount,
        playerGun,
        isActive,
        canShoot,
        canFlee,
        combatLog,
      ];
}

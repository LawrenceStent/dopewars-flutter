import '../../../core/utils/random_generator.dart';
import '../../player/entities/player.dart';
import '../entities/cop.dart';
import '../entities/gun.dart';

/// Result of a single combat round.
class CombatRound {
  /// Player's attack rating (higher = better)
  final int playerAttackRating;

  /// Cop's attack rating
  final int copAttackRating;

  /// Player's defense rating
  final int playerDefenseRating;

  /// Cop's defense rating
  final int copDefenseRating;

  /// Whether player hit the cop
  final bool playerHit;

  /// Whether cop hit the player
  final bool copHit;

  /// Damage dealt by player
  final int playerDamage;

  /// Damage dealt by cop
  final int copDamage;

  /// Total damage by deputies (if cop hit)
  final int deputyDamage;

  const CombatRound({
    required this.playerAttackRating,
    required this.copAttackRating,
    required this.playerDefenseRating,
    required this.copDefenseRating,
    required this.playerHit,
    required this.copHit,
    required this.playerDamage,
    required this.copDamage,
    required this.deputyDamage,
  });
}

/// Service for calculating combat damage.
/// Ported from serverside.c Fire() and HandleDamage() functions.
class DamageCalculator {
  final RandomGenerator _random;

  const DamageCalculator({required RandomGenerator random}) : _random = random;

  /// Resolve one round of combat.
  /// Returns the result of attacks and damage.
  CombatRound resolveCombatRound({
    required Player player,
    required Cop cop,
    required int copDeputies,
    required Gun playerGun,
  }) {
    // Calculate attack ratings
    final playerAttackRating = _calculatePlayerAttack(player, playerGun);
    final copAttackRating = _calculateCopAttack(cop);

    // Calculate defense ratings
    final playerDefenseRating = _calculatePlayerDefense(player);
    final copDefenseRating = _calculateCopDefense(cop);

    // Determine hits
    final playerHit = _checkHit(playerAttackRating, copDefenseRating);
    final copHit = _checkHit(copAttackRating, playerDefenseRating);

    // Calculate damage
    var playerDamage = 0;
    var copDamage = 0;
    var deputyDamage = 0;

    if (playerHit) {
      playerDamage = _calculateDamage(
        baseDamage: playerGun.damage,
        targetArmor: cop.armor,
      );
    }

    if (copHit) {
      // Cop deals damage (player has no armor, armor factor = 1)
      copDamage = _calculateDamage(
        baseDamage: cop.copGun,
        targetArmor: 1, // Player has no armor protection
      );

      // Deputies also attack
      deputyDamage = copDeputies *
          _calculateDamage(
            baseDamage: cop.deputyGun,
            targetArmor: 1, // Player has no armor protection
          );
    }

    return CombatRound(
      playerAttackRating: playerAttackRating,
      copAttackRating: copAttackRating,
      playerDefenseRating: playerDefenseRating,
      copDefenseRating: copDefenseRating,
      playerHit: playerHit,
      copHit: copHit,
      playerDamage: playerDamage,
      copDamage: copDamage,
      deputyDamage: deputyDamage,
    );
  }

  /// Calculate player's attack rating.
  /// From serverside.c: 80 + sum(gun.damage * carried)
  int _calculatePlayerAttack(Player player, Gun playerGun) {
    const baseAttack = 80;
    return baseAttack + playerGun.damage;
  }

  /// Calculate cop's attack rating.
  /// Similar to player but based on cop's gun damage
  int _calculateCopAttack(Cop cop) {
    const baseAttack = 80;
    return baseAttack + cop.copGun;
  }

  /// Calculate player's defense rating.
  /// From serverside.c: 100 - 5*bitches (hired help increases carrying capacity)
  /// For now, we use a base defense of 100
  int _calculatePlayerDefense(Player player) {
    const baseDefense = 100;
    // In future, could subtract penalties for hired help
    return baseDefense;
  }

  /// Calculate cop's defense rating.
  /// Base defense reduced by cop's defensive penalty
  int _calculateCopDefense(Cop cop) {
    const baseDefense = 100;
    return baseDefense - cop.defendPenalty;
  }

  /// Check if an attack hits.
  /// From serverside.c: hit if random(0, attack) > random(0, defense)
  bool _checkHit(int attackRating, int defenseRating) {
    final attackRoll = _random.nextInt(0, attackRating);
    final defenseRoll = _random.nextInt(0, defenseRating);
    return attackRoll > defenseRoll;
  }

  /// Calculate damage with armor reduction.
  /// From serverside.c: damage * 100 / armor
  int _calculateDamage({required int baseDamage, required int targetArmor}) {
    if (targetArmor <= 0) return baseDamage;
    return (baseDamage * 100) ~/ targetArmor;
  }
}

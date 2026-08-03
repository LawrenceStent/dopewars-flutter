import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/random_generator.dart';
import '../../../domain/combat/entities/cop.dart';
import '../../../domain/combat/entities/fight.dart';
import '../../../domain/combat/entities/gun.dart';
import '../../../domain/combat/services/damage_calculator.dart';
import '../../../domain/player/entities/player.dart';
import '../game/game_state.dart';

/// Cubit for managing combat state and actions.
class CombatCubit extends Cubit<CombatState> {
  final DamageCalculator _damageCalculator;
  final RandomGenerator _random;

  /// Callback when combat ends
  final void Function(Player updatedPlayer, bool won)? onCombatEnd;

  CombatCubit({
    required Fight initialFight,
    required DamageCalculator damageCalculator,
    required RandomGenerator random,
    this.onCombatEnd,
  })  : _damageCalculator = damageCalculator,
        _random = random,
        super(CombatState(
          opponentName: initialFight.cop.name,
          opponentHealth: initialFight.copHealth,
          deputyCount: initialFight.deputyCount,
          canShoot: initialFight.canShoot,
          canFlee: initialFight.canFlee,
          combatLog: initialFight.combatLog,
        )) {
    _currentFight = initialFight;
  }

  late Fight _currentFight;

  Fight get currentFight => _currentFight;

  /// Fire at the opponent
  void fire() {
    if (!state.canShoot || _currentFight.isOver) return;

    // Resolve one round of combat
    final round = _damageCalculator.resolveCombatRound(
      player: _currentFight.player,
      cop: _currentFight.cop,
      copDeputies: _currentFight.deputyCount,
      playerGun: _currentFight.playerGun,
    );

    // Apply round to fight
    var updatedFight = _currentFight.applyRound(round);

    // Check if cop is dead
    if (updatedFight.isCopDead) {
      updatedFight = updatedFight.copDies();
      _currentFight = updatedFight;
      emit(CombatState(
        opponentName: updatedFight.cop.name,
        opponentHealth: updatedFight.copHealth,
        deputyCount: updatedFight.deputyCount,
        canShoot: false,
        canFlee: false,
        combatLog: updatedFight.combatLog,
      ));
      // Notify game that combat ended in victory
      onCombatEnd?.call(updatedFight.player, true);
      return;
    }

    // Check if player is dead
    if (updatedFight.isPlayerDead) {
      updatedFight = updatedFight.playerDies();
      _currentFight = updatedFight;
      emit(CombatState(
        opponentName: updatedFight.cop.name,
        opponentHealth: updatedFight.copHealth,
        deputyCount: updatedFight.deputyCount,
        canShoot: false,
        canFlee: false,
        combatLog: updatedFight.combatLog,
      ));
      // Notify game that combat ended in defeat
      onCombatEnd?.call(updatedFight.player, false);
      return;
    }

    // Combat continues
    _currentFight = updatedFight;
    emit(CombatState(
      opponentName: updatedFight.cop.name,
      opponentHealth: updatedFight.copHealth,
      deputyCount: updatedFight.deputyCount,
      canShoot: updatedFight.canShoot,
      canFlee: updatedFight.canFlee,
      combatLog: updatedFight.combatLog,
    ));
  }

  /// Attempt to flee from combat
  void attemptFlee() {
    if (!state.canFlee || _currentFight.isOver) return;

    // Random chance to flee (50%)
    if (_random.nextInt(1, 100) <= 50) {
      var updatedFight = _currentFight.flee();
      _currentFight = updatedFight;
      emit(CombatState(
        opponentName: updatedFight.cop.name,
        opponentHealth: updatedFight.copHealth,
        deputyCount: updatedFight.deputyCount,
        canShoot: false,
        canFlee: false,
        combatLog: updatedFight.combatLog,
      ));
      // Notify game that player fled
      onCombatEnd?.call(updatedFight.player, false);
    } else {
      // Flee failed, continue combat with one more cop attack
      final round = _damageCalculator.resolveCombatRound(
        player: _currentFight.player,
        cop: _currentFight.cop,
        copDeputies: _currentFight.deputyCount,
        playerGun: _currentFight.playerGun,
      );

      var updatedFight = _currentFight.applyRound(round);

      // Check if cop died from the counterattack during failed flee
      if (updatedFight.isCopDead) {
        updatedFight = updatedFight.copDies();
        _currentFight = updatedFight;
        emit(CombatState(
          opponentName: updatedFight.cop.name,
          opponentHealth: updatedFight.copHealth,
          deputyCount: updatedFight.deputyCount,
          canShoot: false,
          canFlee: false,
          combatLog: updatedFight.combatLog,
        ));
        // Notify game that combat ended in victory (player defeated the cop)
        onCombatEnd?.call(updatedFight.player, true);
        return;
      }

      if (updatedFight.isPlayerDead) {
        updatedFight = updatedFight.playerDies();
        _currentFight = updatedFight;
        emit(CombatState(
          opponentName: updatedFight.cop.name,
          opponentHealth: updatedFight.copHealth,
          deputyCount: updatedFight.deputyCount,
          canShoot: false,
          canFlee: false,
          combatLog: updatedFight.combatLog,
        ));
        onCombatEnd?.call(updatedFight.player, false);
        return;
      }

      _currentFight = updatedFight;
      emit(CombatState(
        opponentName: updatedFight.cop.name,
        opponentHealth: updatedFight.copHealth,
        deputyCount: updatedFight.deputyCount,
        canShoot: updatedFight.canShoot,
        canFlee: updatedFight.canFlee,
        combatLog: updatedFight.combatLog,
      ));
    }
  }

  /// Get combat log messages
  List<String> getCombatLog() => _currentFight.combatLog;
}

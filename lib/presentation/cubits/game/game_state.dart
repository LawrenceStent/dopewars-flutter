import 'package:equatable/equatable.dart';

import '../../../domain/combat/entities/cop.dart';
import '../../../domain/combat/entities/gun.dart';
import '../../../domain/game/services/random_encounter_service.dart';
import '../../../domain/player/entities/player.dart';
import '../../../domain/scenario/entities/scenario.dart';
import '../../../domain/trading/entities/drug_market.dart';

/// Base class for all game states.
sealed class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

/// Initial state before game starts.
class GameInitial extends GameState {
  const GameInitial();
}

/// State while loading/initializing a new game.
class GameLoading extends GameState {
  const GameLoading();
}

/// Main gameplay state.
class GamePlaying extends GameState {
  final Player player;
  final DrugMarket currentMarket;
  final List<String> messages;

  const GamePlaying({
    required this.player,
    required this.currentMarket,
    this.messages = const [],
  });

  @override
  List<Object?> get props => [player, currentMarket, messages];

  /// Copy with updated values.
  GamePlaying copyWith({
    Player? player,
    DrugMarket? currentMarket,
    List<String>? messages,
  }) {
    return GamePlaying(
      player: player ?? this.player,
      currentMarket: currentMarket ?? this.currentMarket,
      messages: messages ?? this.messages,
    );
  }

  /// Add a message to the list.
  GamePlaying withMessage(String message) {
    return copyWith(messages: [...messages, message]);
  }

  /// Clear all messages.
  GamePlaying clearMessages() {
    return copyWith(messages: []);
  }
}

/// State when at a special location (bank, loan shark, etc.).
class GameAtLocation extends GameState {
  final Player player;
  final DrugMarket currentMarket;
  final SpecialLocation location;
  final List<String> messages;

  const GameAtLocation({
    required this.player,
    required this.currentMarket,
    required this.location,
    this.messages = const [],
  });

  @override
  List<Object?> get props => [player, currentMarket, location, messages];
}

/// Type of special location.
enum SpecialLocation {
  bank,
  loanShark,
  gunShop,
  roughPub,
}

/// State during combat.
class GameInCombat extends GameState {
  final Player player;
  final Cop cop;
  final Gun playerGun;
  final DrugMarket currentMarket;
  final CombatState combat;
  final List<String> messages;

  const GameInCombat({
    required this.player,
    required this.cop,
    required this.playerGun,
    required this.currentMarket,
    required this.combat,
    this.messages = const [],
  });

  @override
  List<Object?> get props => [player, cop, playerGun, currentMarket, combat, messages];
}

/// Combat state details.
class CombatState extends Equatable {
  final String opponentName;
  final int opponentHealth;
  final int deputyCount;
  final bool canShoot;
  final bool canFlee;
  final List<String> combatLog;

  const CombatState({
    required this.opponentName,
    required this.opponentHealth,
    required this.deputyCount,
    required this.canShoot,
    required this.canFlee,
    this.combatLog = const [],
  });

  @override
  List<Object?> get props => [
        opponentName,
        opponentHealth,
        deputyCount,
        canShoot,
        canFlee,
        combatLog,
      ];
}

/// State when game is over.
class GameOver extends GameState {
  final Player finalPlayer;
  final bool isDead;
  final String message;
  final bool isHighScore;

  const GameOver({
    required this.finalPlayer,
    required this.isDead,
    required this.message,
    this.isHighScore = false,
  });

  @override
  List<Object?> get props => [finalPlayer, isDead, message, isHighScore];
}

/// Error state.
class GameError extends GameState {
  final String message;

  const GameError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when a random event occurs (encounter during travel).
class EventOccurred extends GameState {
  final Player player;
  final EncounterResult encounter;
  final DrugMarket currentMarket;

  const EventOccurred({
    required this.player,
    required this.encounter,
    required this.currentMarket,
  });

  @override
  List<Object?> get props => [player, encounter, currentMarket];
}

/// State when a scenario (interactive event) occurs.
class ScenarioOccurred extends GameState {
  final Player player;
  final Scenario scenario;
  final DrugMarket currentMarket;

  const ScenarioOccurred({
    required this.player,
    required this.scenario,
    required this.currentMarket,
  });

  @override
  List<Object?> get props => [player, scenario, currentMarket];
}


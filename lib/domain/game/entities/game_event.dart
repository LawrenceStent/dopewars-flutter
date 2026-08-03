/// Game event codes representing different game states and events.
/// Ported from dopewars.h lines 129-140.
enum GameEvent {
  /// No event pending.
  none,

  /// Subway ride - hear a saying from a stranger.
  subway,

  /// Offered an object (drug or gun).
  offeredObject,

  /// Offered free weed.
  weed,

  /// Hear a saying.
  saying,

  /// At the loan shark.
  loanShark,

  /// At the bank.
  bank,

  /// At the gun shop.
  gunShop,

  /// At the rough pub.
  roughPub,

  /// Can hire a bitch.
  hireBitch,

  /// Arrived at new location.
  arrive,

  /// Game finished (end of turns or death).
  finish,

  /// In a fight.
  fight,

  /// Fight question (run or fight).
  fightAsk,

  /// At the doctor.
  doctor,

  /// Waiting for action to complete.
  waitDone,

  /// Out of sync (for multiplayer, not needed for single player).
  outOfSync,
}

/// Extension to provide additional functionality for GameEvent.
extension GameEventExtension on GameEvent {
  /// Check if this event requires user input.
  bool get requiresInput {
    switch (this) {
      case GameEvent.offeredObject:
      case GameEvent.weed:
      case GameEvent.loanShark:
      case GameEvent.bank:
      case GameEvent.gunShop:
      case GameEvent.roughPub:
      case GameEvent.hireBitch:
      case GameEvent.fightAsk:
      case GameEvent.doctor:
        return true;
      default:
        return false;
    }
  }

  /// Check if this event is a location-based event.
  bool get isLocationEvent {
    switch (this) {
      case GameEvent.loanShark:
      case GameEvent.bank:
      case GameEvent.gunShop:
      case GameEvent.roughPub:
        return true;
      default:
        return false;
    }
  }

  /// Check if this is a combat-related event.
  bool get isCombatEvent {
    switch (this) {
      case GameEvent.fight:
      case GameEvent.fightAsk:
        return true;
      default:
        return false;
    }
  }

  /// Check if this event blocks normal gameplay.
  bool get blocksGameplay {
    switch (this) {
      case GameEvent.none:
      case GameEvent.arrive:
        return false;
      default:
        return true;
    }
  }
}

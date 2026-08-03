/// Game constants ported from dopewars.c
/// These values define the core game balance and mechanics.
class GameConstants {
  GameConstants._();

  // Financial constants (from dopewars.c lines 108, 114)
  static const int startCash = 2000;
  static const int startDebt = 5500;
  static const int debtInterestPercent = 10; // 10% per turn
  static const int bankInterestPercent = 5; // 5% per turn

  // Game duration (from dopewars.c line 226)
  static const int numTurns = 31;

  // Player stats (from dopewars.c line 228)
  static const int playerArmor = 100;
  static const int bitchArmor = 50;
  static const int startHealth = 100;
  static const int startCoatSize = 100;

  // Special location indices (from dopewars.h lines 216-219)
  static const int defaultLoanSharkLoc = 1; // Ghetto
  static const int defaultBankLoc = 1; // Ghetto
  static const int defaultGunShopLoc = 2; // Central Park
  static const int defaultRoughPubLoc = 2; // Central Park

  // Prices for services (from dopewars.c lines 204-206)
  static const int spyPrice = 20000;
  static const int tipoffPrice = 10000;

  // Bitch prices (from dopewars.c lines 208-210)
  static const int bitchMinPrice = 50000;
  static const int bitchMaxPrice = 150000;
  static const int bitchHireCost = 10000; // Fixed cost per bitch hired
  static const int bitchCarryCapacity = 10; // Space each bitch adds to coat

  // Price modifiers for special deals (from dopewars.c line 755-756)
  static const int cheapDivide = 4;
  static const int expensiveMultiply = 4;

  // Combat constants
  static const int baseAttackRating = 80;
  static const int baseDefenseRating = 100;
  static const int bitchDefensePenalty = 5; // per bitch

  // Random encounter probabilities (from serverside.c)
  static const double muggedChance = 0.10;
  static const double friendChance = 0.30;
  static const double policeDogsChance = 0.50;
  static const double findBodyChance = 0.60;

  // Special deal chance per location
  static const double specialDealChance = 0.70;

  // High score list size (from dopewars.h line 214)
  static const int numHiScore = 18;

  // Start date (from dopewars.c lines 86-88)
  static const int startDay = 1;
  static const int startMonth = 12;
  static const int startYear = 1984;
}

import '../../../core/constants/game_constants.dart';
import '../../../core/value_objects/money.dart';

/// Service for calculating interest on debt and bank deposits.
/// Ported from serverside.c lines 464-467.
class InterestCalculator {
  final int debtInterestPercent;
  final int bankInterestPercent;

  const InterestCalculator({
    this.debtInterestPercent = GameConstants.debtInterestPercent,
    this.bankInterestPercent = GameConstants.bankInterestPercent,
  });

  /// Calculate debt after one turn of interest.
  /// Debt increases by 10% per turn.
  Money calculateDebtWithInterest(Money currentDebt) {
    if (currentDebt.isZeroOrNegative) {
      return Money.zero;
    }
    return currentDebt.applyInterest(debtInterestPercent);
  }

  /// Calculate bank balance after one turn of interest.
  /// Bank increases by 5% per turn.
  Money calculateBankWithInterest(Money currentBank) {
    if (currentBank.isZeroOrNegative) {
      return Money.zero;
    }
    return currentBank.applyInterest(bankInterestPercent);
  }

  /// Apply all end-of-turn interest calculations to player finances.
  /// Returns a tuple of (newDebt, newBank).
  ({Money debt, Money bank}) applyTurnInterest({
    required Money currentDebt,
    required Money currentBank,
  }) {
    return (
      debt: calculateDebtWithInterest(currentDebt),
      bank: calculateBankWithInterest(currentBank),
    );
  }
}

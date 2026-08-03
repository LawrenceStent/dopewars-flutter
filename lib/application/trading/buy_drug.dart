import '../../domain/player/entities/player.dart';
import '../../domain/trading/entities/drug.dart';
import '../../domain/trading/entities/drug_market.dart';
import 'trading_result.dart';

/// Use case for buying drugs from the market.
class BuyDrug {
  const BuyDrug();

  /// Execute the buy drug use case.
  ///
  /// [player] - The current player state
  /// [market] - The current drug market
  /// [drugType] - The type of drug to buy
  /// [quantity] - The quantity to buy
  ///
  /// Returns a [TradingResult] indicating success or failure.
  TradingResult execute({
    required Player player,
    required DrugMarket market,
    required DrugType drugType,
    required int quantity,
  }) {
    // Validate quantity
    if (quantity <= 0) {
      return const TradeFailure(
        error: TradeError.invalidQuantity,
        message: 'Quantity must be greater than zero.',
      );
    }

    // Check if drug is available at this market
    final priceInfo = market.getPrice(drugType);
    if (priceInfo == null) {
      return TradeFailure(
        error: TradeError.drugNotAvailable,
        message: '${DefaultDrugs.byType(drugType).name} is not available here.',
      );
    }

    // Calculate total cost
    final unitPrice = priceInfo.price;
    final totalCost = unitPrice * quantity;

    // Check if player can afford it
    if (totalCost > player.cash) {
      final maxAffordable = player.cash.dollars ~/ unitPrice.dollars;
      return TradeFailure(
        error: TradeError.insufficientFunds,
        message: maxAffordable > 0
            ? 'You can only afford $maxAffordable units.'
            : 'You can\'t afford any ${DefaultDrugs.byType(drugType).name}.',
      );
    }

    // Check if player has space
    if (!player.canCarry(quantity)) {
      final maxCarryable = player.availableSpace;
      return TradeFailure(
        error: TradeError.insufficientSpace,
        message: maxCarryable > 0
            ? 'You can only carry $maxCarryable more units.'
            : 'Your pockets are full!',
      );
    }

    // Execute the purchase
    final updatedPlayer = player
        .copyWith(cash: player.cash - totalCost)
        .addDrug(drugType, quantity, unitPrice);

    final drugName = DefaultDrugs.byType(drugType).name;
    return TradeSuccess(
      updatedPlayer: updatedPlayer,
      drugType: drugType,
      quantity: quantity,
      totalAmount: totalCost,
      message: 'You bought $quantity $drugName for $totalCost.',
    );
  }

  /// Calculate the maximum quantity that can be bought.
  int maxBuyable({
    required Player player,
    required DrugMarket market,
    required DrugType drugType,
  }) {
    final priceInfo = market.getPrice(drugType);
    if (priceInfo == null) return 0;

    final maxAffordable = player.cash.dollars ~/ priceInfo.price.dollars;
    final maxSpace = player.availableSpace;

    return maxAffordable < maxSpace ? maxAffordable : maxSpace;
  }
}

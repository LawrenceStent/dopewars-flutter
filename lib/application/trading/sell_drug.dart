import '../../core/value_objects/money.dart';
import '../../domain/player/entities/player.dart';
import '../../domain/trading/entities/drug.dart';
import '../../domain/trading/entities/drug_market.dart';
import 'trading_result.dart';

/// Use case for selling drugs to the market.
class SellDrug {
  const SellDrug();

  /// Execute the sell drug use case.
  ///
  /// [player] - The current player state
  /// [market] - The current drug market
  /// [drugType] - The type of drug to sell
  /// [quantity] - The quantity to sell
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

    // Check if drug is available at this market (someone to buy it)
    final priceInfo = market.getPrice(drugType);
    if (priceInfo == null) {
      return TradeFailure(
        error: TradeError.drugNotAvailable,
        message: 'Nobody\'s buying ${DefaultDrugs.byType(drugType).name} here.',
      );
    }

    // Check if player has enough to sell
    final inventory = player.getDrugInventory(drugType);
    if (inventory.carried < quantity) {
      return TradeFailure(
        error: TradeError.insufficientInventory,
        message: inventory.carried > 0
            ? 'You only have ${inventory.carried} to sell.'
            : 'You don\'t have any ${DefaultDrugs.byType(drugType).name} to sell.',
      );
    }

    // Calculate sale value and profit
    final unitPrice = priceInfo.price;
    final totalValue = unitPrice * quantity;
    final costBasis = inventory.price * quantity;
    final profit = totalValue - costBasis;

    // Execute the sale
    final updatedPlayer = player
        .copyWith(cash: player.cash + totalValue)
        .removeDrug(drugType, quantity);

    final drugName = DefaultDrugs.byType(drugType).name;
    final profitMessage = _getProfitMessage(profit, quantity == inventory.carried);

    return TradeSuccess(
      updatedPlayer: updatedPlayer,
      drugType: drugType,
      quantity: quantity,
      totalAmount: totalValue,
      profit: profit,
      message: 'You sold $quantity $drugName for $totalValue.$profitMessage',
    );
  }

  String _getProfitMessage(Money profit, bool soldAll) {
    if (!soldAll) return '';

    if (profit.isZeroOrNegative) {
      if (profit.dollars == 0) {
        return ' You broke even.';
      }
      return ' You lost ${profit.abs()} on the deal.';
    }
    return ' You made $profit profit!';
  }

  /// Calculate the maximum quantity that can be sold.
  int maxSellable({
    required Player player,
    required DrugMarket market,
    required DrugType drugType,
  }) {
    final priceInfo = market.getPrice(drugType);
    if (priceInfo == null) return 0;

    return player.getDrugInventory(drugType).carried;
  }
}

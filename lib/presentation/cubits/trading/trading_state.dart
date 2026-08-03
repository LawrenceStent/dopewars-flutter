import 'package:equatable/equatable.dart';

import '../../../application/trading/trading_result.dart';
import '../../../core/value_objects/money.dart';
import '../../../domain/player/entities/inventory.dart';
import '../../../domain/player/entities/player.dart';
import '../../../domain/trading/entities/drug.dart';
import '../../../domain/trading/entities/drug_market.dart';

/// State for the trading cubit.
class TradingState extends Equatable {
  final Player player;
  final DrugMarket market;
  final DrugType? selectedDrug;
  final TradeMode mode;
  final int quantity;
  final TradingResult? lastResult;
  final List<String> messages;

  const TradingState({
    required this.player,
    required this.market,
    this.selectedDrug,
    this.mode = TradeMode.none,
    this.quantity = 1,
    this.lastResult,
    this.messages = const [],
  });

  /// Get the price info for the selected drug.
  DrugPrice? get selectedDrugPrice =>
      selectedDrug != null ? market.getPrice(selectedDrug!) : null;

  /// Get the player's inventory for the selected drug.
  Inventory get selectedDrugInventory =>
      selectedDrug != null
          ? player.getDrugInventory(selectedDrug!)
          : Inventory.empty;

  /// Calculate total cost for current buy selection.
  Money get totalBuyCost {
    final price = selectedDrugPrice;
    if (price == null) return Money.zero;
    return price.price * quantity;
  }

  /// Calculate total value for current sell selection.
  Money get totalSellValue {
    final price = selectedDrugPrice;
    if (price == null) return Money.zero;
    return price.price * quantity;
  }

  /// Calculate max buyable for selected drug.
  int get maxBuyable {
    final price = selectedDrugPrice;
    if (price == null) return 0;
    final maxAffordable = player.cash.dollars ~/ price.price.dollars;
    final maxSpace = player.availableSpace;
    return maxAffordable < maxSpace ? maxAffordable : maxSpace;
  }

  /// Calculate max sellable for selected drug.
  int get maxSellable => selectedDrugInventory.carried;

  /// Check if current buy is valid.
  bool get canBuy =>
      mode == TradeMode.buy &&
      selectedDrug != null &&
      quantity > 0 &&
      quantity <= maxBuyable;

  /// Check if current sell is valid.
  bool get canSell =>
      mode == TradeMode.sell &&
      selectedDrug != null &&
      quantity > 0 &&
      quantity <= maxSellable;

  TradingState copyWith({
    Player? player,
    DrugMarket? market,
    DrugType? selectedDrug,
    bool clearSelectedDrug = false,
    TradeMode? mode,
    int? quantity,
    TradingResult? lastResult,
    bool clearLastResult = false,
    List<String>? messages,
  }) {
    return TradingState(
      player: player ?? this.player,
      market: market ?? this.market,
      selectedDrug: clearSelectedDrug ? null : (selectedDrug ?? this.selectedDrug),
      mode: mode ?? this.mode,
      quantity: quantity ?? this.quantity,
      lastResult: clearLastResult ? null : (lastResult ?? this.lastResult),
      messages: messages ?? this.messages,
    );
  }

  TradingState withMessage(String message) {
    return copyWith(messages: [...messages, message]);
  }

  TradingState clearMessages() {
    return copyWith(messages: []);
  }

  @override
  List<Object?> get props => [
        player,
        market,
        selectedDrug,
        mode,
        quantity,
        lastResult,
        messages,
      ];
}

/// Trading mode.
enum TradeMode {
  none,
  buy,
  sell,
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/trading/buy_drug.dart';
import '../../../application/trading/sell_drug.dart';
import '../../../application/trading/trading_result.dart';
import '../../../domain/player/entities/player.dart';
import '../../../domain/trading/entities/drug.dart';
import '../../../domain/trading/entities/drug_market.dart';
import 'trading_state.dart';

/// Cubit for managing trading operations.
class TradingCubit extends Cubit<TradingState> {
  final BuyDrug _buyDrug;
  final SellDrug _sellDrug;

  /// Callback to notify parent when player state changes.
  final void Function(Player updatedPlayer)? onPlayerUpdated;

  TradingCubit({
    required Player player,
    required DrugMarket market,
    BuyDrug? buyDrug,
    SellDrug? sellDrug,
    this.onPlayerUpdated,
  })  : _buyDrug = buyDrug ?? const BuyDrug(),
        _sellDrug = sellDrug ?? const SellDrug(),
        super(TradingState(player: player, market: market));

  /// Update player and market state (called when game state changes).
  void updateState({Player? player, DrugMarket? market}) {
    emit(state.copyWith(
      player: player,
      market: market,
      clearLastResult: true,
    ));
  }

  /// Select a drug for trading.
  void selectDrug(DrugType drugType) {
    emit(state.copyWith(
      selectedDrug: drugType,
      quantity: 1,
      clearLastResult: true,
    ));
  }

  /// Clear drug selection.
  void clearSelection() {
    emit(state.copyWith(
      clearSelectedDrug: true,
      mode: TradeMode.none,
      quantity: 1,
      clearLastResult: true,
    ));
  }

  /// Set trading mode.
  void setMode(TradeMode mode) {
    int newQuantity = 1;

    // Set initial quantity based on mode
    if (mode == TradeMode.buy && state.maxBuyable > 0) {
      newQuantity = 1;
    } else if (mode == TradeMode.sell && state.maxSellable > 0) {
      newQuantity = 1;
    }

    emit(state.copyWith(
      mode: mode,
      quantity: newQuantity,
      clearLastResult: true,
    ));
  }

  /// Set quantity for trade.
  void setQuantity(int quantity) {
    final maxQty = state.mode == TradeMode.buy
        ? state.maxBuyable
        : state.maxSellable;

    final clampedQty = quantity.clamp(0, maxQty);
    emit(state.copyWith(quantity: clampedQty));
  }

  /// Increment quantity.
  void incrementQuantity([int amount = 1]) {
    setQuantity(state.quantity + amount);
  }

  /// Decrement quantity.
  void decrementQuantity([int amount = 1]) {
    setQuantity(state.quantity - amount);
  }

  /// Set quantity to max.
  void setMaxQuantity() {
    final maxQty = state.mode == TradeMode.buy
        ? state.maxBuyable
        : state.maxSellable;
    setQuantity(maxQty);
  }

  /// Execute buy for selected drug.
  void executeBuy() {
    if (state.selectedDrug == null || state.quantity <= 0) return;

    final result = _buyDrug.execute(
      player: state.player,
      market: state.market,
      drugType: state.selectedDrug!,
      quantity: state.quantity,
    );

    _handleResult(result);
  }

  /// Execute sell for selected drug.
  void executeSell() {
    if (state.selectedDrug == null || state.quantity <= 0) return;

    final result = _sellDrug.execute(
      player: state.player,
      market: state.market,
      drugType: state.selectedDrug!,
      quantity: state.quantity,
    );

    _handleResult(result);
  }

  /// Execute current trade (buy or sell based on mode).
  void executeTrade() {
    switch (state.mode) {
      case TradeMode.buy:
        executeBuy();
        break;
      case TradeMode.sell:
        executeSell();
        break;
      case TradeMode.none:
        break;
    }
  }

  /// Quick buy: select drug, set quantity, and buy in one action.
  void quickBuy(DrugType drugType, int quantity) {
    final result = _buyDrug.execute(
      player: state.player,
      market: state.market,
      drugType: drugType,
      quantity: quantity,
    );

    _handleResult(result);
  }

  /// Quick sell: select drug, set quantity, and sell in one action.
  void quickSell(DrugType drugType, int quantity) {
    final result = _sellDrug.execute(
      player: state.player,
      market: state.market,
      drugType: drugType,
      quantity: quantity,
    );

    _handleResult(result);
  }

  void _handleResult(TradingResult result) {
    if (result is TradeSuccess) {
      // Notify parent of player update
      onPlayerUpdated?.call(result.updatedPlayer);

      emit(state.copyWith(
        player: result.updatedPlayer,
        lastResult: result,
        messages: [result.message],
        // Reset selection after successful trade
        clearSelectedDrug: true,
        mode: TradeMode.none,
        quantity: 1,
      ));
    } else if (result is TradeFailure) {
      emit(state.copyWith(
        lastResult: result,
        messages: [result.message],
      ));
    }
  }

  /// Clear messages.
  void clearMessages() {
    emit(state.clearMessages());
  }

  /// Get available drugs sorted by price.
  List<DrugType> getAvailableDrugsSortedByPrice({bool ascending = true}) {
    final available = state.market.availableDrugs;
    available.sort((a, b) {
      final priceA = state.market.getPrice(a)?.price.dollars ?? 0;
      final priceB = state.market.getPrice(b)?.price.dollars ?? 0;
      return ascending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });
    return available;
  }

  /// Get player's drugs with inventory.
  List<DrugType> getPlayerDrugsWithInventory() {
    return state.player.drugs.keys
        .where((type) => state.player.getDrugInventory(type).carried > 0)
        .toList();
  }
}

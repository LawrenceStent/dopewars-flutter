import 'package:equatable/equatable.dart';

import '../../core/value_objects/money.dart';
import '../../domain/player/entities/player.dart';
import '../../domain/trading/entities/drug.dart';

/// Result of a trading operation.
sealed class TradingResult extends Equatable {
  const TradingResult();

  @override
  List<Object?> get props => [];
}

/// Successful trade result.
class TradeSuccess extends TradingResult {
  final Player updatedPlayer;
  final DrugType drugType;
  final int quantity;
  final Money totalAmount;
  final Money? profit;
  final String message;

  const TradeSuccess({
    required this.updatedPlayer,
    required this.drugType,
    required this.quantity,
    required this.totalAmount,
    this.profit,
    required this.message,
  });

  @override
  List<Object?> get props => [
        updatedPlayer,
        drugType,
        quantity,
        totalAmount,
        profit,
        message,
      ];
}

/// Failed trade result.
class TradeFailure extends TradingResult {
  final TradeError error;
  final String message;

  const TradeFailure({
    required this.error,
    required this.message,
  });

  @override
  List<Object?> get props => [error, message];
}

/// Types of trading errors.
enum TradeError {
  drugNotAvailable,
  insufficientFunds,
  insufficientSpace,
  insufficientInventory,
  invalidQuantity,
}

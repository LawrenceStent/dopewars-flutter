import 'package:equatable/equatable.dart';

import '../../../core/value_objects/money.dart';

/// Represents inventory of a single item type (drug or gun).
/// Ported from struct INVENTORY in dopewars.h lines 269-273.
class Inventory extends Equatable {
  /// Average purchase price per unit (for profit calculation).
  final Money price;

  /// Total value of all carried items at purchase price.
  final Money totalValue;

  /// Number of items carried.
  final int carried;

  const Inventory({
    required this.price,
    required this.totalValue,
    required this.carried,
  });

  /// Empty inventory.
  static const Inventory empty = Inventory(
    price: Money.zero,
    totalValue: Money.zero,
    carried: 0,
  );

  /// Check if inventory is empty.
  bool get isEmpty => carried == 0;

  /// Check if inventory has items.
  bool get hasItems => carried > 0;

  /// Add items to inventory.
  /// Updates the average price and total value.
  Inventory add(int quantity, Money unitPrice) {
    if (quantity <= 0) return this;

    final purchaseValue = unitPrice * quantity;
    final newCarried = carried + quantity;
    final newTotalValue = totalValue + purchaseValue;
    // Calculate weighted average price
    final newPrice =
        newCarried > 0 ? newTotalValue.integerDivide(newCarried) : Money.zero;

    return Inventory(
      price: newPrice,
      totalValue: newTotalValue,
      carried: newCarried,
    );
  }

  /// Remove items from inventory.
  /// Reduces total value proportionally.
  Inventory remove(int quantity) {
    if (quantity <= 0) return this;
    if (quantity > carried) {
      throw ArgumentError('Cannot remove $quantity items, only $carried available');
    }

    final newCarried = carried - quantity;
    if (newCarried == 0) {
      return Inventory.empty;
    }

    // Reduce total value proportionally
    final removedValue = price * quantity;
    final newTotalValue = totalValue - removedValue;

    return Inventory(
      price: price, // Average price stays the same
      totalValue: newTotalValue,
      carried: newCarried,
    );
  }

  /// Calculate profit if selling at given price.
  Money profitAt(Money salePrice) {
    if (isEmpty) return Money.zero;
    return (salePrice - price) * carried;
  }

  /// Calculate total sale value at given price.
  Money saleValueAt(Money salePrice) {
    return salePrice * carried;
  }

  @override
  List<Object?> get props => [price, totalValue, carried];

  @override
  String toString() => 'Inventory(carried: $carried, avgPrice: $price)';
}

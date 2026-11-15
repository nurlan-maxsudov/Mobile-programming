import '../models/cart.dart';

// Part 5: Events name actions and help trace transitions or control concurrency.
// They are useful for duplicate checkout handling but extra code for a simple +.
// The sealed type lets a switch check that every event case is covered.
sealed class CartEvent {
  const CartEvent();
  @override
  String toString() => '$runtimeType';
}

final class CartProductAdded extends CartEvent {
  const CartProductAdded(this.product);
  final Product product;
  @override
  String toString() => 'CartProductAdded(${product.id})';
}

final class CartProductRemoved extends CartEvent {
  const CartProductRemoved(this.productId);
  final String productId;
}

final class CartQtyChanged extends CartEvent {
  const CartQtyChanged(this.productId, this.delta);
  final String productId;
  final int delta;
  @override
  String toString() => 'CartQtyChanged($productId, $delta)';
}

final class CartCouponApplied extends CartEvent {
  const CartCouponApplied(this.code);
  final String code;
  @override
  String toString() => 'CartCouponApplied($code)';
}

final class CartCheckoutRequested extends CartEvent {
  const CartCheckoutRequested();
}

final class CartUndone extends CartEvent {
  const CartUndone();
}

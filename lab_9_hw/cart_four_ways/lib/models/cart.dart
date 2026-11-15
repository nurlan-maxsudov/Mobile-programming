import 'package:flutter/foundation.dart';

class Product {
  const Product({required this.id, required this.name, required this.price});
  final String id;
  final String name;
  final double price;

  @override
  bool operator ==(Object other) =>
      other is Product &&
      id == other.id &&
      name == other.name &&
      price == other.price;
  @override
  int get hashCode => Object.hash(id, name, price);
}

const catalog = [
  Product(id: 'p1', name: 'Keyboard', price: 49),
  Product(id: 'p2', name: 'Mouse', price: 25),
  Product(id: 'p3', name: 'Monitor', price: 199),
];

// Part 1: Immutable lines and copyWith preserve previous states for Undo.
// setState can rebuild after mutation, but mutation corrupts saved history
// and other styles may skip notifications for the same object.
class CartLine {
  const CartLine({required this.product, required this.qty});
  final Product product;
  final int qty;
  double get subtotal => product.price * qty;
  CartLine copyWith({int? qty}) =>
      CartLine(product: product, qty: qty ?? this.qty);

  @override
  bool operator ==(Object other) =>
      other is CartLine && product == other.product && qty == other.qty;
  @override
  int get hashCode => Object.hash(product, qty);
}

extension CartLines on List<CartLine> {
  List<CartLine> withProduct(Product p) {
    final i = indexWhere((l) => l.product.id == p.id);
    if (i == -1) return [...this, CartLine(product: p, qty: 1)];
    return [
      for (final l in this)
        l.product.id == p.id ? l.copyWith(qty: l.qty + 1) : l,
    ];
  }

  List<CartLine> without(String productId) => [
    for (final l in this)
      if (l.product.id != productId) l,
  ];
  List<CartLine> changeQty(String id, int delta) => [
    for (final l in this)
      if (l.product.id != id)
        l
      else if (l.qty + delta > 0)
        l.copyWith(qty: l.qty + delta),
  ];
  double get subtotal => fold(0, (s, l) => s + l.subtotal);
  int get itemCount => fold(0, (s, l) => s + l.qty);
}

enum CheckoutStatus { idle, submitting, success, failure }

class CartState {
  CartState({
    List<CartLine> lines = const [],
    this.coupon = '',
    this.couponError = '',
    this.status = CheckoutStatus.idle,
    this.orderId = '',
    this.checkoutError = '',
    this.canUndo = false,
    List<CartState> history = const [],
  }) : lines = List.unmodifiable(lines),
       history = List.unmodifiable(history);

  final List<CartLine> lines;
  final String coupon;
  final String couponError;
  final CheckoutStatus status;
  final String orderId;
  final String checkoutError;
  final bool canUndo;
  // Only Bloc keeps its undo snapshots here. Other styles use a private list.
  final List<CartState> history;

  // T3: Calculate totals from items and the coupon instead of storing them.
  // A stored total could become outdated after a quantity change, coupon or Undo.
  int get itemCount => lines.itemCount;
  double get subtotal => lines.subtotal;
  double get discount => coupon == 'SAVE10' ? subtotal * 0.10 : 0;
  double get total => subtotal - discount;

  CartState copyWith({
    List<CartLine>? lines,
    String? coupon,
    String? couponError,
    CheckoutStatus? status,
    String? orderId,
    String? checkoutError,
    bool? canUndo,
    List<CartState>? history,
  }) => CartState(
    lines: lines ?? this.lines,
    coupon: coupon ?? this.coupon,
    couponError: couponError ?? this.couponError,
    status: status ?? this.status,
    orderId: orderId ?? this.orderId,
    checkoutError: checkoutError ?? this.checkoutError,
    canUndo: canUndo ?? this.canUndo,
    history: history ?? this.history,
  );

  CartState withLines(List<CartLine> value) => copyWith(
    lines: value,
    status: CheckoutStatus.idle,
    orderId: '',
    checkoutError: '',
  );

  CartState withCoupon(String code) => copyWith(
    coupon: code == 'SAVE10' ? code : '',
    couponError: code == 'SAVE10' ? '' : 'Invalid coupon code',
    status: CheckoutStatus.idle,
    orderId: '',
    checkoutError: '',
  );

  // Checkpoint 4: Equal states skip unnecessary notifications and rebuilds.
  // Keep state and lists immutable, with matching value-based ==/hashCode.
  // Equivalent coupon states then compare equal instead of causing extra updates.
  @override
  bool operator ==(Object other) =>
      other is CartState &&
      listEquals(lines, other.lines) &&
      coupon == other.coupon &&
      couponError == other.couponError &&
      status == other.status &&
      orderId == other.orderId &&
      checkoutError == other.checkoutError &&
      canUndo == other.canUndo &&
      listEquals(history, other.history);
  @override
  int get hashCode => Object.hash(
    Object.hashAll(lines),
    coupon,
    couponError,
    status,
    orderId,
    checkoutError,
    canUndo,
    Object.hashAll(history),
  );
  @override
  String toString() =>
      'CartState(items: $itemCount, coupon: $coupon, '
      'couponError: $couponError, total: $total, status: ${status.name}, '
      'orderId: $orderId, checkoutError: $checkoutError, canUndo: $canUndo)';
}

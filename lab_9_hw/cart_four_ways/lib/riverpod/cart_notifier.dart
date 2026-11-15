import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart.dart';
import '../services/checkout_api.dart';

final checkoutApiProvider = Provider((ref) => CheckoutApi());
final cartProvider = NotifierProvider.autoDispose<CartNotifier, CartState>(
  CartNotifier.new,
);
final canUndoProvider = Provider.autoDispose(
  (ref) => ref.watch(cartProvider).canUndo,
);

class CartNotifier extends Notifier<CartState> {
  final _history = <CartState>[];

  @override
  CartState build() {
    _history.clear();
    return CartState();
  }

  void _change(CartState next) {
    if (state.status == CheckoutStatus.submitting || next == state) return;
    _history.add(state);
    state = next.copyWith(canUndo: true);
  }

  void add(Product p) => _change(state.withLines(state.lines.withProduct(p)));
  void changeQty(String id, int delta) =>
      _change(state.withLines(state.lines.changeQty(id, delta)));
  void applyCoupon(String code) => _change(state.withCoupon(code));

  void undo() {
    if (_history.isEmpty || state.status == CheckoutStatus.submitting) return;
    state = _history.removeLast().copyWith(canUndo: _history.isNotEmpty);
  }

  Future<void> checkout() async {
    if (state.lines.isEmpty || state.status == CheckoutStatus.submitting) {
      return;
    }
    final before = state;
    final api = ref.read(checkoutApiProvider);
    state = state.copyWith(
      status: CheckoutStatus.submitting,
      orderId: '',
      checkoutError: '',
    );
    try {
      final id = await api.submit(before.total);
      // Riverpod 3: autoDispose can destroy the notifier while awaiting.
      if (!ref.mounted) return;
      _history.add(before);
      state = CartState(
        status: CheckoutStatus.success,
        orderId: id,
        canUndo: true,
      );
    } on CheckoutException catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        status: CheckoutStatus.failure,
        checkoutError: e.message,
      );
    }
  }
}

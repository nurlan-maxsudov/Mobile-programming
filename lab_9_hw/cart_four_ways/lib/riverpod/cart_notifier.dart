import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart.dart';
import '../services/checkout_api.dart';

final checkoutApiProvider = Provider((ref) => CheckoutApi());
// Part 3 T5 / checkpoint 1: State lives in the provider container.
// autoDispose discards the cart and private history after listeners disappear.
// Popping the page and returning therefore creates an empty cart.
final cartProvider = NotifierProvider.autoDispose<CartNotifier, CartState>(
  CartNotifier.new,
);
// T5: Watch cart state so Undo availability updates when state changes.
// Reading only the notifier or its private history would not subscribe.
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

  // Checkpoint 2: Public notifier methods update the cart by assigning state.
  // Equal values do not need another notification or Undo entry.
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
    // Part 3: read obtains the API once for this action without subscribing.
    // Tests can override this provider with a mock API.
    final api = ref.read(checkoutApiProvider);
    state = state.copyWith(
      status: CheckoutStatus.submitting,
      orderId: '',
      checkoutError: '',
    );
    try {
      final id = await api.submit(before.total);
      // T4 / checkpoint 5: A persistent provider needs no widget-mounted guard.
      // Our autoDispose provider can die during await, so Riverpod 3 needs ref.mounted.
      // This checks the provider lifecycle, not the widget lifecycle.
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

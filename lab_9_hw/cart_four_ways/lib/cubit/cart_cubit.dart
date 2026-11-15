import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/cart.dart';
import '../services/checkout_api.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(this._api) : super(CartState());
  final CheckoutApi _api;
  final _history = <CartState>[];

  void _change(CartState next) {
    if (state.status == CheckoutStatus.submitting) return;
    if (next == state) {
      emit(next); // Equal states are dropped: onChange will not run again.
      return;
    }
    _history.add(state);
    emit(next.copyWith(canUndo: true));
  }

  void add(Product p) => _change(state.withLines(state.lines.withProduct(p)));
  void changeQty(String id, int delta) =>
      _change(state.withLines(state.lines.changeQty(id, delta)));
  void applyCoupon(String code) => _change(state.withCoupon(code));

  void undo() {
    if (_history.isEmpty || state.status == CheckoutStatus.submitting) return;
    emit(_history.removeLast().copyWith(canUndo: _history.isNotEmpty));
  }

  Future<void> checkout() async {
    if (state.lines.isEmpty || state.status == CheckoutStatus.submitting) {
      return;
    }
    final before = state;
    emit(
      state.copyWith(
        status: CheckoutStatus.submitting,
        orderId: '',
        checkoutError: '',
      ),
    );
    try {
      final id = await _api.submit(before.total);
      if (isClosed) return;
      _history.add(before);
      emit(
        CartState(status: CheckoutStatus.success, orderId: id, canUndo: true),
      );
    } on CheckoutException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          checkoutError: e.message,
        ),
      );
    }
  }

  @override
  void onChange(Change<CartState> change) {
    debugPrint('Cubit: $change');
    super.onChange(change);
  }
}

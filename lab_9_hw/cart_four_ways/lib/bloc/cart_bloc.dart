import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import '../models/cart.dart';
import '../services/checkout_api.dart';
import 'cart_event.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc(this._api) : super(CartState()) {
    on<CartProductAdded>(
      (event, emit) => _change(
        event,
        state.withLines(state.lines.withProduct(event.product)),
        emit,
      ),
    );
    on<CartProductRemoved>(
      (event, emit) => _change(
        event,
        state.withLines(state.lines.without(event.productId)),
        emit,
      ),
    );
    on<CartQtyChanged>(
      (event, emit) => _change(
        event,
        state.withLines(state.lines.changeQty(event.productId, event.delta)),
        emit,
      ),
    );
    on<CartCouponApplied>(
      (event, emit) => _change(event, state.withCoupon(event.code), emit),
    );
    on<CartUndone>((event, emit) {
      if (state.history.isEmpty || state.status == CheckoutStatus.submitting) {
        return;
      }
      final history = [...state.history]..removeLast();
      emit(
        state.history.last.copyWith(
          history: history,
          canUndo: history.isNotEmpty,
        ),
      );
    });
    on<CartCheckoutRequested>(_checkout, transformer: droppable());
  }

  final CheckoutApi _api;

  bool _isUndoable(CartEvent event) => switch (event) {
    CartProductAdded() ||
    CartProductRemoved() ||
    CartQtyChanged() ||
    CartCouponApplied() => true,
    CartCheckoutRequested() || CartUndone() => false,
  };

  void _change(CartEvent event, CartState next, Emitter<CartState> emit) {
    if (state.status == CheckoutStatus.submitting || next == state) return;
    if (_isUndoable(event)) {
      // Strip nested history so each entry is just a cart snapshot.
      final snapshot = state.copyWith(history: const [], canUndo: false);
      next = next.copyWith(
        history: [...state.history, snapshot],
        canUndo: true,
      );
    }
    emit(next);
  }

  Future<void> _checkout(
    CartCheckoutRequested event,
    Emitter<CartState> emit,
  ) async {
    if (state.lines.isEmpty) return;
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
      if (emit.isDone) return;
      // Clearing the cart is undoable; submitting/failure status changes are not.
      final snapshot = before.copyWith(history: const [], canUndo: false);
      emit(
        CartState(
          status: CheckoutStatus.success,
          orderId: id,
          history: [...before.history, snapshot],
          canUndo: true,
        ),
      );
    } on CheckoutException catch (e) {
      if (emit.isDone) return;
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          checkoutError: e.message,
        ),
      );
    }
  }
}

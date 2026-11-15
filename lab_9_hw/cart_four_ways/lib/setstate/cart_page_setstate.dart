import 'package:flutter/material.dart';

import '../models/cart.dart';
import '../services/checkout_api.dart';
import '../widgets/cart_body.dart';

class SetStateCartPage extends StatefulWidget {
  const SetStateCartPage({super.key});
  @override
  State<SetStateCartPage> createState() => _SetStateCartPageState();
}

class _SetStateCartPageState extends State<SetStateCartPage> {
  // Part 2 / checkpoint 1: This page owns state and discards it on disposal.
  // For another page to read the cart, lift state to a common ancestor
  // and pass callbacks, or use a shared state holder.
  CartState _state = CartState();
  // T5: History lives in this State object; normal hot reload preserves it.
  // Hot restart or leaving the page discards it, so returning starts fresh.
  final _history = <CartState>[];
  final _api = CheckoutApi();

  // Checkpoints 2-3: There is no separate state-holder mutation API here.
  // Page callbacks call setState to rebuild and pass fresh data to children.
  // Save history before cart edits, not before checkout status changes.
  void _change(CartState next) {
    if (_state.status == CheckoutStatus.submitting || next == _state) return;
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    setState(() {
      _history.add(_state);
      _state = next.copyWith(canUndo: true);
    });
  }

  void _add(Product p) =>
      _change(_state.withLines(_state.lines.withProduct(p)));
  void _changeQty(String id, int delta) =>
      _change(_state.withLines(_state.lines.changeQty(id, delta)));
  void _applyCoupon(String code) => _change(_state.withCoupon(code));

  void _undo() {
    if (_history.isEmpty || _state.status == CheckoutStatus.submitting) return;
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    setState(() {
      _state = _history.removeLast().copyWith(canUndo: _history.isNotEmpty);
    });
  }

  Future<void> _checkout() async {
    if (_state.lines.isEmpty || _state.status == CheckoutStatus.submitting) {
      return;
    }
    final before = _state;
    setState(
      () => _state = _state.copyWith(
        status: CheckoutStatus.submitting,
        orderId: '',
        checkoutError: '',
      ),
    );
    try {
      // T4 / checkpoint 5: The user can leave while checkout awaits.
      // The mounted guard prevents setState after disposal and invalid context use.
      final id = await _api.submit(before.total);
      if (!mounted) return;
      setState(() {
        _history.add(before);
        _state = CartState(
          status: CheckoutStatus.success,
          orderId: id,
          canUndo: true,
        );
      });
    } on CheckoutException catch (e) {
      if (!mounted) return;
      setState(
        () => _state = _state.copyWith(
          status: CheckoutStatus.failure,
          checkoutError: e.message,
        ),
      );
    }
    if (!mounted) return;
    showCheckoutMessage(context, _state);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Cart · setState'),
      actions: [
        TextButton(
          onPressed:
              _state.canUndo && _state.status != CheckoutStatus.submitting
              ? _undo
              : null,
          child: const Text('Undo'),
        ),
      ],
    ),
    body: CartBody(
      state: _state,
      onAdd: _add,
      onQtyChanged: _changeQty,
      onApplyCoupon: _applyCoupon,
      onCheckout: _checkout,
    ),
  );
}

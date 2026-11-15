import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/cart_body.dart';
import '../models/cart.dart';
import 'cart_notifier.dart';

class RiverpodCartPage extends ConsumerWidget {
  const RiverpodCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartProvider);
    final cart = ref.read(cartProvider.notifier);
    final canUndo = ref.watch(canUndoProvider);
    ref.listen(cartProvider, (previous, next) => debugPrint('Riverpod: $next'));
    ref.listen(cartProvider.select((s) => s.status), (previous, next) {
      showCheckoutMessage(context, ref.read(cartProvider));
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart · Riverpod'),
        actions: [
          TextButton(
            onPressed: canUndo && state.status != CheckoutStatus.submitting
                ? cart.undo
                : null,
            child: const Text('Undo'),
          ),
        ],
      ),
      body: CartBody(
        state: state,
        onAdd: cart.add,
        onQtyChanged: cart.changeQty,
        onApplyCoupon: cart.applyCoupon,
        onCheckout: cart.checkout,
        summary: const RiverpodCartSummary(),
      ),
    );
  }
}

class RiverpodCartSummary extends ConsumerWidget {
  const RiverpodCartSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(cartProvider.select((s) => s.total));
    // Watch the other displayed values too, even if a change leaves total equal.
    ref.watch(
      cartProvider.select((s) => (s.itemCount, s.subtotal, s.discount)),
    );
    debugPrint('Riverpod summary build');
    return CartSummary(state: ref.read(cartProvider));
  }
}

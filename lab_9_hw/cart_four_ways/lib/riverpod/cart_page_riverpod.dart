import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/cart_body.dart';
import '../models/cart.dart';
import 'cart_notifier.dart';

class RiverpodCartPage extends ConsumerWidget {
  const RiverpodCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Part 3 / checkpoint 3: watch subscribes to displayed cart and Undo values.
    // read gets the notifier for method calls without subscribing.
    // Using read alone for displayed data would miss later updates.
    final state = ref.watch(cartProvider);
    final cart = ref.read(cartProvider.notifier);
    final canUndo = ref.watch(canUndoProvider);
    // T2: Applying the same coupon twice produces equal state, so no second log.
    // Without value equality, separate objects would normally compare unequal.
    ref.listen(cartProvider, (previous, next) => debugPrint('Riverpod: $next'));
    // Part 3: listen runs messages as side effects when checkout status changes.
    // read inside the listener fetches current state once; build only renders UI.
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
    // T3: select rebuilds this summary only when its displayed values change.
    // Unlike rebuilding the setState page, status-only changes do not rebuild it.
    // Typing is local to the TextField and does not mutate any cart.
    ref.watch(cartProvider.select((s) => s.total));
    // Watch the other displayed values too, even if a change leaves total equal.
    ref.watch(
      cartProvider.select((s) => (s.itemCount, s.subtotal, s.discount)),
    );
    debugPrint('Riverpod summary build');
    return CartSummary(state: ref.read(cartProvider));
  }
}

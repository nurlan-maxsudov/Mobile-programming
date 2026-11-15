import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/cart.dart';
import '../services/checkout_api.dart';
import '../widgets/cart_body.dart';
import 'cart_cubit.dart';

class CubitCartPage extends StatelessWidget {
  const CubitCartPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    // Part 4 / checkpoint 1: This provider owns and closes the page-scoped Cubit.
    // Inside CartBody it would be below the page context, so the page could not
    // read it to supply CartBody with state and callbacks.
    create: (_) => CartCubit(CheckoutApi()),
    // Part 4 / checkpoint 3: BlocProvider maps to ProviderScope plus a provider;
    // BlocListener maps to ref.listen, and BlocBuilder maps to ref.watch.
    // context.read maps to ref.read; buildWhen/BlocSelector map to select.
    child: BlocListener<CartCubit, CartState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: showCheckoutMessage,
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          final cart = context.read<CartCubit>();
          return Scaffold(
            appBar: AppBar(
              title: const Text('Cart · Cubit'),
              actions: [
                TextButton(
                  onPressed:
                      state.canUndo && state.status != CheckoutStatus.submitting
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
              summary: const BlocCartSummary<CartCubit>(),
            ),
          );
        },
      ),
    ),
  );
}

// Reused by the Bloc page by changing just the state-holder type.
class BlocCartSummary<B extends StateStreamable<CartState>>
    extends StatelessWidget {
  const BlocCartSummary({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<B, CartState>(
    // T3: Rebuild for displayed values, not typing or checkout status.
    // Check every displayed value because different carts can have the same total.
    buildWhen: (p, c) =>
        p.total != c.total ||
        p.itemCount != c.itemCount ||
        p.subtotal != c.subtotal ||
        p.discount != c.discount,
    builder: (context, state) {
      debugPrint('$B summary build');
      return CartSummary(state: state);
    },
  );
}

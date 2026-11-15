import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/cart.dart';
import '../services/checkout_api.dart';
import '../widgets/cart_body.dart';
import '../cubit/cart_page_cubit.dart';
import 'cart_bloc.dart';
import 'cart_event.dart';

class BlocCartPage extends StatelessWidget {
  const BlocCartPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    // Checkpoint 1: This Bloc lives in a page-scoped BlocProvider.
    // Leaving the page closes it and discards its cart and history.
    create: (_) => CartBloc(CheckoutApi()),
    child: BlocListener<CartBloc, CartState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: showCheckoutMessage,
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final cart = context.read<CartBloc>();
          return Scaffold(
            appBar: AppBar(
              title: const Text('Cart · Bloc'),
              actions: [
                TextButton(
                  onPressed:
                      state.canUndo && state.status != CheckoutStatus.submitting
                      ? () => cart.add(const CartUndone())
                      : null,
                  child: const Text('Undo'),
                ),
              ],
            ),
            body: CartBody(
              state: state,
              // Checkpoint 2: The UI changes Bloc state only through add(event).
              // Handlers emit results; Cubit and Notifier instead expose action methods.
              onAdd: (p) => cart.add(CartProductAdded(p)),
              onQtyChanged: (id, delta) => cart.add(CartQtyChanged(id, delta)),
              onApplyCoupon: (code) => cart.add(CartCouponApplied(code)),
              onCheckout: () => cart.add(const CartCheckoutRequested()),
              summary: const BlocCartSummary<CartBloc>(),
            ),
          );
        },
      ),
    ),
  );
}

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
    create: (_) => CartCubit(CheckoutApi()),
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

import 'package:flutter/material.dart';

import '../models/cart.dart';

// The only local state is the text being typed. Cart state comes from the page.
// Part 1: Callbacks let all four styles reuse this UI without provider imports.
// Only the unfinished text is local; the page/state holder owns the applied coupon.
class CartBody extends StatefulWidget {
  const CartBody({
    super.key,
    required this.state,
    required this.onAdd,
    required this.onQtyChanged,
    required this.onApplyCoupon,
    required this.onCheckout,
    this.summary,
  });
  final CartState state;
  final void Function(Product) onAdd;
  final void Function(String id, int delta) onQtyChanged;
  final void Function(String code) onApplyCoupon;
  final VoidCallback onCheckout;
  final Widget? summary;

  @override
  State<CartBody> createState() => _CartBodyState();
}

class _CartBodyState extends State<CartBody> {
  final _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final busy = state.status == CheckoutStatus.submitting;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              children: [
                for (final p in catalog)
                  ActionChip(
                    label: Text('${p.name} · ${p.price.toStringAsFixed(0)}'),
                    onPressed: busy ? null : () => widget.onAdd(p),
                  ),
              ],
            ),
          ),
          Expanded(
            child: state.lines.isEmpty
                ? const Center(child: Text('Cart is empty'))
                : ListView(
                    children: [
                      for (final l in state.lines)
                        ListTile(
                          key: ValueKey(l.product.id),
                          title: Text(l.product.name),
                          subtitle: Text('× ${l.qty}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Decrease ${l.product.name}',
                                icon: const Icon(Icons.remove),
                                onPressed: busy
                                    ? null
                                    : () =>
                                          widget.onQtyChanged(l.product.id, -1),
                              ),
                              Text('${l.qty}'),
                              IconButton(
                                tooltip: 'Increase ${l.product.name}',
                                icon: const Icon(Icons.add),
                                onPressed: busy
                                    ? null
                                    : () =>
                                          widget.onQtyChanged(l.product.id, 1),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _couponController,
                        enabled: !busy,
                        decoration: const InputDecoration(
                          labelText: 'Coupon code',
                        ),
                        onSubmitted: widget.onApplyCoupon,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: busy
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              widget.onApplyCoupon(_couponController.text);
                            },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
                if (state.couponError.isNotEmpty)
                  Text(
                    state.couponError,
                    style: const TextStyle(color: Colors.red),
                  ),
                if (state.coupon.isNotEmpty) Text('Applied: ${state.coupon}'),
              ],
            ),
          ),
          widget.summary ?? CartSummary(state: state),
          Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton(
              onPressed: busy || state.lines.isEmpty ? null : widget.onCheckout,
              child: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}

class CartSummary extends StatelessWidget {
  const CartSummary({super.key, required this.state});
  final CartState state;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.all(12),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _row('Items', '${state.itemCount}'),
          _row('Subtotal', state.subtotal.toStringAsFixed(2)),
          _row('Discount', state.discount.toStringAsFixed(2)),
          _row('Total', state.total.toStringAsFixed(2)),
        ],
      ),
    ),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, key: ValueKey('summary-$label')),
      ],
    ),
  );
}

// Called by setState after checkout, or by Riverpod/Bloc listeners.
void showCheckoutMessage(BuildContext context, CartState state) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentMaterialBanner();
  if (state.status == CheckoutStatus.success) {
    messenger.showSnackBar(
      SnackBar(content: Text('Order ${state.orderId} placed')),
    );
  } else if (state.status == CheckoutStatus.failure) {
    messenger.showMaterialBanner(
      MaterialBanner(
        content: Text(state.checkoutError),
        actions: [
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
}

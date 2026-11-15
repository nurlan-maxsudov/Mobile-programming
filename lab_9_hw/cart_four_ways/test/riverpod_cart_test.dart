import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cart_four_ways/models/cart.dart';
import 'package:cart_four_ways/riverpod/cart_notifier.dart';
import 'package:cart_four_ways/services/checkout_api.dart';

class MockCheckoutApi extends Mock implements CheckoutApi {}

void main() {
  test('two keyboards and SAVE10 total 88.2', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // A real listener keeps an autoDispose provider alive during a test.
    final subscription = container.listen(cartProvider, (_, _) {});
    addTearDown(subscription.close);
    final cart = container.read(cartProvider.notifier);
    cart.add(catalog.first);
    cart.add(catalog.first);
    cart.applyCoupon('SAVE10');
    expect(container.read(cartProvider).total, 88.2);
  });

  test('failed checkout keeps the cart', () async {
    final api = MockCheckoutApi();
    when(() => api.submit(any()))
        .thenThrow(const CheckoutException('Card declined'));
    final container = ProviderContainer(
      overrides: [checkoutApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(cartProvider, (_, _) {});
    addTearDown(subscription.close);
    final cart = container.read(cartProvider.notifier);
    cart.add(catalog.first);
    await cart.checkout();
    expect(container.read(cartProvider).status, CheckoutStatus.failure);
    expect(container.read(cartProvider).lines, [
      CartLine(product: catalog.first, qty: 1),
    ]);
  });

  test('equal coupon does not notify; undo availability follows history', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    var changes = 0;
    container.listen(cartProvider, (_, _) => changes++);
    final cart = container.read(cartProvider.notifier);
    cart.add(catalog.first);
    cart.applyCoupon('SAVE10');
    final before = changes;
    cart.applyCoupon('SAVE10');
    expect(changes, before);
    expect(container.read(canUndoProvider), isTrue);
    cart.undo();
    expect(container.read(cartProvider).coupon, '');
    cart.undo();
    expect(container.read(canUndoProvider), isFalse);
  });

  test('disposal during checkout is safe and returning starts empty', () async {
    final api = MockCheckoutApi();
    final pending = Completer<String>();
    when(() => api.submit(any())).thenAnswer((_) => pending.future);
    final container = ProviderContainer(
      overrides: [checkoutApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(cartProvider, (_, _) {});
    final cart = container.read(cartProvider.notifier);
    cart.add(catalog.first);
    final checkout = cart.checkout();
    subscription.close();
    await container.pump();
    pending.complete('ORD-TEST');
    await checkout;
    final returned = container.listen(cartProvider, (_, _) {});
    addTearDown(returned.close);
    expect(container.read(cartProvider).lines, isEmpty);
    expect(container.read(cartProvider).canUndo, isFalse);
  });
}

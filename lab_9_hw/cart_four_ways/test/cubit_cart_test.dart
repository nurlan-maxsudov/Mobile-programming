import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cart_four_ways/models/cart.dart';
import 'package:cart_four_ways/cubit/cart_cubit.dart';
import 'package:cart_four_ways/services/checkout_api.dart';

class MockCheckoutApi extends Mock implements CheckoutApi {}

void main() {
  late MockCheckoutApi api;
  final keyboard = catalog.first;
  setUp(() => api = MockCheckoutApi());

  // T6: blocTest checks the full ordered sequence of emitted states.
  // Riverpod tests mainly inspect final state without pumping any widgets.
  blocTest<CartCubit, CartState>(
    'emits the three exact cart states',
    build: () => CartCubit(api),
    act: (c) {
      c.add(keyboard);
      c.add(keyboard);
      c.applyCoupon('SAVE10');
    },
    expect: () => [
      CartState(lines: [CartLine(product: keyboard, qty: 1)], canUndo: true),
      CartState(lines: [CartLine(product: keyboard, qty: 2)], canUndo: true),
      CartState(
        lines: [CartLine(product: keyboard, qty: 2)],
        coupon: 'SAVE10',
        canUndo: true,
      ),
    ],
  );

  blocTest<CartCubit, CartState>(
    'checkout emits submitting then failure and keeps lines',
    build: () {
      when(() => api.submit(any()))
          .thenThrow(const CheckoutException('Card declined'));
      return CartCubit(api)..add(keyboard);
    },
    act: (c) => c.checkout(),
    expect: () => [
      CartState(
        lines: [CartLine(product: keyboard, qty: 1)],
        canUndo: true,
        status: CheckoutStatus.submitting,
      ),
      CartState(
        lines: [CartLine(product: keyboard, qty: 1)],
        canUndo: true,
        status: CheckoutStatus.failure,
        checkoutError: 'Card declined',
      ),
    ],
  );

  blocTest<CartCubit, CartState>(
    'the second identical coupon emit is dropped',
    build: () => CartCubit(api),
    act: (c) {
      c.applyCoupon('SAVE10');
      c.applyCoupon('SAVE10');
    },
    expect: () => [CartState(coupon: 'SAVE10', canUndo: true)],
  );

  test('close while checkout awaits does not emit after close', () async {
    final pending = Completer<String>();
    when(() => api.submit(any())).thenAnswer((_) => pending.future);
    final cart = CartCubit(api)..add(keyboard);
    final checkout = cart.checkout();
    await cart.close();
    pending.complete('ORD-TEST');
    await checkout;
    expect(cart.isClosed, isTrue);
  });
}

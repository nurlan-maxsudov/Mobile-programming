import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cart_four_ways/models/cart.dart';
import 'package:cart_four_ways/bloc/cart_bloc.dart';
import 'package:cart_four_ways/bloc/cart_event.dart';
import 'package:cart_four_ways/services/checkout_api.dart';

class MockCheckoutApi extends Mock implements CheckoutApi {}

void main() {
  late MockCheckoutApi api;
  final keyboard = catalog.first;
  final empty = CartState();
  final one = CartState(lines: [CartLine(product: keyboard, qty: 1)]);
  final two = CartState(lines: [CartLine(product: keyboard, qty: 2)]);
  setUp(() => api = MockCheckoutApi());

  blocTest<CartBloc, CartState>(
    'events emit the three exact cart states',
    build: () => CartBloc(api),
    act: (b) => b
      ..add(CartProductAdded(keyboard))
      ..add(CartProductAdded(keyboard))
      ..add(const CartCouponApplied('SAVE10')),
    expect: () => [
      one.copyWith(canUndo: true, history: [empty]),
      two.copyWith(canUndo: true, history: [empty, one]),
      two.copyWith(coupon: 'SAVE10', canUndo: true, history: [empty, one, two]),
    ],
  );

  blocTest<CartBloc, CartState>(
    'checkout emits submitting then failure and keeps lines',
    build: () {
      when(() => api.submit(any()))
          .thenThrow(const CheckoutException('Card declined'));
      return CartBloc(api);
    },
    seed: () => one,
    act: (b) => b.add(const CartCheckoutRequested()),
    expect: () => [
      one.copyWith(status: CheckoutStatus.submitting),
      one.copyWith(
        status: CheckoutStatus.failure,
        checkoutError: 'Card declined',
      ),
    ],
  );

  blocTest<CartBloc, CartState>(
    'droppable ignores a second checkout while the first awaits',
    build: () {
      when(() => api.submit(any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return 'ORD-TEST';
      });
      return CartBloc(api);
    },
    seed: () => one,
    act: (b) async {
      final success = b.stream.firstWhere(
        (s) => s.status == CheckoutStatus.success,
      );
      b
        ..add(const CartCheckoutRequested())
        ..add(const CartCheckoutRequested());
      await success;
    },
    expect: () => [
      one.copyWith(status: CheckoutStatus.submitting),
      CartState(
        status: CheckoutStatus.success,
        orderId: 'ORD-TEST',
        canUndo: true,
        history: [one],
      ),
    ],
    verify: (_) => verify(() => api.submit(49)).called(1),
  );

  test('close during checkout safely cancels the emitter', () async {
    final pending = Completer<String>();
    when(() => api.submit(any())).thenAnswer((_) => pending.future);
    final cart = CartBloc(api);
    cart.add(CartProductAdded(keyboard));
    await cart.stream.firstWhere((s) => s.lines.isNotEmpty);
    cart.add(const CartCheckoutRequested());
    await cart.stream.firstWhere((s) => s.status == CheckoutStatus.submitting);
    final closing = cart.close();
    pending.complete('ORD-TEST');
    await closing;
    expect(cart.isClosed, isTrue);
  });
}

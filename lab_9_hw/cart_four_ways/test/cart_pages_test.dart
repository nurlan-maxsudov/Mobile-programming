import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cart_four_ways/main.dart';

Future<void> tap(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

String? total(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const ValueKey('summary-Total'))).data;

void main() {
  for (final style in ['setState', 'Riverpod', 'Cubit', 'Bloc']) {
    testWidgets('$style: quantity, coupon, failure, undo and success', (
      tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: MainApp()));
      await tap(tester, style);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Undo'))
            .onPressed,
        isNull,
      );
      await tap(tester, 'Keyboard · 49');
      await tester.tap(find.byTooltip('Decrease Keyboard'));
      await tester.pumpAndSettle();
      expect(find.text('Cart is empty'), findsOneWidget);
      await tap(tester, 'Undo');
      await tap(tester, 'Keyboard · 49');
      await tester.enterText(find.byType(TextField), 'SAVE10');
      await tap(tester, 'Apply');
      expect(total(tester), '88.20');
      await tester.enterText(find.byType(TextField), 'WRONG');
      await tap(tester, 'Apply');
      expect(find.text('Invalid coupon code'), findsOneWidget);
      expect(total(tester), '98.00');
      await tap(tester, 'Undo');
      expect(total(tester), '88.20');
      await tester.tap(find.byTooltip('Decrease Keyboard'));
      await tester.pumpAndSettle();
      expect(total(tester), '44.10');
      await tester.tap(find.byTooltip('Increase Keyboard'));
      await tester.pumpAndSettle();
      expect(total(tester), '88.20');
      for (var i = 0; i < 3; i++) {
        await tap(tester, 'Monitor · 199');
      }
      expect(total(tester), '625.50');
      await tester.tap(find.text('Checkout'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.byType(MaterialBanner), findsOneWidget);
      expect(find.text('Card declined'), findsOneWidget);
      expect(total(tester), '625.50');
      await tap(tester, 'Dismiss');
      await tap(tester, 'Undo');
      expect(total(tester), '446.40');
      await tester.tap(find.text('Checkout'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Cart is empty'), findsOneWidget);
      expect(find.textContaining('Order ORD-'), findsOneWidget);
      await tap(tester, 'Undo');
      expect(total(tester), '446.40');
      expect(tester.takeException(), isNull);
    });

    testWidgets('$style: leaving during checkout is safe', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: MainApp()));
      await tap(tester, style);
      await tap(tester, 'Keyboard · 49');
      await tester.tap(find.text('Checkout'));
      await tester.pump();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
      await tap(tester, style);
      expect(find.text('Cart is empty'), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Undo'))
            .onPressed,
        isNull,
      );
    });
  }
}

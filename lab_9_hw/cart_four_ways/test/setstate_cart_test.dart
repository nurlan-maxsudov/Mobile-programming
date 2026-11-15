import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cart_four_ways/setstate/cart_page_setstate.dart';

void main() {
  // T6: Most lines find widgets, tap, enter text and pump frames.
  // The final assertion checks the cart result: 2 * 49 * 0.9 = 88.20.
  testWidgets('two keyboards and SAVE10 total 88.20', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SetStateCartPage()));
    await tester.tap(find.text('Keyboard · 49'));
    await tester.pump();
    await tester.tap(find.text('Keyboard · 49'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'SAVE10');
    await tester.tap(find.text('Apply'));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('summary-Total'))).data,
      '88.20',
    );
  });
}

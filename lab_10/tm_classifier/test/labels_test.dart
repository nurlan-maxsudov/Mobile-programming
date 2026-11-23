import 'package:flutter_test/flutter_test.dart';
import 'package:tm_classifier/services/classifier.dart';

void main() {
  test('parses indexed labels in model output order', () {
    expect(parseLabels('0 Mug\n1 Bottle\n'), ['Mug', 'Bottle']);
  });

  test('handles Windows endings, blank lines, and multi-word labels', () {
    expect(parseLabels('0 Mug\r\n1 Bottle\r\n2 Car keys\r\n\r\n'), [
      'Mug',
      'Bottle',
      'Car keys',
    ]);
  });
}

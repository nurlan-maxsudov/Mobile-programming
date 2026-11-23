import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tm_classifier/app.dart';
import 'package:tm_classifier/services/classifier.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('real model recognizes the bottle and handles invalid input', (
    tester,
  ) async {
    final classifier = await Classifier.load();
    addTearDown(classifier.close);
    final bytes = await ClassifierApp.loadSample();
    final stopwatch = Stopwatch()..start();
    final predictions = classifier.classify(bytes);
    stopwatch.stop();
    for (final prediction in predictions) {
      debugPrint(
        'REAL MODEL: ${prediction.label}: ${(prediction.confidence * 100).toStringAsFixed(4)}%',
      );
    }
    final total = predictions.fold(0.0, (sum, p) => sum + p.confidence);
    debugPrint(
      'REAL MODEL: total=$total, elapsed=${stopwatch.elapsedMilliseconds} ms',
    );
    expect(predictions.length, classifier.labels.length);
    expect(predictions.length, 6);
    expect(predictions.first.label, 'Bottle');
    expect(total, closeTo(1, 0.01));
    expect(
      () => classifier.classify(Uint8List.fromList(utf8.encode('a text file'))),
      throwsA(
        isA<ClassifierException>().having(
          (e) => e.message,
          'message',
          contains('not a readable image'),
        ),
      ),
    );

    await tester.pumpWidget(
      ClassifierApp(classifierLoader: () async => classifier),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Classify sample photo'));
    await tester.pumpAndSettle();
    expect(find.text('Result'), findsOneWidget);
    expect(find.text('Bottle'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('missing model path appears on startup screen', (tester) async {
    await tester.pumpWidget(
      ClassifierApp(
        classifierLoader: () =>
            Classifier.load(modelPath: 'assets/model/typo.tflite'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load the model'), findsOneWidget);
    expect(find.textContaining('assets/model/typo.tflite'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

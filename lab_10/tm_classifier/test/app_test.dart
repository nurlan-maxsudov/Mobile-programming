import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:tm_classifier/app.dart';
import 'package:tm_classifier/services/classifier.dart';
import 'package:tm_classifier/services/image_sources.dart';
import 'package:tm_classifier/widgets/classification_tile.dart';

class _TestClassifier extends Fake implements Classifier {
  bool closed = false;
  bool rejectImage = false;
  int calls = 0;

  @override
  List<String> get labels => [
    'Nothing',
    'Bottle',
    'Phone',
    'Glasses',
    'Mouse',
    'Card',
  ];

  @override
  List<Prediction> classify(Uint8List bytes) {
    calls++;
    if (rejectImage) {
      throw const ClassifierException(
        'This file is not a readable image. Choose a JPEG or PNG photo.',
      );
    }
    return [
      const Prediction('Bottle', 0.95),
      for (final label in labels.where((label) => label != 'Bottle'))
        Prediction(label, 0.01),
    ];
  }

  @override
  void close() => closed = true;
}

class _MissingModelBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == Classifier.labelsAsset) {
      return ByteData.sublistView(
        Uint8List.fromList(utf8.encode('0 Bottle\n')),
      );
    }
    throw FlutterError('Unable to load asset: "$key".');
  }
}

class _TestSources extends Fake implements ImageSources {
  Uint8List? bytes = img.encodePng(img.Image(width: 10, height: 10));
  String? url;
  bool fail = false;
  @override
  Future<Uint8List?> fromCamera() async {
    if (fail) throw const ImageSourceException('Camera access was denied.');
    return bytes;
  }

  @override
  Future<Uint8List?> fromGallery() async => bytes;
  @override
  Future<Uint8List> fromUrl(String value) async {
    url = value;
    return bytes!;
  }

  @override
  void close() {}
}

void main() {
  testWidgets(
    'all three sources classify and history reopens without inference',
    (tester) async {
      final classifier = _TestClassifier();
      final sources = _TestSources();
      await tester.pumpWidget(
        ClassifierApp(
          classifierLoader: () async => classifier,
          imageSources: sources,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      for (final action in [
        ('Take a photo', 'Camera'),
        ('Choose from gallery', 'Gallery'),
        ('Download an image', 'Download'),
      ]) {
        await tester.tap(find.text(action.$1));
        await tester.pumpAndSettle();
        if (action.$2 == 'Download') {
          await tester.enterText(
            find.byType(TextFormField),
            'https://example.com/new.png',
          );
          await tester.tap(find.widgetWithText(FilledButton, 'Download'));
          await tester.pumpAndSettle();
        }
        expect(find.text('Result'), findsOneWidget);
        expect(find.text(action.$2), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
      expect(sources.url, 'https://example.com/new.png');
      expect(classifier.calls, 3);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('History'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ClassificationTile), findsNWidgets(3));
      expect(
        tester
            .widget<ClassificationTile>(find.byType(ClassificationTile).first)
            .record
            .source
            .label,
        'Download',
      );
      await tester.tap(find.byType(ClassificationTile).first);
      await tester.pumpAndSettle();
      expect(find.text('Result'), findsOneWidget);
      expect(classifier.calls, 3);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'cancellation and permission failure do not add history or freeze UI',
    (tester) async {
      final classifier = _TestClassifier();
      final sources = _TestSources()..bytes = null;
      await tester.pumpWidget(
        ClassifierApp(
          classifierLoader: () async => classifier,
          imageSources: sources,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();
      expect(classifier.calls, 0);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      sources.fail = true;
      await tester.tap(find.text('Take a photo'));
      await tester.pumpAndSettle();
      expect(find.text('Camera access was denied.'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('History'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No photos classified yet'), findsOneWidget);
      expect(classifier.calls, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('missing model shows its path and supports retry', (
    tester,
  ) async {
    var loads = 0;
    await tester.pumpWidget(
      ClassifierApp(
        classifierLoader: () {
          loads++;
          return Classifier.load(
            bundle: _MissingModelBundle(),
            modelPath: 'assets/model/typo.tflite',
          );
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load the model'), findsOneWidget);
    expect(find.textContaining('assets/model/typo.tflite'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(loads, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loads once, reuses the classifier, and closes it on disposal', (
    tester,
  ) async {
    final classifier = _TestClassifier();
    final ready = Completer<Classifier>();
    var loads = 0;
    await tester.pumpWidget(
      ClassifierApp(
        classifierLoader: () {
          loads++;
          return ready.future;
        },
        sampleLoader: () async =>
            img.encodePng(img.Image(width: 10, height: 10)),
      ),
    );
    expect(find.text('Loading the model…'), findsOneWidget);
    ready.complete(classifier);
    await tester.pumpAndSettle();
    for (var attempt = 0; attempt < 2; attempt++) {
      await tester.tap(find.text('Classify sample photo'));
      await tester.pumpAndSettle();
      expect(find.text('Result'), findsOneWidget);
      expect(find.text('95.0%'), findsOneWidget);
      // The last rows are below the fold on a small screen.
      await tester.scrollUntilVisible(find.text('Card'), 150);
      expect(find.text('Card'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    expect(loads, 1);
    expect(classifier.calls, 2);
    await tester.pumpWidget(const SizedBox());
    expect(classifier.closed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'invalid image leaves a readable error and an enabled retry action',
    (tester) async {
      final classifier = _TestClassifier()..rejectImage = true;
      await tester.pumpWidget(
        ClassifierApp(
          classifierLoader: () async => classifier,
          sampleLoader: () async =>
              Uint8List.fromList(utf8.encode('text file')),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Classify sample photo'));
      await tester.pumpAndSettle();
      expect(find.textContaining('not a readable image'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Classify sample photo'),
            )
            .onPressed,
        isNotNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('closes an interpreter that finishes loading after disposal', (
    tester,
  ) async {
    final ready = Completer<Classifier>();
    final classifier = _TestClassifier();
    await tester.pumpWidget(
      ClassifierApp(classifierLoader: () => ready.future),
    );
    await tester.pumpWidget(const SizedBox());
    ready.complete(classifier);
    await tester.pump();
    expect(classifier.closed, isTrue);
    expect(tester.takeException(), isNull);
  });
}

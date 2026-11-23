# Tests

`labels_test.dart` contains the two required tests of `parseLabels`:

1. Normal indexed labels: `0 Mug\n1 Bottle\n` becomes `['Mug', 'Bottle']`.
2. Windows line endings, trailing blank lines, and a multi-word label (`2 Car keys`).

`image_preprocessing_test.dart` checks center cropping, RGB normalization,
EXIF rotation, invalid bytes, and decoding the actual sample.

`app_test.dart` checks loading, missing-model errors/retry, one shared classifier,
result navigation, invalid-image errors, and disposal. It uses a fake classifier;
the fake predictions do not measure model accuracy.

`image_sources_test.dart` covers picker sources and cancellation, permission
errors, image downloads, HTTP failures, non-image URLs, timeouts, and size limits.
The widget tests also check all three input flows and History reuse.

Run `flutter test` for all 22 tests. The real-model tests live in
`../integration_test/classifier_test.dart` and require an Android/iOS runtime:


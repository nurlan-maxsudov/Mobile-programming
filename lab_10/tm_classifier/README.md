# Lab 10: Teachable Machine Image Classifier

Flutter app for Android and iOS. It loads the supplied floating-point model once
at startup and shows its six labels. Tap **Get started** to open Home, then:

- **Take a photo** opens the system camera.
- **Choose from gallery** selects an existing photo or downloaded image.
- **Download an image** accepts a direct HTTPS image URL.
- **Classify sample photo** still tests `assets/model/sample.jpeg`.

Every source uses the same classifier and Result screen. Successful results are
saved newest-first in **History** for this session; tapping one reopens its saved
predictions without running the model again. **Model** displays the loaded labels
and model details. History is cleared when the app restarts.

The credited Figma design and reference screenshots remain to be supplied. The
current theme is a basic Material starter.

## Structure

```text
tm_classifier/
  android/                         Android runner and internet permission
  ios/                             iOS runner and camera/photo usage descriptions
  assets/model/                    Model export, labels.txt, and sample.jpeg
  docs/                            Add training/design screenshots and recording
  lib/
    main.dart                      Entry point
    app.dart                       MaterialApp configuration
    screens/
      welcome_screen.dart
      home_screen.dart
      result_screen.dart
      history_screen.dart
      model_screen.dart
    services/
      classifier.dart              Model loading, validation, and inference
      image_preprocessing.dart     EXIF orientation, center crop, normalization
      image_sources.dart           Camera/gallery selection and URL downloads
    theme/app_theme.dart           Shared starter theme
    models/classification_record.dart
    widgets/                       Result tiles and image URL dialog
  test/                            Label parsing, preprocessing, and widget tests
  integration_test/                Actual-model tests on Android/iOS
  NOTES.md                         Lab answers and evaluation template
  pubspec.yaml                     Dependencies and model asset declaration
```

## Run

From this directory, with an Android or iOS device selected:

```sh
flutter pub get
flutter run
```

For the installed Android emulator, use `flutter run -d emulator-5554` after
starting it. If your terminal prompt already shows `tm_classifier`, you are
already in the project directory.

Use JDK 17 for Android builds with the project's Gradle 9.3.1 / Android Gradle
Plugin 9.1 setup. Java 27 caused `Unsupported class file major version 71`;
upgrading Gradle alone then exposed an Android `jlink` failure. On this Mac,
install and select the supported JDK with:

```sh
brew install openjdk@17
flutter config --jdk-dir=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
```

The Flutter JDK setting applies to all Flutter projects on this Mac; it does not
replace the system Java installation. See the
[Android Gradle Plugin compatibility table](https://developer.android.com/build/releases/agp-9-1-0-release-notes).

The bundled labels are Nothing, Bottle, Phone, Glasses, Mouse, and Card. Keep the
model and labels from the same export. Startup checks the input tensor's shape
and type and verifies that the number of outputs matches the label count.

Images are decoded, rotated according to EXIF, center-cropped/resized to 224 x
224 RGB, and normalized to [-1, 1]. Predictions are paired with their labels
before sorting. Model loading and classification failures show readable messages.
The app owns the interpreter and closes it when disposed, including if loading
finishes after disposal. Inference is synchronous; the loading state is painted
first, but its animation can pause during processing. Moving inference to an
isolate is an optional later improvement.

## Testing new photos in the emulator

The installed emulator uses a virtual rear-camera scene and an emulated front
camera. To test real objects, copy photos into the emulator (for example, drag a
photo onto its window), then choose them from the gallery. A Mac webcam requires
configuring the emulator camera separately. Downloading from a direct HTTPS
image URL is another option.

Camera/gallery cancellation returns to Home without an error. Downloads require
HTTP 200 and an `image/` content type, time out after 20 seconds, and are limited
to 20 MB. Invalid images and denied permissions display readable errors.

## Validation

```sh
flutter analyze
flutter test
flutter test integration_test/classifier_test.dart -d <device-id>
```

The integration test requires an Android/iOS device or emulator. It runs the
real model on the supplied bottle photo, checks that Bottle is first and the
probabilities sum to one, rejects text bytes, exercises the result screen, and
checks a missing-model startup error. Unit/widget tests use a fake classifier
only for UI state and lifecycle checks; their confidence values are not model
measurements. They also test the actual sample's image preprocessing.

Latest validation: static analysis is clean, all 22 unit/widget tests pass, and
the updated debug APK builds. Java 17 resolves the Android build-tool errors.
`android/build.gradle.kts` also aligns tflite_flutter 0.12.1's Kotlin target with
its Java 11 target. Source tests cover camera/gallery bytes, cancellation,
permission errors, URL validation, status/content type, timeout, download limits,
and saved History navigation. Model accuracy still needs the lab's evaluation;
the bundled sample currently scores Glasses 39.4% and Bottle 34.8% on the emulator,
so the integration test's Bottle-first accuracy assertion is not yet satisfied.
The updated app was installed and the Home screen/camera launch were observed.
The emulator disconnected before the full gallery check; end-to-end native source
and History demonstrations still need to be completed.

## Lab checkpoints

1. Train and export your own model: `p1-model`.
2. Verify assets, dependencies, and a device build: `p2-setup`.
3. Implement the classifier and two label parser tests: `p3-classifier`.
4. Implement the five screens using a credited Figma design: `p4-screens`.
5. Connect all sources, History, and evaluation: `p5-sources`.

Commit and tag each checkpoint only when it is complete; push commits and tags
for the demonstration. Run `flutter analyze` and `flutter test`.

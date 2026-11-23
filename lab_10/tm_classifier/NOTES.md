# Lab 10 Notes

## Part 1: Model

1. **What happens with an unknown object?**
   The model picks a known class. The background class helps recognise empty scenes, but not all unknown objects.

2. **Floating-point vs quantized model?**
   Floating-point uses decimals and more space. Quantized uses integers and less space, so the code must handle values differently.

## Part 2: Setup

1. **`assets/model/` vs `assets/`?**
   Each includes files in that folder only. `assets/` does not include the model subfolder automatically.

2. **Why do some packages need platform support?**
   `image` and `http` use Dart. `image_picker` needs Android/iOS, and `tflite_flutter` needs the native ML library.

## Part 3: Classifier

1. **What if we use `value / 255`?**
   It gives the wrong value range, so predictions may change. It does not crash because the data shape and type stay the same.

2. **How do we add a seventh class?**
   Retrain and replace both model and labels. The app gets the class count from the labels.

## Part 4: Design

1. **What did we change from Figma?**
   No Figma design was used yet. The app uses Material 3.

2. **Where does the Model screen get its labels?**
   From the loaded classifier, so it does not read the same file again.

## Part 5: Sources

1. **Why can camera and downloaded photos get different scores?**
   Their angles, lighting, or backgrounds may differ from the training photos.

2. **How long does classification take?**
   One emulator run took about 1.4 seconds. A loading indicator appears but may pause. Phone speed was not tested.

## Final Questions

1. **How does a photo become percentages?**
   `image_sources.dart` gets bytes → `image_preprocessing.dart` rotates, crops, resizes, and scales them → `classifier.dart` predicts → `app.dart` saves → `result_screen.dart` displays percentages.

2. **Which three `pubspec.yaml` entries are essential?**
   `assets/model/`, `tflite_flutter`, and `image_picker`. Removing them causes missing-file or missing-package errors.

3. **What must match the training input?**
   The 224 × 224 centre crop and RGB values scaled to [-1, 1].

4. **Does 97% confidence mean the prediction is correct?**
   No. It shows confidence among known classes. An unfamiliar object can still get a high score.

5. **What stays on the device?**
   Photos, model, results, and history stay locally. Downloads need internet; a cloud vision API would upload photos.

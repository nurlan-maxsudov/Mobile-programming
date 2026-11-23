import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'image_preprocessing.dart';

class Prediction {
  const Prediction(this.label, this.confidence);

  final String label;
  final double confidence;
}

/// Preserve export order: output index i belongs to label index i.
List<String> parseLabels(String raw) => [
  for (final line in raw.split('\n'))
    if (line.trim().isNotEmpty)
      line.trim().replaceFirst(RegExp(r'^\d+\s+'), ''),
];

class ClassifierException implements Exception {
  const ClassifierException(this.message);

  final String message;

  @override
  String toString() => message;
}

class Classifier {
  Classifier._(this._interpreter, List<String> labels)
    : labels = List.unmodifiable(labels);

  static const modelAsset = 'assets/model/model_unquant.tflite';
  static const labelsAsset = 'assets/model/labels.txt';
  static const inputSize = classifierInputSize;

  final Interpreter _interpreter;
  final List<String> labels;
  bool _closed = false;

  static Future<Classifier> load({
    AssetBundle? bundle,
    String modelPath = modelAsset,
    String labelsPath = labelsAsset,
  }) async {
    final assets = bundle ?? rootBundle;
    Interpreter? interpreter;
    var stage = 'Read labels at "$labelsPath"';
    try {
      final labels = parseLabels(await assets.loadString(labelsPath));
      if (labels.isEmpty || labels.any((label) => label.isEmpty)) {
        throw const FormatException(
          'The label file contains no usable labels.',
        );
      }
      stage = 'Load model at "$modelPath"';
      final data = await assets.load(modelPath);
      interpreter = Interpreter.fromBuffer(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );

      stage = 'Check model "$modelPath" against labels "$labelsPath"';
      final inputs = interpreter.getInputTensors();
      final outputs = interpreter.getOutputTensors();
      if (inputs.length != 1 || outputs.length != 1) {
        throw const FormatException('Expected one image input and one output.');
      }
      if (inputs.single.type != TensorType.float32 ||
          !listEquals(inputs.single.shape, [1, inputSize, inputSize, 3])) {
        throw const FormatException(
          'Expected a floating-point model with input [1, 224, 224, 3]. '
          'Export TensorFlow Lite → Floating point from Teachable Machine.',
        );
      }
      if (outputs.single.type != TensorType.float32 ||
          !listEquals(outputs.single.shape, [1, labels.length])) {
        throw FormatException(
          'Model output ${outputs.single.shape} does not match '
          '${labels.length} labels. Use model and labels from the same export.',
        );
      }
      return Classifier._(interpreter, labels);
    } catch (error) {
      interpreter?.close();
      throw ClassifierException('$stage failed. $error');
    }
  }

  List<Prediction> classify(Uint8List bytes) {
    if (_closed) {
      throw const ClassifierException(
        'The classifier has already been closed.',
      );
    }
    try {
      final input = prepareImageInput(bytes);
      final output = [List<double>.filled(labels.length, 0)];
      _interpreter.run(input, output);
      final probabilities = output.single;
      final total = probabilities.fold(0.0, (sum, value) => sum + value);
      if (probabilities.any((p) => !p.isFinite || p < 0 || p > 1) ||
          (total - 1).abs() > 0.01) {
        throw const ClassifierException(
          'The model returned invalid probabilities. Check the model export '
          'and image preprocessing.',
        );
      }
      return [
        for (var i = 0; i < labels.length; i++)
          Prediction(labels[i], probabilities[i]),
      ]..sort((a, b) => b.confidence.compareTo(a.confidence));
    } on FormatException {
      throw const ClassifierException(
        'This file is not a readable image. Choose a JPEG or PNG photo.',
      );
    } on ClassifierException {
      rethrow;
    } catch (error) {
      throw ClassifierException('Could not classify this image. $error');
    }
  }

  void close() {
    if (_closed) return;
    _closed = true;
    _interpreter.close();
  }
}

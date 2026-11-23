import 'dart:typed_data';

import '../services/classifier.dart';

enum ImageOrigin {
  camera('Camera'),
  gallery('Gallery'),
  download('Download'),
  sample('Sample photo');

  const ImageOrigin(this.label);
  final String label;
}

class ClassificationRecord {
  ClassificationRecord({
    required this.bytes,
    required List<Prediction> predictions,
    required this.source,
    required this.duration,
  }) : predictions = List.unmodifiable(predictions);

  final Uint8List bytes;
  final List<Prediction> predictions;
  final ImageOrigin source;
  final Duration duration;
  Prediction get top => predictions.first;
}

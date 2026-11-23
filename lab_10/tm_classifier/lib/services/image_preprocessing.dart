import 'dart:typed_data';

import 'package:image/image.dart' as img;

const classifierInputSize = 224;

/// The floating-point Teachable Machine input is [1, 224, 224, 3], RGB [-1, 1].
List<List<List<List<double>>>> prepareImageInput(Uint8List bytes) {
  final img.Image? decoded;
  try {
    decoded = img.decodeImage(bytes);
  } catch (_) {
    throw const FormatException('Not a readable image');
  }
  if (decoded == null) throw const FormatException('Not a readable image');
  final square = img.copyResizeCropSquare(
    img
        .bakeOrientation(decoded)
        .convert(format: img.Format.uint8, numChannels: 3),
    size: classifierInputSize,
  );
  return [
    List.generate(
      classifierInputSize,
      (y) => List.generate(classifierInputSize, (x) {
        final pixel = square.getPixel(x, y);
        return [pixel.r / 127.5 - 1, pixel.g / 127.5 - 1, pixel.b / 127.5 - 1];
      }),
    ),
  ];
}

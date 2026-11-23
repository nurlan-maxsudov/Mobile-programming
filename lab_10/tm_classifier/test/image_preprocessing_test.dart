import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:tm_classifier/services/image_preprocessing.dart';

void main() {
  test('rejects text bytes instead of passing them to the interpreter', () {
    expect(
      () => prepareImageInput(Uint8List.fromList(utf8.encode('not a photo'))),
      throwsFormatException,
    );
  });

  test(
    'uses a center crop and preserves RGB channel order and normalization',
    () {
      final photo = img.Image(width: 448, height: 224);
      img.fill(photo, color: img.ColorRgb8(0, 255, 0));
      img.fillRect(
        photo,
        x1: 112,
        y1: 0,
        x2: 335,
        y2: 223,
        color: img.ColorRgb8(255, 0, 128),
      );
      final input = prepareImageInput(img.encodePng(photo));
      expect(input.length, 1);
      expect(input.single.length, 224);
      expect(input.single.first.length, 224);
      for (final row in input.single) {
        for (final pixel in row) {
          expect(pixel[0], 1);
          expect(pixel[1], -1);
          expect(pixel[2], closeTo(128 / 127.5 - 1, 1e-9));
        }
      }
    },
  );

  test('applies EXIF orientation before resizing', () {
    final photo = img.Image(width: 224, height: 224);
    img.fill(photo, color: img.ColorRgb8(0, 0, 255));
    img.fillRect(
      photo,
      x1: 0,
      y1: 0,
      x2: 111,
      y2: 223,
      color: img.ColorRgb8(255, 0, 0),
    );
    photo.exif.imageIfd.orientation = 6;
    final input = prepareImageInput(img.encodeJpg(photo, quality: 100));
    // A 90-degree clockwise rotation places the red left half at the top.
    expect(input.single[30][100][0], greaterThan(0.9));
    expect(input.single[190][100][2], greaterThan(0.9));
  });

  test('the supplied sample decodes to a finite normalized tensor', () {
    final input = prepareImageInput(
      File('assets/model/sample.jpeg').readAsBytesSync(),
    );
    expect(input.single.length, 224);
    for (final row in input.single) {
      expect(row.length, 224);
      for (final pixel in row) {
        expect(pixel.length, 3);
        for (final channel in pixel) {
          expect(channel.isFinite && channel >= -1 && channel <= 1, isTrue);
        }
      }
    }
  });
}

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tm_classifier/services/image_sources.dart';

class _Picker extends ImagePicker {
  XFile? result;
  PlatformException? failure;
  ImageSource? lastSource;
  double? lastWidth;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    lastSource = source;
    lastWidth = maxWidth;
    if (failure != null) throw failure!;
    return result;
  }
}

void main() {
  test(
    'camera and gallery request the correct source and return bytes',
    () async {
      final picker = _Picker()
        ..result = XFile.fromData(
          Uint8List.fromList([1, 2, 3]),
          mimeType: 'image/png',
        );
      final sources = ImageSources(picker: picker);
      addTearDown(sources.close);
      expect(await sources.fromCamera(), [1, 2, 3]);
      expect(picker.lastSource, ImageSource.camera);
      expect(picker.lastWidth, 1024);
      expect(await sources.fromGallery(), [1, 2, 3]);
      expect(picker.lastSource, ImageSource.gallery);
    },
  );

  test('picker cancellation returns null for both sources', () async {
    final sources = ImageSources(picker: _Picker());
    addTearDown(sources.close);
    expect(await sources.fromCamera(), isNull);
    expect(await sources.fromGallery(), isNull);
  });

  test('permission denial becomes an actionable message', () async {
    final sources = ImageSources(
      picker: _Picker()
        ..failure = PlatformException(code: 'camera_access_denied'),
    );
    addTearDown(sources.close);
    await expectLater(
      sources.fromCamera(),
      throwsA(
        isA<ImageSourceException>().having(
          (e) => e.message,
          'message',
          contains('device settings'),
        ),
      ),
    );
  });

  test('downloads a successful image response', () async {
    final sources = ImageSources(
      client: MockClient((request) async {
        expect(request.url.toString(), 'https://example.com/photo.png');
        return http.Response.bytes(
          [1, 2, 3],
          200,
          headers: {'content-type': 'image/png'},
        );
      }),
    );
    addTearDown(sources.close);
    expect(await sources.fromUrl(' https://example.com/photo.png '), [1, 2, 3]);
  });

  test('rejects a web page returned with status 200', () async {
    final sources = ImageSources(
      client: MockClient(
        (_) async => http.Response(
          '<html>',
          200,
          headers: {'content-type': 'text/html'},
        ),
      ),
    );
    addTearDown(sources.close);
    await expectLater(
      sources.fromUrl('https://example.com/page'),
      throwsA(
        isA<ImageSourceException>().having(
          (e) => e.message,
          'message',
          contains('directly to an image'),
        ),
      ),
    );
  });

  test('reports HTTP failure codes', () async {
    final sources = ImageSources(
      client: MockClient((_) async => http.Response('', 404)),
    );
    addTearDown(sources.close);
    await expectLater(
      sources.fromUrl('https://example.com/missing.jpg'),
      throwsA(
        isA<ImageSourceException>().having(
          (e) => e.message,
          'message',
          contains('404'),
        ),
      ),
    );
  });

  test('invalid URL is rejected before a network request', () async {
    final sources = ImageSources(
      client: MockClient((_) async => throw StateError('Must not request')),
    );
    addTearDown(sources.close);
    for (final url in [
      'hello',
      'file:///photo.jpg',
      'http://example.com/photo.jpg',
    ]) {
      await expectLater(
        sources.fromUrl(url),
        throwsA(
          isA<ImageSourceException>().having(
            (e) => e.message,
            'message',
            contains('HTTPS'),
          ),
        ),
      );
    }
  });

  test('network failure gives a readable connection message', () async {
    final sources = ImageSources(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );
    addTearDown(sources.close);
    await expectLater(
      sources.fromUrl('https://example.com/image.jpg'),
      throwsA(
        isA<ImageSourceException>().having(
          (e) => e.message,
          'message',
          contains('internet connection'),
        ),
      ),
    );
  });

  test('slow response times out', () async {
    final response = Completer<http.Response>();
    final sources = ImageSources(
      client: MockClient((_) => response.future),
      timeout: const Duration(milliseconds: 5),
    );
    addTearDown(sources.close);
    await expectLater(
      sources.fromUrl('https://example.com/image.jpg'),
      throwsA(
        isA<ImageSourceException>().having(
          (e) => e.message,
          'message',
          contains('timed out'),
        ),
      ),
    );
    response.complete(
      http.Response('', 200, headers: {'content-type': 'image/png'}),
    );
  });

  test('rejects images exceeding the download size limit', () async {
    final sources = ImageSources(
      client: MockClient.streaming(
        (_, _) async => http.StreamedResponse(
          const Stream.empty(),
          200,
          contentLength: ImageSources.maxDownloadBytes + 1,
          headers: {'content-type': 'image/png'},
        ),
      ),
    );
    addTearDown(sources.close);
    await expectLater(
      sources.fromUrl('https://example.com/large.png'),
      throwsA(
        isA<ImageSourceException>().having(
          (e) => e.message,
          'message',
          contains('20 MB'),
        ),
      ),
    );
  });
}

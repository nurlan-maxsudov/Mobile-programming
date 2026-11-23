import 'dart:async';
import 'dart:io';
import 'dart:typed_data' show BytesBuilder;

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageSourceException implements Exception {
  const ImageSourceException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ImageSources {
  ImageSources({
    ImagePicker? picker,
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  }) : _picker = picker ?? ImagePicker(),
       _client = client ?? http.Client();

  final ImagePicker _picker;
  final http.Client _client;
  final Duration timeout;
  static const maxDownloadBytes = 20 * 1024 * 1024;

  Future<Uint8List?> fromCamera() => _pick(ImageSource.camera);
  Future<Uint8List?> fromGallery() => _pick(ImageSource.gallery);

  Future<Uint8List?> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, maxWidth: 1024);
      return file == null ? null : await file.readAsBytes();
    } on PlatformException catch (error) {
      if (error.code.toLowerCase().contains('denied')) {
        throw const ImageSourceException(
          'Photo access was denied. Allow access in your device settings and try again.',
        );
      }
      throw ImageSourceException(
        source == ImageSource.camera
            ? 'Could not open the camera. Check that a camera is available, or choose a photo from the gallery.'
            : 'Could not open the gallery. Please try again.',
      );
    } catch (_) {
      throw const ImageSourceException(
        'Could not read the selected photo. Please choose another image.',
      );
    }
  }

  static Uri parseUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      throw const ImageSourceException(
        'Enter a direct HTTPS image URL, such as https://example.com/photo.jpg.',
      );
    }
    return uri;
  }

  Future<Uint8List> fromUrl(String value) async {
    final uri = parseUrl(value);
    final abort = Completer<void>();
    try {
      return await _download(uri, abort.future).timeout(timeout);
    } on TimeoutException {
      throw const ImageSourceException(
        'The download timed out. Check your connection and try again.',
      );
    } on ImageSourceException {
      rethrow;
    } on SocketException {
      throw const ImageSourceException(
        'Could not connect. Check your internet connection and the image address.',
      );
    } on http.ClientException {
      throw const ImageSourceException(
        'Could not download the image. Check the address and your internet connection.',
      );
    } finally {
      if (!abort.isCompleted) abort.complete();
    }
  }

  Future<Uint8List> _download(Uri uri, Future<void> abort) async {
    final response = await _client.send(
      http.AbortableRequest('GET', uri, abortTrigger: abort),
    );
    if (response.statusCode != 200) {
      await response.stream.listen((_) {}).cancel();
      throw ImageSourceException(
        'The server returned HTTP ${response.statusCode}. Try another image URL.',
      );
    }
    final contentType =
        response.headers['content-type']?.trim().toLowerCase() ?? '';
    if (!contentType.startsWith('image/')) {
      await response.stream.listen((_) {}).cancel();
      throw const ImageSourceException(
        'That address returned a web page or other file. Use a link directly to an image.',
      );
    }
    if ((response.contentLength ?? 0) > maxDownloadBytes) {
      await response.stream.listen((_) {}).cancel();
      throw const ImageSourceException(
        'This image is too large. Choose an image smaller than 20 MB.',
      );
    }
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in response.stream.timeout(timeout)) {
      if (bytes.length + chunk.length > maxDownloadBytes) {
        throw const ImageSourceException(
          'This image is too large. Choose an image smaller than 20 MB.',
        );
      }
      bytes.add(chunk);
    }
    return bytes.takeBytes();
  }

  void close() => _client.close();
}

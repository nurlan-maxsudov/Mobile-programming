import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/product_page.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProductApi {
  ProductApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _host = 'dummyjson.com';

  Future<ProductPage> getProducts({int limit = 20, int skip = 0}) async {
    final uri = Uri.https(_host, '/products', {
      'limit': '$limit',
      'skip': '$skip',
    });
    return ProductPage.fromJson(await _get(uri));
  }

  Future<Product> getProduct(int id) async {
    final uri = Uri.https(_host, '/products/$id');
    return Product.fromJson(await _get(uri));
  }

  Future<ProductPage> search(String query) async {
    final uri = Uri.https(_host, '/products/search', {'q': query});
    return ProductPage.fromJson(await _get(uri));
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw ApiException(
          'The server returned an error (${response.statusCode}). Please try again.',
        );
      }
      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object.');
      }
      return json;
    } on TimeoutException {
      throw const ApiException('The request took too long. Please try again.');
    } on http.ClientException {
      throw const ApiException(
        'Could not connect to the server. Check your internet connection and try again.',
      );
    } on FormatException {
      throw const ApiException(
        'The server sent an invalid response. Please try again.',
      );
    }
  }

  void close() => _client.close();
}

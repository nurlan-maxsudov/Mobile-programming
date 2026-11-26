import 'dart:convert';
import 'dart:io';

import 'package:api_catalog/models/product.dart';
import 'package:api_catalog/models/product_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the saved product and page with nested models', () {
    final json = jsonDecode(
      File('test/fixtures/product.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final product = Product.fromJson(json);

    expect(product.title, 'Essence Mascara Lash Princess');
    expect(product.price, isA<double>());
    expect(product.price, 9.99);
    expect(product.rating, 2.56);
    expect(product.brand, 'Essence');
    expect(product.tags, ['beauty', 'mascara']);
    expect(product.dimensions.width, 15.14);
    expect(product.dimensions.height, 13.08);
    expect(product.dimensions.depth, 22.99);
    expect(product.reviews, hasLength(3));
    expect(product.reviews.first.rating, 3);
    expect(product.reviews.first.comment, 'Would not recommend!');
    expect(product.reviews.first.reviewerName, 'Eleanor Collins');
    expect(product.reviews.first.date, DateTime.utc(2025, 4, 30, 9, 41, 2, 53));
    expect(product.description, json['description']);
    expect(product.images, json['images']);
    expect(product.thumbnail, json['thumbnail']);

    final page = ProductPage.fromJson({
      'products': [json],
      'total': 1,
      'skip': 0,
      'limit': 20,
    });
    expect(page.products.single.title, product.title);
    expect(page.products.single.reviews, hasLength(3));
    expect(page.total, 1);
    expect(page.skip, 0);
    expect(page.limit, 20);
  });

  test('handles missing brand and tags and converts integer numbers', () {
    final product = Product.fromJson({
      'id': 2,
      'title': 'Test product',
      'price': 10,
      'rating': 4,
      'thumbnail': 'https://example.com/thumbnail.png',
      'dimensions': {'width': 1, 'height': 2, 'depth': 3},
      'reviews': <Map<String, dynamic>>[],
      'description': 'A product for testing.',
      'images': <String>[],
    });

    expect(product.brand, isNull);
    expect(product.tags, isEmpty);
    expect(product.price, isA<double>());
    expect(product.price, 10.0);
    expect(product.rating, isA<double>());
    expect(product.rating, 4.0);
    expect(product.dimensions.width, isA<double>());
    expect(product.dimensions.width, 1.0);
    expect(product.dimensions.height, 2.0);
    expect(product.dimensions.depth, 3.0);
  });
}

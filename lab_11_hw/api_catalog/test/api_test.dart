import 'dart:convert';
import 'dart:io';

import 'package:api_catalog/data/product_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('getProducts returns one product from a mocked page', () async {
    final fixture = jsonDecode(
      File('test/fixtures/product.json').readAsStringSync(),
    );
    final api = ProductApi(
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.scheme, 'https');
        expect(request.url.host, 'dummyjson.com');
        expect(request.url.path, '/products');
        expect(request.url.queryParameters, {'limit': '20', 'skip': '0'});
        return http.Response(
          jsonEncode({
            'products': [fixture],
            'total': 1,
            'skip': 0,
            'limit': 20,
          }),
          200,
        );
      }),
    );
    addTearDown(api.close);

    final page = await api.getProducts();

    expect(page.products, hasLength(1));
    expect(page.products.single.id, 1);
    expect(page.products.single.title, 'Essence Mascara Lash Princess');
    expect(page.total, 1);
    expect(page.skip, 0);
    expect(page.limit, 20);
  });

  test('getProduct turns HTTP 404 into an ApiException', () async {
    final api = ProductApi(
      client: MockClient((request) async {
        expect(request.url.path, '/products/0');
        return http.Response(
          jsonEncode({'message': "Product with id '0' not found"}),
          404,
        );
      }),
    );
    addTearDown(api.close);

    await expectLater(
      api.getProduct(0),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          'The server returned an error (404). Please try again.',
        ),
      ),
    );
  });
}

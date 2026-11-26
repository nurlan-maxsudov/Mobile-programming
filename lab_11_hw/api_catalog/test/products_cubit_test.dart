import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_catalog/cubit/products_cubit.dart';
import 'package:api_catalog/cubit/products_state.dart';
import 'package:api_catalog/data/product_api.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final fixture = jsonDecode(
    File('test/fixtures/product.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  http.Response page({int id = 1, int total = 1, int skip = 0}) {
    return http.Response(
      jsonEncode({
        'products': [
          {...fixture, 'id': id},
        ],
        'total': total,
        'skip': skip,
        'limit': 20,
      }),
      200,
    );
  }

  blocTest<ProductsCubit, ProductsState>(
    'load emits loading then loaded on success',
    build: () {
      final api = ProductApi(client: MockClient((_) async => page()));
      addTearDown(api.close);
      return ProductsCubit(api);
    },
    act: (cubit) => cubit.load(),
    expect: () => [isA<ProductsLoading>(), isA<ProductsLoaded>()],
    verify: (cubit) {
      final state = cubit.state as ProductsLoaded;
      expect(state.products.single.title, 'Essence Mascara Lash Princess');
      expect(state.total, 1);
      expect(state.hasMore, isFalse);
    },
  );

  blocTest<ProductsCubit, ProductsState>(
    'load emits loading then error on failure',
    build: () {
      final api = ProductApi(
        client: MockClient((_) async => http.Response('Server error', 500)),
      );
      addTearDown(api.close);
      return ProductsCubit(api);
    },
    act: (cubit) => cubit.load(),
    expect: () => [isA<ProductsLoading>(), isA<ProductsError>()],
    verify: (cubit) =>
        expect((cubit.state as ProductsError).message, contains('500')),
  );

  test('loadMore appends the next page and ignores a second tap', () async {
    final pending = Completer<http.Response>();
    final skips = <String?>[];
    final nextPageStarted = Completer<void>();
    final api = ProductApi(
      client: MockClient((request) async {
        skips.add(request.url.queryParameters['skip']);
        if (skips.length == 1) return page(total: 2);
        nextPageStarted.complete();
        return pending.future;
      }),
    );
    final cubit = ProductsCubit(api);
    addTearDown(api.close);
    addTearDown(cubit.close);

    await cubit.load();
    final loading = cubit.loadMore();
    await nextPageStarted.future;
    await cubit.loadMore();
    expect(skips, ['0', '1']);
    expect((cubit.state as ProductsLoaded).isLoadingMore, isTrue);
    pending.complete(page(id: 2, total: 2, skip: 1));
    await loading;

    final state = cubit.state as ProductsLoaded;
    expect(state.products.map((product) => product.id), [1, 2]);
    expect(state.hasMore, isFalse);
    expect(state.isLoadingMore, isFalse);
  });

  test(
    'refresh keeps the first page when an older loadMore finishes',
    () async {
      final pending = Completer<http.Response>();
      final api = ProductApi(
        client: MockClient((request) async {
          return request.url.queryParameters['skip'] == '0'
              ? page(total: 2)
              : pending.future;
        }),
      );
      final cubit = ProductsCubit(api);
      addTearDown(api.close);
      addTearDown(cubit.close);

      await cubit.load();
      final loading = cubit.loadMore();
      await cubit.load();
      pending.complete(page(id: 2, total: 2, skip: 1));
      await loading;

      expect((cubit.state as ProductsLoaded).products.single.id, 1);
    },
  );
}

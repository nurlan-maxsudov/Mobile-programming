import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/product_api.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._api) : super(const ProductsLoading());

  final ProductApi _api;
  int _request = 0;

  Future<void> load() async {
    final request = ++_request;
    emit(const ProductsLoading());
    try {
      final page = await _api.getProducts();
      if (isClosed || request != _request) return;
      emit(ProductsLoaded(page.products, total: page.total));
    } on ApiException catch (error) {
      if (!isClosed && request == _request) {
        emit(ProductsError(error.message));
      }
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! ProductsLoaded ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    final request = ++_request;
    emit(
      ProductsLoaded(
        current.products,
        total: current.total,
        isLoadingMore: true,
      ),
    );
    try {
      final page = await _api.getProducts(skip: current.products.length);
      if (isClosed || request != _request) return;
      emit(
        ProductsLoaded([
          ...current.products,
          ...page.products,
        ], total: page.total),
      );
    } on ApiException catch (error) {
      if (!isClosed && request == _request) {
        emit(
          ProductsLoaded(
            current.products,
            total: current.total,
            loadMoreError: error.message,
          ),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import '../widgets/product_tile.dart';
import 'details_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) => switch (state) {
          ProductsLoading() => const Center(child: CircularProgressIndicator()),
          ProductsError(:final message) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<ProductsCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          ProductsLoaded() => RefreshIndicator(
            onRefresh: context.read<ProductsCubit>().load,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.products.isEmpty ? 1 : state.products.length + 1,
              itemBuilder: (context, index) {
                if (state.products.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No products found.')),
                  );
                }
                if (index < state.products.length) {
                  final product = state.products[index];
                  return ProductTile(
                    product,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DetailsScreen(productId: product.id),
                      ),
                    ),
                  );
                }
                if (!state.hasMore) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (state.loadMoreError != null)
                        Text(state.loadMoreError!, textAlign: TextAlign.center),
                      TextButton(
                        onPressed: state.isLoadingMore
                            ? null
                            : context.read<ProductsCubit>().loadMore,
                        child: Text(
                          state.isLoadingMore
                              ? 'Loading...'
                              : '${state.loadMoreError == null ? 'Load more' : 'Retry'} (${state.products.length} of ${state.total})',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        },
      ),
    );
  }
}

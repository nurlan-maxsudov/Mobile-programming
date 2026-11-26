import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/details_cubit.dart';
import '../cubit/details_state.dart';
import '../data/product_api.dart';
import '../models/product.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({required this.productId, super.key});

  final int productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DetailsCubit(context.read<ProductApi>())..load(productId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Product details')),
        body: BlocBuilder<DetailsCubit, DetailsState>(
          builder: (context, state) => switch (state) {
            DetailsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            DetailsError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<DetailsCubit>().load(productId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            DetailsLoaded(:final product) => _ProductDetails(product),
          },
        ),
      ),
    );
  }
}

class _ProductDetails extends StatelessWidget {
  const _ProductDetails(this.product);

  final Product product;

  String _date(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(product.title, style: textTheme.headlineSmall),
        const SizedBox(height: 12),
        for (final image in product.images)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Image.network(
              image,
              height: 220,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 220,
                child: Icon(Icons.broken_image_outlined, size: 48),
              ),
            ),
          ),
        Text(product.description),
        const SizedBox(height: 16),
        Text('Dimensions', style: textTheme.titleMedium),
        Text('Width: ${product.dimensions.width}'),
        Text('Height: ${product.dimensions.height}'),
        Text('Depth: ${product.dimensions.depth}'),
        const SizedBox(height: 16),
        Text('Reviews', style: textTheme.titleMedium),
        if (product.reviews.isEmpty) const Text('No reviews yet.'),
        for (final review in product.reviews)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${review.reviewerName} · ${_date(review.date)}'),
                Text('${'★' * review.rating}${'☆' * (5 - review.rating)}'),
                const SizedBox(height: 4),
                Text(review.comment),
              ],
            ),
          ),
      ],
    );
  }
}

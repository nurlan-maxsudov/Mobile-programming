import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductTile extends StatelessWidget {
  const ProductTile(this.product, {required this.onTap, super.key});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(
        product.thumbnail,
        width: 56,
        height: 56,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox(
          width: 56,
          height: 56,
          child: Icon(Icons.broken_image_outlined),
        ),
      ),
      title: Text(product.title),
      subtitle: Text(
        '\$${product.price.toStringAsFixed(2)} · ★ ${product.rating.toStringAsFixed(1)}',
      ),
      onTap: onTap,
    );
  }
}

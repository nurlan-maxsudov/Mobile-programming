import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/products_cubit.dart';
import 'data/product_api.dart';
import 'screens/products_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => ProductApi(),
      dispose: (api) => api.close(),
      child: MaterialApp(
        title: 'Products',
        home: BlocProvider(
          create: (context) =>
              ProductsCubit(context.read<ProductApi>())..load(),
          child: const ProductsScreen(),
        ),
      ),
    );
  }
}

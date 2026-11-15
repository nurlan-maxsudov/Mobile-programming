import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'setstate/cart_page_setstate.dart';
import 'riverpod/cart_page_riverpod.dart';
import 'cubit/cart_page_cubit.dart';
import 'bloc/cart_page_bloc.dart';

void main() {
  Bloc.observer = CartObserver();
  runApp(const ProviderScope(child: MainApp()));
}

class CartObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    debugPrint('Bloc: $transition');
    super.onTransition(bloc, transition);
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'One Cart, Four Ways',
    home: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('One Cart, Four Ways')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final entry in <String, Widget>{
                'setState': const SetStateCartPage(),
                'Riverpod': const RiverpodCartPage(),
                'Cubit': const CubitCartPage(),
                'Bloc': const BlocCartPage(),
              }.entries)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => entry.value),
                    ),
                    child: Text(entry.key),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

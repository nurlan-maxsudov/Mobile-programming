
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/item/:id',
      name: 'item',
      builder: (context, state) =>
          ItemScreen(id: state.pathParameters['id']!),
    ),
  ],
  errorBuilder: (context, state) => const NotFoundScreen(),
);

void main() => runApp(MaterialApp.router(routerConfig: router));

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: const Text('Settings'),
              onPressed: () => context.goNamed('settings'),
            ),
            ElevatedButton(
              child: const Text('Item 42'),
              onPressed: () {
                context.goNamed(
                  'item',
                  pathParameters: {'id': '42'},
                );
              },
            ),
            ElevatedButton(
              child: const Text('Unknown Page'),
              onPressed: () => context.go('/unknown'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Home'),
          onPressed: () => context.goNamed('home'),
        ),
      ),
    );
  }
}

class ItemScreen extends StatelessWidget {
  final String id;

  const ItemScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item')),
      body: Center(
        child: Text('Item #$id'),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('404')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Page not found - Go Home'),
          onPressed: () => context.goNamed('home'),
        ),
      ),
    );
  }
}

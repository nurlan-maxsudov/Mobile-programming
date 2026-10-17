
import 'package:flutter/material.dart';

class AppRoutes {
  static const home = '/';
  static const profile = '/profile';
  static const messages = '/messages';
  static const about = '/about';
}

void main() {
  runApp(MaterialApp(
    initialRoute: AppRoutes.home,
    routes: {
      AppRoutes.home: (context) => const HomeScreen(),
      AppRoutes.profile: (context) => const SimpleScreen(title: 'Profile'),
      AppRoutes.messages: (context) => const SimpleScreen(title: 'Messages'),
      AppRoutes.about: (context) => const SimpleScreen(title: 'About'),
    },
  ));
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    void navigate(String route) {
      final navigator = Navigator.of(context);
      navigator.pop();
      navigator.pushReplacementNamed(route);
    }

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text('Menu')),
          ListTile(
            title: const Text('Home'),
            onTap: () => navigate(AppRoutes.home),
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () => navigate(AppRoutes.profile),
          ),
          ListTile(
            title: const Text('Messages'),
            onTap: () => navigate(AppRoutes.messages),
          ),
          ListTile(
            title: const Text('About'),
            onTap: () => navigate(AppRoutes.about),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimpleScreen(title: 'Home');
  }
}

class SimpleScreen extends StatelessWidget {
  final String title;

  const SimpleScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const AppDrawer(),
      body: Center(child: Text('$title Screen')),
    );
  }
}

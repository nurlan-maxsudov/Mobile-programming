
import 'package:flutter/material.dart';

class User {
  final String name;
  final int age;
  final String city;

  const User(this.name, this.age, this.city);
}

const users = [
  User('Ali', 20, 'Tashkent'),
  User('Bob', 22, 'Samarkand'),
  User('Sara', 19, 'Bukhara'),
  User('John', 21, 'Nukus'),
];

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    onGenerateRoute: (settings) {
      if (settings.name == '/') {
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
      }

      if (settings.name == '/profile') {
        final user = settings.arguments;

        if (user is User) {
          return MaterialPageRoute(
            builder: (context) => ProfileScreen(user: user),
          );
        }
      }

      return MaterialPageRoute(
        builder: (context) => const ErrorScreen(),
      );
    },
  ));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: ListView(
        children: [
          for (final user in users)
            ListTile(
              title: Text(user.name),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: user,
                );
              },
            ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: Center(
        child: Text('${user.name}, ${user.age}, ${user.city}'),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(child: Text('Invalid route or argument')),
    );
  }
}

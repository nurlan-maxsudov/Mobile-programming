
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
    routes: {
      '/': (context) => const HomeScreen(),
      '/profile': (context) => const ProfileScreen(),
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
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as User;

    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Name: ${user.name}'),
            Text('Age: ${user.age}'),
            Text('City: ${user.city}'),
          ],
        ),
      ),
    );
  }
}

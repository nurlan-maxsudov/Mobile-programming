
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const HomeScreen(),
      '/rate': (context) => const RateScreen(),
    },
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? rating;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movies')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rating == null ? 'Not rated yet' : 'Movie: $rating/5',
            ),
            ElevatedButton(
              child: const Text('Rate Movie'),
              onPressed: () async {
                final result = await Navigator.pushNamed<int>(
                  context,
                  '/rate',
                  arguments: 'Inception',
                );

                if (!mounted) return;

                if (result != null) {
                  setState(() {
                    rating = result;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RateScreen extends StatelessWidget {
  const RateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final movie = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: Text(movie)),
      body: Center(
        child: Wrap(
          children: [
            for (int i = 1; i <= 5; i++)
              IconButton(
                icon: const Icon(Icons.star),
                onPressed: () => Navigator.pop(context, i),
              ),
          ],
        ),
      ),
    );
  }
}

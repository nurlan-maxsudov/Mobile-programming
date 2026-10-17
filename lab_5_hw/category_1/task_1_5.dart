
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: HomeScreen()));

class BackOrExitButton extends StatelessWidget {
  const BackOrExitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.canPop(context);

    return ElevatedButton(
      child: Text(canGoBack ? 'Can go Back' : 'Nothing to go back to'),
      onPressed: canGoBack ? () => Navigator.pop(context) : null,
    );
  }
}

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
            const BackOrExitButton(),
            ElevatedButton(
              child: const Text('Open details'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DetailsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: const Center(
        child: BackOrExitButton(),
      ),
    );
  }
}

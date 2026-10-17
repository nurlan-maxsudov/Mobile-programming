
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: HomeScreen()));

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color currentColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Colour')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              color: currentColor,
            ),
            ElevatedButton(
              child: const Text('Choose colour'),
              onPressed: () async {
                final c = await Navigator.push<Color>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ColorScreen(),
                  ),
                );

                if (!mounted) return;

                if (c != null) {
                  setState(() {
                    currentColor = c;
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

class ColorScreen extends StatelessWidget {
  const ColorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Colour')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: const Text('Red'),
              onPressed: () => Navigator.pop(context, Colors.red),
            ),
            ElevatedButton(
              child: const Text('Green'),
              onPressed: () => Navigator.pop(context, Colors.green),
            ),
            ElevatedButton(
              child: const Text('Blue'),
              onPressed: () => Navigator.pop(context, Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

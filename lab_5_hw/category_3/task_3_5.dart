
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: HomeScreen()));

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int number = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Count: $number'),
            ElevatedButton(
              child: const Text('Edit'),
              onPressed: () async {
                final result = await Navigator.push<int>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditorScreen(number: number),
                  ),
                );

                if (!mounted) return;

                if (result != null) {
                  setState(() {
                    number = result;
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

class EditorScreen extends StatefulWidget {
  final int number;

  const EditorScreen({super.key, required this.number});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late int count;

  @override
  void initState() {
    super.initState();
    count = widget.number;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editor')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Count: $count'),
            ElevatedButton(
              child: const Text('+'),
              onPressed: () => setState(() => count++),
            ),
            ElevatedButton(
              child: const Text('-'),
              onPressed: () => setState(() => count--),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () => Navigator.pop(context, count),
            ),
          ],
        ),
      ),
    );
  }
}

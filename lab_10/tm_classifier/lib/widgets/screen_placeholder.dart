import 'package:flutter/material.dart';

/// Temporary shell until the reference design and screen behavior are added.
class ScreenPlaceholder extends StatelessWidget {
  const ScreenPlaceholder({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(description, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

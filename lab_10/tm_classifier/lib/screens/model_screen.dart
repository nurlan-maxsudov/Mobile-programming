import 'package:flutter/material.dart';

import '../services/classifier.dart';

class ModelScreen extends StatelessWidget {
  const ModelScreen({required this.labels, super.key});
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('What the model recognises', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final label in labels) Chip(label: Text(label))],
        ),
        const SizedBox(height: 24),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Number of classes'),
          subtitle: Text('${labels.length}'),
        ),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Input size'),
          subtitle: Text('224 × 224 pixels · RGB'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Model file'),
          subtitle: Text(Classifier.modelAsset.split('/').last),
        ),
        const SizedBox(height: 16),
        const Text(
          'Classification runs on your device. A high percentage is not a guarantee: unfamiliar objects can still be assigned to one of these classes.',
        ),
      ],
    );
  }
}

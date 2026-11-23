import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/classifier.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    required this.imageBytes,
    required this.predictions,
    required this.source,
    required this.duration,
    super.key,
  });

  final Uint8List imageBytes;
  final List<Prediction> predictions;
  final String source;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(source, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Center(
              child: Image.memory(
                imageBytes,
                height: MediaQuery.sizeOf(context).height * 0.4,
                fit: BoxFit.contain,
                semanticLabel: 'Classified photo',
                errorBuilder: (_, _, _) =>
                    const Text('Could not display this image.'),
              ),
            ),
            const SizedBox(height: 24),
            for (var i = 0; i < predictions.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            predictions[i].label,
                            style: i == 0
                                ? theme.textTheme.titleMedium
                                : theme.textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(predictions[i].confidence * 100).toStringAsFixed(1)}%',
                          style: i == 0 ? theme.textTheme.titleMedium : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: predictions[i].confidence,
                      color: i == 0
                          ? theme.colorScheme.primary
                          : theme.colorScheme.secondary,
                      semanticsLabel: predictions[i].label,
                      semanticsValue:
                          '${(predictions[i].confidence * 100).toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ),
            Text(
              'Processed on device in ${duration.inMilliseconds} ms',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

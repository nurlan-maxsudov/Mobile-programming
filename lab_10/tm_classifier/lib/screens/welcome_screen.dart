import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    required this.labels,
    required this.loadError,
    required this.sampleError,
    required this.busy,
    required this.onRetry,
    required this.onClassifySample,
    required this.onGetStarted,
    super.key,
  });

  final List<String>? labels;
  final String? loadError;
  final String? sampleError;
  final bool busy;
  final VoidCallback onRetry;
  final VoidCallback onClassifySample;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Image Classifier')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Recognise everyday objects',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            const Text('Classify photos on your phone, even offline.'),
            const SizedBox(height: 24),
            if (loadError != null) ...[
              Text(
                'Could not load the model',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(loadError!),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ] else if (labels == null) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 16),
              const Center(child: Text('Loading the model…')),
            ] else ...[
              Text('Ready to recognise', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final label in labels!) Chip(label: Text(label)),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: busy ? null : onGetStarted,
                child: const Text('Get started'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: busy ? null : onClassifySample,
                icon: const Icon(Icons.image_outlined),
                label: Text(busy ? 'Classifying…' : 'Classify sample photo'),
              ),
              if (busy) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
              if (sampleError != null) ...[
                const SizedBox(height: 16),
                Text(
                  sampleError!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

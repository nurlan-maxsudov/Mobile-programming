import 'package:flutter/material.dart';

import '../models/classification_record.dart';
import '../widgets/classification_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.busy,
    required this.status,
    required this.error,
    required this.latest,
    required this.onCamera,
    required this.onGallery,
    required this.onDownload,
    required this.onSample,
    required this.onOpenLatest,
    super.key,
  });

  final bool busy;
  final String? status;
  final String? error;
  final ClassificationRecord? latest;
  final VoidCallback onCamera, onGallery, onDownload, onSample, onOpenLatest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Try a new photo', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text('Keep the object near the centre of the photo.'),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: busy ? null : onCamera,
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text('Take a photo'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: busy ? null : onGallery,
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Choose from gallery'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: busy ? null : onDownload,
          icon: const Icon(Icons.download_outlined),
          label: const Text('Download an image'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: busy ? null : onSample,
          child: const Text('Classify sample photo'),
        ),
        if (busy) ...[
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Text(status ?? 'Working…', textAlign: TextAlign.center),
        ],
        if (error != null) ...[
          const SizedBox(height: 16),
          Text(error!, style: TextStyle(color: theme.colorScheme.error)),
        ],
        if (latest != null) ...[
          const SizedBox(height: 24),
          Text('Most recent result', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          ClassificationTile(record: latest!, onTap: onOpenLatest),
        ],
      ],
    );
  }
}

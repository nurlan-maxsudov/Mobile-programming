import 'package:flutter/material.dart';

import '../models/classification_record.dart';

class ClassificationTile extends StatelessWidget {
  const ClassificationTile({
    required this.record,
    required this.onTap,
    super.key,
  });
  final ClassificationRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (record.source) {
      ImageOrigin.camera => Icons.photo_camera_outlined,
      ImageOrigin.gallery => Icons.photo_library_outlined,
      ImageOrigin.download => Icons.download_outlined,
      ImageOrigin.sample => Icons.image_outlined,
    };
    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            record.bytes,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
          ),
        ),
        title: Text(record.top.label),
        subtitle: Text(
          '${(record.top.confidence * 100).toStringAsFixed(1)}% · ${record.source.label}',
        ),
        trailing: Icon(icon, semanticLabel: record.source.label),
        onTap: onTap,
      ),
    );
  }
}

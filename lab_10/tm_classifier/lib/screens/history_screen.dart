import 'package:flutter/material.dart';

import '../models/classification_record.dart';
import '../widgets/classification_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({required this.records, required this.onOpen, super.key});
  final List<ClassificationRecord> records;
  final ValueChanged<ClassificationRecord> onOpen;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history, size: 48),
              const SizedBox(height: 16),
              Text(
                'No photos classified yet',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a photo from Home. Results from this session will appear here.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (_, index) => ClassificationTile(
        record: records[index],
        onTap: () => onOpen(records[index]),
      ),
    );
  }
}

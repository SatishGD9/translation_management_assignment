import 'package:flutter/material.dart';
import 'package:translation_domain/translation_domain.dart';

class TranslationListItem extends StatelessWidget {
  final TranslationEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TranslationListItem({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key: ${entry.key}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...entry.translations.entries.map((mapEntry) {
              return Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2.0, bottom: 2.0),
                child: Text('${mapEntry.key.toUpperCase()}: ${mapEntry.value}'),
              );
            }).toList(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text('Edit'),
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.delete, size: 20),
                  label: const Text('Delete'),
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
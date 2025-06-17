import 'package:flutter/material.dart';
import 'package:translation_domain/translation_domain.dart';

import 'tool_tip.dart';

class TranslationListItem extends StatefulWidget {
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
  State<TranslationListItem> createState() => _TranslationListItemState();
}

class _TranslationListItemState extends State<TranslationListItem> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Translation key section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 250,
                  child: HoverTextOverlay(
                    text: widget.entry.key,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit Translation',
                      onPressed: widget.onEdit,
                      color: theme.colorScheme.primary,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      tooltip: 'Delete Translation',
                      onPressed: widget.onDelete,
                      color: theme.colorScheme.error,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),

            /// Translations list
            SizedBox(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: widget.entry.translations.entries.map((mapEntry) {
                  return ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 500,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HoverTextOverlay(
                            text: mapEntry.key.toUpperCase(),
                          ),
                          const SizedBox(height: 4),
                          HoverTextOverlay(
                            text: mapEntry.value,
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

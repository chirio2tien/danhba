import 'package:flutter/material.dart';
import '../../data/schemas/contact.dart';
import '../../utils/formatters.dart';

class NoteTimeline extends StatelessWidget {
  final Contact contact;
  final void Function(int noteId) onDelete;
  const NoteTimeline({super.key, required this.contact, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (contact.notes.isEmpty) {
      return Center(
        child: Text(
          'Chưa có ghi chú nào.',
          style: TextStyle(color: dark ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contact.notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final n = contact.notes[i];
        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: dark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                border: Border.all(color: dark ? const Color(0xFF334155) : Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.text, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, size: 14),
                      const SizedBox(width: 4),
                      Text(formatNoteDate(n.date),
                          style: TextStyle(fontSize: 11, color: dark ? Colors.grey.shade400 : Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                icon: const Icon(Icons.delete, size: 18),
                color: Colors.red,
                tooltip: 'Xóa ghi chú',
                onPressed: () => onDelete(n.id),
              ),
            )
          ],
        );
      },
    );
  }
}
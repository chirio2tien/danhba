import 'package:flutter/material.dart';
import '../../data/schemas/group.dart';
import '../../theme/ui_colors.dart';

class GroupBadge extends StatelessWidget {
  final Group? group;
  final bool dark;
  const GroupBadge({super.key, required this.group, required this.dark});

  @override
  Widget build(BuildContext context) {
    if (group == null) {
      return _pill('Khác', Colors.grey);
    }
    final col = UiColors.groupColor(group!.color);
    return _pill(group!.label, col);
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: color.withOpacity(0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder, size: 10, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/group_providers.dart';

const _icons = [
  Icons.work, Icons.favorite, Icons.coffee, Icons.tag, Icons.group,
  Icons.home, Icons.star, Icons.flash_on, Icons.music_note, Icons.table_rows,
  Icons.emoji_emotions, Icons.public, Icons.card_giftcard, Icons.workspace_premium,
  Icons.place,
];

const _colors = ['blue','pink','amber','green','purple','red'];

class GroupCreateModal extends ConsumerStatefulWidget {
  const GroupCreateModal({super.key});

  @override
  ConsumerState<GroupCreateModal> createState() => _GroupCreateModalState();
}

class _GroupCreateModalState extends ConsumerState<GroupCreateModal> {
  final _label = TextEditingController();
  String iconKey = 'tag';
  String color = 'blue';

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(Icons.folder_open, color: Color(0xFF4F46E5)),
                  SizedBox(width: 8),
                  Text('Tạo Nhóm Mới', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('TÊN NHÓM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: dark?Colors.grey[300]:Colors.grey[700])),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _label,
                decoration: InputDecoration(
                  hintText: 'VD: Đồng nghiệp, CLB...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('BIỂU TƯỢNG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: dark?Colors.grey[300]:Colors.grey[700])),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _icons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (_, i) {
                  final selected = iconKey == i.toString();
                  return InkWell(
                    onTap: () => setState(() => iconKey = i.toString()),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: selected ? const Color(0xFFEEF2FF) : (dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                        border: Border.all(color: selected ? const Color(0xFF4F46E5) : Colors.transparent, width: 2),
                      ),
                      child: Icon(_icons[i], color: selected? const Color(0xFF4F46E5) : (dark?Colors.grey[400]:Colors.grey[600])),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('MÀU SẮC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: dark?Colors.grey[300]:Colors.grey[700])),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: _colors.map((c) {
                  final selected = c == color;
                  return GestureDetector(
                    onTap: () => setState(() => color = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: selected ? Colors.black54 : Colors.transparent, width: 2),
                        color: _mapColor(c),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () async {
                        if (_label.text.trim().isEmpty) return;
                        await ref.read(groupActionController).create(_label.text.trim(), color, 'tag');
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Tạo'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Color _mapColor(String c) {
    switch (c) {
      case 'blue': return Colors.blue;
      case 'pink': return Colors.pink;
      case 'amber': return Colors.amber;
      case 'green': return Colors.green;
      case 'purple': return Colors.purple;
      case 'red': return Colors.red;
      default: return Colors.grey;
    }
  }
}
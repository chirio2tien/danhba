import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/schemas/contact.dart';
import '../../data/schemas/group.dart';
import '../../utils/phone_launcher.dart';

class ContactListCard extends StatelessWidget {
  final Contact contact;
  final Group? group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onQR;
  final VoidCallback onToggleFavorite;

  const ContactListCard({
    super.key,
    required this.contact,
    required this.group,
    required this.onEdit,
    required this.onDelete,
    required this.onQR,
    required this.onToggleFavorite,
  });

  Future<void> _call(BuildContext context, bool dark) async {
    try {
      await callPhone(contact.phone);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không gọi được: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE0E7FF),
            backgroundImage: contact.avatarBase64 != null
                ? MemoryImage(base64Decode(contact.avatarBase64!))
                : null,
            child: contact.avatarBase64 == null
                ? Text(
                    contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                _groupBadge(group, dark),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Phone: desktop -> pill bấm gọi, mobile -> icon bấm gọi
          if (!isMobile) ...[
            _pillPhone(context, contact.phone, dark),
          ] else ...[
            IconButton(
              tooltip: 'Gọi',
              icon: Icon(Icons.phone, size: 18, color: dark ? Colors.grey[300] : Colors.grey[700]),
              onPressed: () => _call(context, dark),
            ),
          ],

          const SizedBox(width: 6),

          if (!isMobile) ...[
            IconButton(
              onPressed: onToggleFavorite,
              icon: Icon(
                Icons.star,
                color: contact.isFavorite ? Colors.amber : (dark ? Colors.grey[500] : Colors.grey[400]),
                size: 20,
              ),
              tooltip: 'Yêu thích',
            ),
            IconButton(onPressed: onQR, icon: const Icon(Icons.qr_code_2, size: 20)),
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, size: 20)),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, size: 20, color: Colors.red)),
          ] else ...[
            PopupMenuButton<String>(
              tooltip: 'Tùy chọn',
              onSelected: (v) {
                switch (v) {
                  case 'fav':
                    onToggleFavorite();
                    break;
                  case 'qr':
                    onQR();
                    break;
                  case 'edit':
                    onEdit();
                    break;
                  case 'del':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'fav',
                  child: Text(contact.isFavorite ? 'Bỏ yêu thích' : 'Yêu thích'),
                ),
                const PopupMenuItem(value: 'qr', child: Text('Hiện QR')),
                const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                const PopupMenuItem(value: 'del', child: Text('Xóa')),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Icon(Icons.more_vert, color: dark ? Colors.grey[300] : Colors.grey[700]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _groupBadge(Group? group, bool dark) {
    if (group == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF334155) : Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text('Khác', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      );
    }
    final col = _mapColor(group.color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: col.withOpacity(.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        group.label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: col),
      ),
    );
  }

  Widget _pillPhone(BuildContext context, String phone, bool dark) {
    return InkWell(
      onTap: () => _call(context, dark),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: dark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
          border: Border.all(color: dark ? const Color(0xFF475569) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone, size: 16, color: dark ? Colors.grey[200] : Colors.grey[700]),
            const SizedBox(width: 6),
            Text(phone, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Color _mapColor(String c) {
    switch (c) {
      case 'blue':
        return Colors.blue;
      case 'pink':
        return Colors.pink;
      case 'amber':
        return Colors.amber;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
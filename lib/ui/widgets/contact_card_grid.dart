import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/schemas/contact.dart';
import '../../data/schemas/group.dart';
import '../../utils/phone_launcher.dart';

class ContactGridCardExtended extends StatelessWidget {
  final Contact contact;
  final Group? group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onQR;
  final VoidCallback onToggleFavorite;

  const ContactGridCardExtended({
    super.key,
    required this.contact,
    required this.group,
    required this.onEdit,
    required this.onDelete,
    required this.onQR,
    required this.onToggleFavorite,
  });

  Future<void> _call(BuildContext context) async {
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

    return Container(
      constraints: const BoxConstraints(minHeight: 320), // đảm bảo đủ cao
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar + Favorite
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: const Color(0xFFE0E7FF),
                    backgroundImage: contact.avatarBase64 != null
                        ? MemoryImage(base64Decode(contact.avatarBase64!))
                        : null,
                    child: contact.avatarBase64 == null
                        ? Text(
                            contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: InkWell(
                      onTap: onToggleFavorite,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: contact.isFavorite
                              ? Colors.amber.withOpacity(.30)
                              : (dark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.star,
                          size: 18,
                          color: contact.isFavorite ? Colors.amber : (dark ? Colors.grey[400] : Colors.grey[500]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),
          _groupBadge(group, dark),
          const SizedBox(height: 16),

          Text(
            contact.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          Text(
            contact.email ?? 'Chưa có email',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: dark ? Colors.grey[400] : Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 18),

          // Phone pill: bấm vào là gọi (KHÔNG dùng IconButton bên trong để tránh double-tap area/rối layout)
          InkWell(
            onTap: () => _call(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: dark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                border: Border.all(color: dark ? const Color(0xFF475569) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone, size: 16, color: dark ? Colors.grey[200] : Colors.grey[700]),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      contact.phone,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _actionBtn(Icons.qr_code_2, onQR, dark),
              _actionBtn(Icons.edit, onEdit, dark),
              _actionBtn(Icons.delete, onDelete, dark, color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, VoidCallback onTap, bool dark, {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color ?? (dark ? Colors.grey[200] : Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _groupBadge(Group? group, bool dark) {
    if (group == null || group.id == 'none') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF334155) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Không nhóm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      );
    }
    final col = _mapColor(group.color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: col.withOpacity(.20), borderRadius: BorderRadius.circular(8)),
      child: Text(
        group.label.toLowerCase(),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: col),
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
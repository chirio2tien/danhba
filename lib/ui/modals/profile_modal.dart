import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/profile_providers.dart';
import '../../data/schemas/profile.dart';

class ProfileEditModal extends ConsumerStatefulWidget {
  final Profile profile;
  const ProfileEditModal({super.key, required this.profile});

  @override
  ConsumerState<ProfileEditModal> createState() => _ProfileEditModalState();
}

class _ProfileEditModalState extends ConsumerState<ProfileEditModal> {
  late TextEditingController name;
  late TextEditingController phone;
  late TextEditingController email;
  String? avatar;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.profile.name);
    phone = TextEditingController(text: widget.profile.phone);
    email = TextEditingController(text: widget.profile.email ?? '');
    avatar = widget.profile.avatarBase64;
  }

  Future<void> pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() => avatar = base64Encode(bytes));
    }
  }

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
              const Row(children: [
                Icon(Icons.settings, color: Color(0xFF4F46E5)),
                SizedBox(width: 8),
                Text('Sửa Danh Thiếp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: pickAvatar,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    border: Border.all(color: dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: avatar != null
                      ? ClipOval(child: Image.memory(base64Decode(avatar!), fit: BoxFit.cover))
                      : Icon(Icons.camera_alt_outlined, size: 36, color: dark?Colors.grey[400]:Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 28),
              _input('Tên hiển thị', name, Icons.person),
              const SizedBox(height: 16),
              _input('Số điện thoại', phone, Icons.phone, keyboard: TextInputType.phone),
              const SizedBox(height: 16),
              _input('Email', email, Icons.email, keyboard: TextInputType.emailAddress),
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
                      child: const Text('Đóng'),
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
                        await ref.read(profileControllerProvider).update(
                          name: name.text.trim(),
                          phone: phone.text.trim(),
                          email: email.text.trim(),
                          avatarBase64: avatar,
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Lưu'),
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

  Widget _input(String label, TextEditingController c, IconData icon, {TextInputType? keyboard}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          keyboardType: keyboard,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
          ),
        )
      ],
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';

import '../../data/schemas/contact.dart';
import '../../data/schemas/group.dart';
import '../../data/schemas/note.dart';
import '../../providers/contact_providers.dart';
import '../../providers/group_providers.dart';
import '../../repositories/contact_repository.dart';

class SidePanel extends ConsumerStatefulWidget {
  const SidePanel({super.key});

  @override
  ConsumerState<SidePanel> createState() => _SidePanelState();
}

class _SidePanelState extends ConsumerState<SidePanel> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emailCtrl;
  String groupId = 'none'; // 'none' = không nhóm, không hiển thị chip
  bool favorite = false;
  String tab = 'info';
  String? avatarBase64;
  final noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final st = ref.read(panelStateProvider);
    final c = st.editingContact;
    nameCtrl = TextEditingController(text: c?.name ?? '');
    phoneCtrl = TextEditingController(text: c?.phone ?? '');
    emailCtrl = TextEditingController(text: c?.email ?? '');
    groupId = (c?.groupId != null && c!.groupId != '') ? c.groupId : 'none';
    favorite = c?.isFavorite ?? false;
    avatarBase64 = c?.avatarBase64;
    tab = st.tab;
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() => avatarBase64 = base64Encode(bytes));
    }
  }

  @override
  Widget build(BuildContext context) {
    final panel = ref.watch(panelStateProvider);
    final groups = ref.watch(groupsStreamProvider).maybeWhen(data: (d) => d, orElse: () => <Group>[]);
    final dark = Theme.of(context).brightness == Brightness.dark;

    // Watch realtime contact khi đang sửa
    Contact? liveEditing;
    if (panel.editing && panel.editingContact != null) {
      final stream = ref.watch(contactByIdStreamProvider(panel.editingContact!.id));
      liveEditing = stream.maybeWhen(data: (d) => d, orElse: () => panel.editingContact);
    }
    final notes = panel.editing ? (liveEditing?.notes ?? <Note>[]) : panel.tempNotes;

    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      width: 400,
      child: Material(
        elevation: 30,
        color: dark ? const Color(0xFF0F172A) : Colors.white,
        child: Column(
          children: [
            _header(panel, dark),
            _tabs(),
            const Divider(height: 1),
            Expanded(child: tab == 'info' ? _buildInfo(groups, dark) : _buildNotes(panel, dark, notes, liveEditing?.id)),
            if (tab == 'info') _saveButton(panel),
          ],
        ),
      ),
    );
  }

  Widget _header(PanelState panel, bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Text(panel.editing ? 'Chi Tiết' : 'Thêm Mới',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => ref.read(panelStateProvider.notifier).state = panel.copyWith(open: false),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Row(
      children: [
        _tabBtn('Thông tin', 'info'),
        _tabBtn('Ghi chú (${ref.watch(panelStateProvider).editing ? _currentNoteCount() : ref.watch(panelStateProvider).tempNotes.length})', 'notes'),
      ],
    );
  }

  int _currentNoteCount() {
    final panel = ref.read(panelStateProvider);
    if (!panel.editing || panel.editingContact == null) return 0;
    final stream = ref.read(contactByIdStreamProvider(panel.editingContact!.id));
    return stream.maybeWhen(data: (d) => d?.notes.length ?? 0, orElse: () => panel.editingContact!.notes.length);
  }

  Widget _tabBtn(String label, String value) {
    final active = tab == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => tab = value),
        child: Container(
          alignment: Alignment.center,
          height: 46,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? const Color(0xFF4F46E5) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: active ? const Color(0xFF4F46E5) : Colors.grey[500])),
        ),
      ),
    );
  }

  Widget _buildInfo(List<Group> groups, bool dark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickAvatar,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                border: Border.all(color: dark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
              alignment: Alignment.center,
              child: avatarBase64 == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 32, color: dark?Colors.grey[500]:Colors.grey[600]),
                        const SizedBox(height: 6),
                        Text('Chạm để tải ảnh lên', style: TextStyle(fontSize: 11, color: dark?Colors.grey[400]:Colors.grey[600])),
                      ],
                    )
                  : ClipOval(child: Image.memory(base64Decode(avatarBase64!), fit: BoxFit.cover, width: 120, height: 120)),
            ),
          ),
          const SizedBox(height: 28),
          _input('Họ và Tên', nameCtrl, Icons.person),
            const SizedBox(height: 16),
          _input('Số Điện Thoại', phoneCtrl, Icons.phone, keyboard: TextInputType.phone),
          const SizedBox(height: 16),
          _input('Email', emailCtrl, Icons.email, keyboard: TextInputType.emailAddress),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('NHÓM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: dark?Colors.grey[300]:Colors.grey[700])),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: groups.where((g) => g.id != 'none').map((g) {
              final active = groupId == g.id;
              return FilterChip(
                label: Text(g.label),
                selected: active,
                onSelected: (_) {
                  setState(() {
                    if (active) {
                      groupId = 'none'; // bấm lại để bỏ nhóm
                    } else {
                      groupId = g.id;
                    }
                  });
                },
                selectedColor: const Color(0xFFEEF2FF),
                checkmarkColor: const Color(0xFF4F46E5),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: active ? const Color(0xFF4F46E5) : (dark ? Colors.grey[300] : Colors.grey[700]),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => favorite = !favorite),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 50,
                  height: 28,
                  padding: const EdgeInsets.all(4),
                  alignment: favorite ? Alignment.centerRight : Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: favorite ? Colors.amber : (dark?Colors.grey[700]:Colors.grey[300]),
                  ),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Thêm vào mục Yêu thích', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 160),
        ],
      ),
    );
  }

  Widget _buildNotes(PanelState panel, bool dark, List notes, Id? contactId) {
    final editing = panel.editing;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Stack(
            children: [
              TextField(
                controller: noteCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Nhập ghi chú mới...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  onPressed: () async {
                    final text = noteCtrl.text.trim();
                    if (text.isEmpty) return;
                    if (editing && contactId != null) {
                      await ref.read(contactRepositoryProvider).addNote(contactId, text);
                    } else {
                      final entry = {
                        'id': DateTime.now().millisecondsSinceEpoch,
                        'text': text,
                        'date': DateTime.now().toIso8601String(),
                      };
                      ref.read(panelStateProvider.notifier).state =
                          panel.copyWith(tempNotes: [entry, ...panel.tempNotes]);
                    }
                    noteCtrl.clear();
                  },
                  child: const Icon(Icons.send, size: 18),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: notes.isEmpty
              ? Center(
                  child: Text(
                    'Chưa có ghi chú nào.',
                    style: TextStyle(color: dark?Colors.grey[400]:Colors.grey[600]),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: notes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    if (editing) {
                      final note = notes[i] as Note;
                      return _noteTile(
                        id: note.id,
                        text: note.text,
                        date: note.date,
                        editing: true,
                        dark: dark,
                        contactId: contactId,
                      );
                    } else {
                      final map = notes[i] as Map<String, dynamic>;
                      final date = DateTime.tryParse(map['date'] as String) ?? DateTime.now();
                      return _noteTile(
                        id: map['id'] as int,
                        text: map['text'] as String,
                        date: date,
                        editing: false,
                        dark: dark,
                      );
                    }
                  },
                ),
        ),
      ],
    );
  }

  Widget _noteTile({
    required int id,
    required String text,
    required DateTime date,
    required bool editing,
    required bool dark,
    Id? contactId,
  }) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')} ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}',
                    style: TextStyle(fontSize: 11, color: dark?Colors.grey[400]:Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            icon: const Icon(Icons.delete, size: 18),
            color: Colors.red,
            onPressed: () async {
              final panel = ref.read(panelStateProvider);
              if (editing && contactId != null) {
                await ref.read(contactRepositoryProvider).deleteNote(contactId, id);
              } else {
                final newList = [...panel.tempNotes]..removeWhere((x) => x['id'] == id);
                ref.read(panelStateProvider.notifier).state = panel.copyWith(tempNotes: newList);
              }
            },
          ),
        )
      ],
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
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        )
      ],
    );
  }

  Widget _saveButton(PanelState panel) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          onPressed: () async {
            if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thiếu tên hoặc SĐT')));
              }
              return;
            }
            final repo = ref.read(contactRepositoryProvider);
            if (panel.editing) {
              final c = panel.editingContact!;
              c.name = nameCtrl.text.trim();
              c.phone = phoneCtrl.text.trim();
              c.email = emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim();
              c.groupId = groupId; // 'none' nếu bỏ
              c.isFavorite = favorite;
              c.avatarBase64 = avatarBase64;
              await repo.update(c);
            } else {
              final c = Contact(
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                groupId: groupId,
                isFavorite: favorite,
                avatarBase64: avatarBase64,
              );
              await repo.add(c);
              if (panel.tempNotes.isNotEmpty) {
                for (final n in panel.tempNotes) {
                  await repo.addNote(c.id, n['text'] as String);
                }
              }
            }
            ref.read(panelStateProvider.notifier).state = panel.copyWith(open: false);
          },
          icon: const Icon(Icons.save),
          label: Text(panel.editing ? 'Lưu Thay Đổi' : 'Tạo Liên Hệ Mới'),
        ),
      ),
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/schemas/group.dart';
import '../../data/schemas/contact.dart';
import '../../providers/contact_providers.dart';
import '../../providers/group_providers.dart';
import '../../providers/profile_providers.dart';
import '../../repositories/contact_repository.dart';
import '../../utils/qr_utils.dart';

import '../widgets/contact_card_grid.dart';
import '../widgets/contact_card_list.dart';
import '../widgets/side_panel.dart';
import '../modals/group_modal.dart';
import '../modals/profile_modal.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openAdd(WidgetRef ref, List<Group> groups) {
    ref.read(panelStateProvider.notifier).state =
        PanelState(open: true, editing: false, tab: 'info');
  }

  void _openEdit(WidgetRef ref, Contact contact) {
    ref.read(panelStateProvider.notifier).state = PanelState(
      open: true,
      editing: true,
      editingContact: contact,
      tab: 'info',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark      = ref.watch(darkModeProvider);
    final profile   = ref.watch(profileStreamProvider).maybeWhen(data: (d) => d, orElse: () => null);
    final groups    = ref.watch(groupsStreamProvider).maybeWhen(data: (d) => d, orElse: () => <Group>[]);
    final panel     = ref.watch(panelStateProvider);
    final search    = ref.watch(searchProvider);
    final viewMode  = ref.watch(viewModeProvider);
    final activeTab = ref.watch(activeTabProvider);

    // Danh sách đã lọc để hiển thị nội dung
    final filteredContacts = ref.watch(filteredContactsProvider);

    // Danh sách đầy đủ để tính badge tổng & yêu thích
    final allContactsAsync = ref.watch(contactsStreamProvider);
    final allContacts = allContactsAsync.maybeWhen(data: (d) => d, orElse: () => <Contact>[]);

    final totalAll      = allContacts.length;
    final favoritesCount = allContacts.where((c) => c.isFavorite).length;

    return Scaffold(
      body: Row(
        children: [
          _sidebar(
            context: context,
            ref: ref,
            profile: profile,
            groups: groups,
            totalAll: totalAll,            // dùng tổng thực tế
            favoritesCount: favoritesCount,// dùng tổng yêu thích thực tế
            activeTab: activeTab,
            dark: dark,
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    _topBar(context, ref, search),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(48, 0, 48, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            Text(
                              activeTab == 'favorites'
                                  ? 'Danh bạ yêu thích'
                                  : activeTab == 'all'
                                      ? 'Tất cả danh bạ'
                                      : 'Nhóm ${groups.firstWhere(
                                          (g) => g.id == activeTab,
                                          orElse: () => Group(
                                            id: 'none',
                                            label: 'Đã xóa',
                                            color: 'gray',
                                            icon: 'tag',
                                          ),
                                        ).label}',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Đang hiển thị ${filteredContacts.length} liên hệ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Expanded(
                              child: filteredContacts.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.search_off,
                                              size: 72, color: Colors.grey),
                                          const SizedBox(height: 16),
                                          const Text('Chưa có dữ liệu phù hợp'),
                                          if (activeTab != 'all')
                                            TextButton(
                                              onPressed: () => ref
                                                  .read(activeTabProvider.notifier)
                                                  .state = 'all',
                                              child: const Text('Quay về tất cả'),
                                            )
                                        ],
                                      ),
                                    )
                                  : LayoutBuilder(
                                      builder: (context, constraints) {
                                        if (viewMode == 'list') {
                                          return ListView.separated(
                                            padding: const EdgeInsets.only(bottom: 120),
                                            itemCount: filteredContacts.length,
                                            separatorBuilder: (_, __) =>
                                                const SizedBox(height: 12),
                                            itemBuilder: (_, i) {
                                              final c = filteredContacts[i];
                                              final g = groups.firstWhere(
                                                (x) => x.id == c.groupId,
                                                orElse: () => Group(
                                                  id: 'none',
                                                  label: 'Khác',
                                                  color: 'gray',
                                                  icon: 'tag',
                                                ),
                                              );
                                              return ContactListCard(
                                                contact: c,
                                                group: g,
                                                onEdit: () => _openEdit(ref, c),
                                                onDelete: () async {
                                                  final repo = ref.read(contactRepositoryProvider);
                                                  await repo.delete(c.id);
                                                },
                                                onQR: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => AlertDialog(
                                                      title: const Text('Mã QR Danh Thiếp'),
                                                      content: QrImageView(
                                                        data: buildMeCardData(
                                                          name: c.name,
                                                          phone: c.phone,
                                                          email: c.email,
                                                        ),
                                                        size: 200,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                onToggleFavorite: () async {
                                                  await ref
                                                      .read(contactRepositoryProvider)
                                                      .toggleFavorite(c.id);
                                                },
                                              );
                                            },
                                          );
                                        } else {
                                        return LayoutBuilder(
  builder: (context, constraints) {
    final width = constraints.maxWidth;

    int cross = 3;
    if (width < 900) cross = 2;
    if (width < 600) cross = 1;

    final ratio = 0.85;

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: ratio,
      ),
      itemCount: filteredContacts.length,
      itemBuilder: (_, i) {
        final c = filteredContacts[i];
        final g = groups.firstWhere(
          (x) => x.id == c.groupId,
          orElse: () => Group(id: 'none', label: 'Không nhóm', color: 'gray', icon: 'tag'),
        );
        return ContactGridCardExtended(
          contact: c,
          group: g,
          onEdit: () => _openEdit(ref, c),
          onDelete: () async {
            final repo = ref.read(contactRepositoryProvider);
            await repo.delete(c.id);
          },
          onQR: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Mã QR Danh Thiếp'),
                content: QrImageView(
                  data: buildMeCardData(
                    name: c.name,
                    phone: c.phone,
                    email: c.email,
                  ),
                  size: 200,
                ),
              ),
            );
          },
          onToggleFavorite: () async {
            await ref.read(contactRepositoryProvider).toggleFavorite(c.id);
          },
        );
      },
    );
  },
);
                                        }
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (panel.open)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(panelStateProvider.notifier).state =
                            panel.copyWith(open: false);
                      },
                      child: Container(
                        color: Colors.black.withOpacity(.35),
                      ),
                    ),
                  ),
                if (panel.open) const SidePanel(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: MediaQuery.of(context).size.width < 900
          ? FloatingActionButton(
              onPressed: () => _openAdd(ref, groups),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // -------- SIDEBAR --------
  Widget _sidebar({
    required BuildContext context,
    required WidgetRef ref,
    required dynamic profile,
    required List<Group> groups,
    required int totalAll,
    required int favoritesCount,
    required String activeTab,
    required bool dark,
  }) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          right: BorderSide(
            color: dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _profileCard(context, ref, profile, dark),
          _sectionLabel('DANH MỤC', dark),
          _navItem(
            context,
            ref,
            icon: Icons.people,
            label: 'Tất cả liên hệ',
            count: totalAll, // luôn tổng tất cả
            active: activeTab == 'all',
            onTap: () => ref.read(activeTabProvider.notifier).state = 'all',
            dark: dark,
          ),
          _navItem(
            context,
            ref,
            icon: Icons.star,
            label: 'Yêu thích',
            count: favoritesCount, // luôn tổng yêu thích thật
            active: activeTab == 'favorites',
            onTap: () => ref.read(activeTabProvider.notifier).state = 'favorites',
            dark: dark,
          ),
          _groupsSection(context, ref, groups, activeTab, dark),
          _darkToggle(ref, dark),
        ],
      ),
    );
  }

  Widget _profileCard(BuildContext context, WidgetRef ref, dynamic profile, bool dark) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: () {
          if (profile == null) return;
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Mã QR Của Tôi'),
              content: QrImageView(
                data: buildMeCardData(
                  name: profile.name,
                  phone: profile.phone,
                  email: profile.email,
                ),
                size: 200,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF4F46E5),
                backgroundImage: profile?.avatarBase64 != null
                    ? MemoryImage(base64Decode(profile!.avatarBase64!))
                    : null,
                child: profile?.avatarBase64 == null
                    ? Text(
                        profile?.name.isNotEmpty == true ? profile!.name[0].toUpperCase() : 'N',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DANH THIẾP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: dark ? Colors.indigo[300] : const Color(0xFF4F46E5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(profile?.name ?? 'Loading...', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.qr_code_2, size: 12, color: dark ? Colors.indigo[300] : const Color(0xFF4F46E5)),
                        const SizedBox(width: 4),
                        Text(
                          'Chạm để hiện QR',
                          style: TextStyle(fontSize: 10, color: dark ? Colors.indigo[300] : const Color(0xFF4F46E5)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.settings, size: 20, color: dark ? Colors.grey[300] : Colors.black87),
                onPressed: () {
                  if (profile == null) return;
                  showDialog(context: context, builder: (_) => ProfileEditModal(profile: profile));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: dark ? Colors.grey[300] : Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _groupsSection(BuildContext context, WidgetRef ref, List<Group> groups, String activeTab, bool dark) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'NHÓM (${groups.where((g) => g.id != "none").length})',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: dark ? Colors.grey[300] : Colors.grey[700]),
                  ),
                ),
                InkWell(
                  onTap: () => showDialog(context: context, builder: (_) => const GroupCreateModal()),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.add, size: 18),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 12),
              children: groups.where((g) => g.id != 'none').map((g) {
                final active = activeTab == g.id;
                final color = _mapColor(g.color);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: InkWell(
                    onTap: () => ref.read(activeTabProvider.notifier).state = g.id,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: active ? (dark ? const Color(0xFF1E293B) : Colors.white) : Colors.transparent,
                        border: Border.all(
                          color: active
                              ? (dark ? const Color(0xFF334155) : const Color(0xFFE0E7FF))
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.wallet_travel, size: 18, color: color),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              g.label,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Xóa nhóm?'),
                                  content: const Text('Liên hệ sẽ chuyển sang “Không nhóm”.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ref.read(groupActionController).deleteAndUnassign(g.id);
                                if (ref.read(activeTabProvider) == g.id) {
                                  ref.read(activeTabProvider.notifier).state = 'all';
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(Icons.delete, size: 16, color: dark ? Colors.grey[400] : Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _darkToggle(WidgetRef ref, bool dark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: InkWell(
        onTap: () => ref.read(darkModeProvider.notifier).state = !dark,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(dark ? Icons.light_mode : Icons.dark_mode, size: 18),
              const SizedBox(width: 8),
              Text(dark ? 'Chế độ Sáng' : 'Chế độ Tối', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required int count,
    required bool active,
    required VoidCallback onTap,
    required bool dark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: active ? (dark ? const Color(0xFF1E293B) : Colors.white) : Colors.transparent,
            border: Border.all(
              color: active
                  ? (dark ? const Color(0xFF334155) : const Color(0xFFE0E7FF))
                  : Colors.transparent,
            ),
            boxShadow: active && !dark
                ? [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: active ? const Color(0xFF4F46E5) : (dark ? Colors.grey[300] : Colors.grey[700])),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: active
                        ? (dark ? Colors.white : const Color(0xFF1E293B))
                        : (dark ? Colors.grey[300] : Colors.grey[700]),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFEEF2FF)
                      : (dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    color: active
                        ? const Color(0xFF4F46E5)
                        : (dark ? Colors.grey[300] : Colors.grey[600]),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, WidgetRef ref, String search) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final viewMode = ref.watch(viewModeProvider);
    return Container(
      padding: const EdgeInsets.fromLTRB(48, 24, 48, 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Tìm kiếm danh bạ...',
                  filled: true,
                  fillColor: dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                  ),
                ),
                onChanged: (v) => ref.read(searchProvider.notifier).state = v,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              color: dark ? const Color(0xFF1E293B) : Colors.white,
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Grid',
                  onPressed: () => ref.read(viewModeProvider.notifier).state = 'grid',
                  icon: Icon(
                    Icons.grid_view,
                    color: viewMode == 'grid'
                        ? const Color(0xFF4F46E5)
                        : (dark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
                IconButton(
                  tooltip: 'List',
                  onPressed: () => ref.read(viewModeProvider.notifier).state = 'list',
                  icon: Icon(
                    Icons.view_list,
                    color: viewMode == 'list'
                        ? const Color(0xFF4F46E5)
                        : (dark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mock quét QR...')),
              );
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Quét QR'),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: () {
              final groupsLocal = ref.watch(groupsStreamProvider).maybeWhen(data: (d) => d, orElse: () => <Group>[]);
              _openAdd(ref, groupsLocal);
            },
            icon: const Icon(Icons.add),
            label: const Text('Thêm Mới', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
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
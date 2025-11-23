import 'package:isar/isar.dart';
import '../data/isar_service.dart';
import '../data/schemas/group.dart';
import '../data/schemas/contact.dart';

class GroupRepository {
  Future<List<Group>> getAll() async {
    final isar = await IsarService.instance();
    return isar.groups.where().findAll();
  }

  Stream<List<Group>> watchAll() async* {
    final isar = await IsarService.instance();
    yield* isar.groups.where().watch(fireImmediately: true);
  }

  Future<void> ensureDefaultGroups() async {
    final isar = await IsarService.instance();
    await isar.writeTxn(() async {
      final none = await isar.groups.filter().idEqualTo('none').findFirst();
      if (none == null) {
        await isar.groups.put(Group(
          id: 'none',
          label: 'Không nhóm',
          color: 'gray',
          icon: 'tag',
        ));
      }
      // Tuỳ chọn seed ban đầu
      final any = await isar.groups.where().findFirst();
      if (any == null) {
        await isar.groups.putAll([
          Group(id: 'work', label: 'Công việc', color: 'blue', icon: 'briefcase'),
          Group(id: 'family', label: 'Gia đình', color: 'pink', icon: 'heart'),
          Group(id: 'friends', label: 'Bạn bè', color: 'amber', icon: 'coffee'),
        ]);
      }
    });
  }

  Future<void> addGroup(String label, String color, String icon) async {
    final isar = await IsarService.instance();
    final id =
        '${label.toLowerCase().replaceAll(RegExp(r"\s+"), "-")}-${DateTime.now().millisecondsSinceEpoch}';
    final g = Group(id: id, label: label.trim(), color: color, icon: icon);
    await isar.writeTxn(() => isar.groups.put(g));
  }

  // Xoá nhóm và chuyển contact của nhóm sang 'none'
  Future<void> deleteAndUnassign(String customId) async {
    if (customId == 'none') return; // không xoá nhóm hệ thống
    final isar = await IsarService.instance();
    await isar.writeTxn(() async {
      final target =
          await isar.groups.filter().idEqualTo(customId).findFirst();
      if (target != null) {
        final affected =
            await isar.contacts.filter().groupIdEqualTo(customId).findAll();
        for (final c in affected) {
          c.groupId = 'none';
        }
        if (affected.isNotEmpty) {
          await isar.contacts.putAll(affected);
        }
        await isar.groups.delete(target.internalId);
      }
    });
  }
}
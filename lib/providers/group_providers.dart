import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/group_repository.dart';
import '../data/schemas/group.dart';

final groupRepositoryProvider = Provider((ref) => GroupRepository());

final groupsStreamProvider = StreamProvider<List<Group>>((ref) {
  final repo = ref.watch(groupRepositoryProvider);
  return repo.watchAll();
});

final groupActionController = Provider((ref) => _GroupActions(ref));

class _GroupActions {
  final Ref ref;
  _GroupActions(this.ref);

  Future<void> create(String label, String color, String icon) async {
    await ref.read(groupRepositoryProvider).addGroup(label, color, icon);
  }

  Future<void> deleteAndUnassign(String id) async {
    await ref.read(groupRepositoryProvider).deleteAndUnassign(id);
  }

  Future<void> ensureDefaults() async {
    await ref.read(groupRepositoryProvider).ensureDefaultGroups();
  }
}
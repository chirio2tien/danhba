import '../data/isar_service.dart';
import '../data/schemas/profile.dart';

class ProfileRepository {
  Future<Profile?> getProfile() async {
    final isar = await IsarService.instance();
    var p = await isar.profiles.get(1);
    if (p == null) {
      p = Profile(name: 'Nguyễn Văn Chủ', phone: '0909999999', email: 'admin@procrm.com');
      await isar.writeTxn(() => isar.profiles.put(p!));
    }
    return p;
  }

  Stream<Profile?> watchProfile() async* {
    final isar = await IsarService.instance();
    yield* isar.profiles.watchObject(1, fireImmediately: true);
  }

  Future<void> update(Profile p) async {
    final isar = await IsarService.instance();
    await isar.writeTxn(() => isar.profiles.put(p));
  }

  Future<void> updateFields({String? name, String? phone, String? email, String? avatarBase64}) async {
    final isar = await IsarService.instance();
    await isar.writeTxn(() async {
      final p = await isar.profiles.get(1);
      if (p == null) return;
      if (name != null) p.name = name;
      if (phone != null) p.phone = phone;
      if (email != null) p.email = email;
      if (avatarBase64 != null) p.avatarBase64 = avatarBase64;
      await isar.profiles.put(p);
    });
  }
}
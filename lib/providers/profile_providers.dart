import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/profile_repository.dart';
import '../data/schemas/profile.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

final profileStreamProvider = StreamProvider<Profile?>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.watchProfile();
});

final profileControllerProvider = Provider((ref) => _ProfileController(ref));
class _ProfileController {
  final Ref ref;
  _ProfileController(this.ref);

  Future<void> update({String? name, String? phone, String? email, String? avatarBase64}) async {
    await ref.read(profileRepositoryProvider).updateFields(
      name: name, phone: phone, email: email, avatarBase64: avatarBase64,
    );
  }
}
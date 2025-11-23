import 'package:isar/isar.dart';

part 'profile.g.dart';

@collection
class Profile {
  Id id = 1;
  late String name;
  late String phone;
  String? email;
  String? avatarBase64;

  Profile({
    required this.name,
    required this.phone,
    this.email,
    this.avatarBase64,
  });
}
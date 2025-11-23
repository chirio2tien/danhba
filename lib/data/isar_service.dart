import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'schemas/contact.dart';
import 'schemas/group.dart';
import 'schemas/profile.dart';

class IsarService {
  static Isar? _isar;
  static Future<Isar> instance() async {
    if (_isar != null) return _isar!;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        ContactSchema,
        GroupSchema,
        ProfileSchema,
      ],
      directory: dir.path,
      inspector: false,
    );
    return _isar!;
  }
}
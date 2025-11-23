import 'package:isar/isar.dart';
import 'note.dart';

part 'contact.g.dart';

@collection
class Contact {
  Id id = Isar.autoIncrement;

  late String name;
  late String phone;
  String? email;
  late String groupId;
  bool isFavorite = false;
  String? avatarBase64;

  final List<Note> notes;

  Contact({
    required this.name,
    required this.phone,
    this.email,
    required this.groupId,
    this.isFavorite = false,
    this.avatarBase64,
    List<Note> notes = const [],
  }) : notes = List<Note>.from(notes);
}
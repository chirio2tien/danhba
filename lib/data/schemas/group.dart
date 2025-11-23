import 'package:isar/isar.dart';

part 'group.g.dart';

@collection
class Group {
  Id internalId = Isar.autoIncrement; // không dùng bên ngoài
  late String id;    // custom id (label_slug + timestamp)
  late String label;
  late String color; // blue, pink, amber...
  late String icon;  // briefcase, heart...

  Group({
    required this.id,
    required this.label,
    required this.color,
    required this.icon,
  });
}
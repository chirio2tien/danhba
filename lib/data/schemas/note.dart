import 'package:isar/isar.dart';

part 'note.g.dart';

@embedded
class Note {
  int id = 0;
  String text = '';
  DateTime date = DateTime.now();

  // LƯU Ý: Không khai báo constructor cho embedded object
  // Sử dụng Note() và gán giá trị bằng cascade khi tạo mới.
}
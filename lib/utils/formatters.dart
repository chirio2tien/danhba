import 'package:intl/intl.dart';

String formatNoteDate(DateTime dt) {
  final f = DateFormat('dd/MM HH:mm');
  return f.format(dt);
}
import 'package:url_launcher/url_launcher.dart';

String _sanitizePhone(String input) {
  // giữ lại số và dấu +
  final s = input.trim();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final ch = s[i];
    final isDigit = ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
    if (isDigit || (ch == '+' && buf.isEmpty)) {
      buf.write(ch);
    }
  }
  return buf.toString();
}

Future<void> callPhone(String phone) async {
  final p = _sanitizePhone(phone);

  if (p.isEmpty) {
    throw Exception('Số điện thoại không hợp lệ');
  }

  final uri = Uri(scheme: 'tel', path: p);

  // Ép mở bằng app ngoài (dialer)
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

  if (!ok) {
    throw Exception('Không mở được app gọi điện trên thiết bị này');
  }
}
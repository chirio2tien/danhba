String buildMeCardData({
  required String name,
  required String phone,
  String? email,
}) {
  String esc(String s) => s.replaceAll(';', r'\;').replaceAll(':', r'\:').trim();

  final n = esc(name);
  final p = esc(phone);
  final e = email == null ? '' : esc(email);

  return 'MECARD:N:$n;TEL:$p;EMAIL:$e;;';
}
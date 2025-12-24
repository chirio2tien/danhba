class MeCardData {
  final String name;
  final String phone;
  final String? email;

  const MeCardData({required this.name, required this.phone, this.email});
}

// Parse QR dạng: MECARD:N:name;TEL:phone;EMAIL:email;;
MeCardData? parseMeCard(String raw) {
  final text = raw.trim();

  if (!text.toUpperCase().startsWith('MECARD:')) return null;

  // bỏ prefix MECARD:
  final body = text.substring(7);

  String? name;
  String? tel;
  String? email;

  // tách theo ';'
  final parts = body.split(';');
  for (final p in parts) {
    final part = p.trim();
    if (part.isEmpty) continue;

    final idx = part.indexOf(':');
    if (idx <= 0) continue;

    final key = part.substring(0, idx).toUpperCase();
    final value = part.substring(idx + 1);

    switch (key) {
      case 'N':
        name = value.trim();
        break;
      case 'TEL':
        tel = value.trim();
        break;
      case 'EMAIL':
        email = value.trim().isEmpty ? null : value.trim();
        break;
    }
  }

  if (name == null || name.isEmpty) return null;
  if (tel == null || tel.isEmpty) return null;

  return MeCardData(name: name, phone: tel, email: email);
}
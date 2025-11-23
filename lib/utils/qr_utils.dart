String buildMeCardData({
  required String name,
  required String phone,
  String? email,
}) {
  return 'MECARD:N:$name;TEL:$phone;EMAIL:${email ?? ''};;';
}
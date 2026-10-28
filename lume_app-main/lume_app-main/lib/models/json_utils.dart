num toNum(dynamic value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '') ?? 0;
}

List<String> toStringList(dynamic value) {
  if (value == null) return [];
  final raw = value is List
      ? value.map((e) => e.toString())
      : value.toString().split(RegExp(r'[,;]'));
  return raw.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}

bool toBool(dynamic value) {
  if (value is bool) return value;
  final s = value?.toString().trim().toLowerCase() ?? '';
  return s == 'true' || s == '1' || s == 'có' || s == 'co' || s == 'yes';
}

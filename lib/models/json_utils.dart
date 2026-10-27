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

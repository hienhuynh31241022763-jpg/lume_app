// HT-07 · Quy ước nội dung mã trên hộp giày / tem / poster (nhóm chốt 2026-11-01).
// - QR: "LUME:<id>". Đọc thêm được link "https://lume.vn/p/<id>" và id trần.
// - Mã vạch EAN-13 trên tem giá: "8936042" + id 5 số + 1 số kiểm tra.

const _qrPrefix = 'LUME:';
const _eanPrefix = '8936042';

/// Nội dung QR cho sản phẩm [id] (dùng khi in mã).
String qrFor(String id) => '$_qrPrefix$id';

/// Mã EAN-13 cho sản phẩm [id] có id là số (dùng khi in tem).
String ean13For(String id) {
  final body = '$_eanPrefix${id.padLeft(5, '0')}';
  return '$body${_checkDigit(body)}';
}

/// Đọc id sản phẩm từ nội dung mã quét được; không phải mã LUMÉ thì null.
String? productIdFromCode(String raw) {
  final s = raw.trim();
  if (s.toUpperCase().startsWith(_qrPrefix)) {
    final id = s.substring(_qrPrefix.length).trim();
    return id.isEmpty ? null : id;
  }
  final link = RegExp(r'lume\.vn/p/([\w-]+)').firstMatch(s);
  if (link != null) return link.group(1);
  if (RegExp(r'^\d{13}$').hasMatch(s)) {
    final body = s.substring(0, 12);
    if (!s.startsWith(_eanPrefix) || _checkDigit(body) != s[12]) return null;
    return int.parse(s.substring(_eanPrefix.length, 12)).toString();
  }
  if (RegExp(r'^\d{1,5}$').hasMatch(s)) return s;
  return null;
}

/// Số kiểm tra EAN-13: vị trí lẻ nhân 1, vị trí chẵn nhân 3.
String _checkDigit(String body12) {
  var sum = 0;
  for (var i = 0; i < body12.length; i++) {
    final d = int.parse(body12[i]);
    sum += i.isEven ? d : d * 3;
  }
  return ((10 - sum % 10) % 10).toString();
}

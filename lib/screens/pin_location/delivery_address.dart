/// HT-11 · Địa chỉ giao hàng đã ghim trên bản đồ.
/// Thanh toán (HT-01) ghi [orderText] vào `Order.address`.
class DeliveryAddress {
  const DeliveryAddress({
    required this.label,
    required this.line1,
    required this.line2,
    required this.lat,
    required this.lng,
    this.note = '',
  });

  /// Nhà riêng / Công ty / Khác.
  final String label;

  /// Số nhà, tên đường.
  final String line1;

  /// Phường, quận, tỉnh/thành.
  final String line2;
  final double lat;
  final double lng;

  /// Ghi chú cho shipper.
  final String note;

  static const labels = ['Nhà riêng', 'Công ty', 'Khác'];

  String get fullText => [line1, line2].where((s) => s.isNotEmpty).join(', ');

  /// Định dạng nhóm đã thống nhất:
  /// "[Nhà riêng] 279 Nguyễn Tri Phương, P.5, Q.10 · Ghi chú: …"
  String get orderText {
    final note = this.note.trim();
    return '[$label] $fullText${note.isEmpty ? '' : ' · Ghi chú: $note'}';
  }

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      label: (json['label'] ?? labels.first).toString(),
      line1: (json['line1'] ?? '').toString(),
      line2: (json['line2'] ?? '').toString(),
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      note: (json['note'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'line1': line1,
    'line2': line2,
    'lat': lat,
    'lng': lng,
    'note': note,
  };
}

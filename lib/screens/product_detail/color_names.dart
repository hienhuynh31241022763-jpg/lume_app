import 'package:flutter/material.dart';

/// Đổi tên màu tiếng Việt trong dữ liệu (VD: "Hồng phấn", "Đen tuyền")
/// sang mã màu để vẽ chấm màu. Tên dài / cụ thể đặt trước tên ngắn.
/// Dùng cho Chi tiết sản phẩm và Bộ lọc (phần của Uyên).
const List<(String, Color)> _table = [
  ('trong suốt', Color(0xFFE6F0F4)),
  ('ánh kim', Color(0xFFD9C38E)),
  ('bạc', Color(0xFFC9CCD1)),
  ('đỏ rượu', Color(0xFF8E2436)),
  ('fuchsia', Color(0xFFD63A8A)),
  ('trắng hồng', Color(0xFFFBE6EC)),
  ('hồng đào', Color(0xFFF4B6A6)),
  ('hồng nude', Color(0xFFE9C2B8)),
  ('hồng baby', Color(0xFFF7C9D6)),
  ('hồng nhạt', Color(0xFFF8D3DC)),
  ('hồng phấn', Color(0xFFD9798F)),
  ('lavender', Color(0xFFC7B6E2)),
  ('mint', Color(0xFFA8E0CF)),
  ('xanh non', Color(0xFFB5D98A)),
  ('xanh rêu', Color(0xFF5B6B3E)),
  ('vàng bơ', Color(0xFFF3DE8A)),
  ('vàng nhạt', Color(0xFFF6E7A8)),
  ('sô-cô-la', Color(0xFF5A3825)),
  ('nâu', Color(0xFF7B5137)),
  ('nude', Color(0xFFE3C3A8)),
  ('kem', Color(0xFFF1E6D2)),
  ('be', Color(0xFFE6D3B8)),
  ('xám', Color(0xFF9E9E9E)),
  ('trắng', Color(0xFFFFFFFF)),
  ('đen', Color(0xFF222222)),
  ('đỏ', Color(0xFFB3283B)),
  ('hồng', Color(0xFFE79AAE)),
  ('tím', Color(0xFFA98BD1)),
  ('xanh', Color(0xFF6FA8DC)),
  ('vàng', Color(0xFFE5C04B)),
];

Color colorFromName(String name) {
  final n = name.toLowerCase();
  for (final (key, color) in _table) {
    if (n.contains(key)) return color;
  }
  return const Color(0xFFBDBDBD);
}

/// Màu sáng thì dấu tích / viền vẽ màu tối cho dễ thấy.
bool isLightColor(Color c) => c.computeLuminance() > 0.6;
import 'package:flutter/material.dart';

import '../../models/product.dart';

/// MH-09 · Bộ lọc: logic
/// Trong cùng 1 nhóm là HOẶC (chọn Cao gót + Sandal → ra cả hai loại),
/// giữa các nhóm là VÀ (Cao gót VÀ size 37 VÀ màu Hồng).
/// File này chỉ có logic, không có giao diện, để dễ kiểm tra.

// ───────────────────────────── Sắp xếp ─────────────────────────────

enum SortOption {
  popular('Phổ biến'),
  priceAsc('Giá thấp → cao'),
  priceDesc('Giá cao → thấp'),
  newest('Mới nhất'),
  // TODO: API chưa có số lượng bán, tạm xếp theo đánh giá như Trang chủ.
  bestSeller('Bán chạy'),
  rating('Đánh giá cao');

  const SortOption(this.label);
  final String label;
}

// ─────────────────────── Nhóm chiều cao gót ───────────────────────

class HeelRange {
  const HeelRange(this.label, this.min, this.max);

  final String label;
  final double min;
  final double max;

  bool contains(double h) => h >= min && h <= max;
}

const heelRanges = [
  HeelRange('Bệt', 0, 1),
  HeelRange('2–4cm', 1.01, 4),
  HeelRange('5–7cm', 4.01, 7),
  HeelRange('8cm+', 7.01, 100),
];

// ───────────────────────── Nhóm màu ─────────────────────────
// Dữ liệu có hơn 25 tên màu khác nhau ("Hồng phấn", "Hồng đào", "Đen tuyền"…)
// nên gom về vài nhóm màu chính để bộ lọc gọn như prototype.

class ColorFamily {
  const ColorFamily(this.name, this.swatch, this.keywords);

  final String name;
  final Color swatch;
  final List<String> keywords;

  bool matches(String colorName) {
    final n = colorName.toLowerCase();
    return keywords.any(n.contains);
  }
}

const colorFamilies = [
  ColorFamily('Đen', Color(0xFF222222), ['đen']),
  ColorFamily('Trắng', Color(0xFFFFFFFF), ['trắng', 'trong suốt']),
  ColorFamily('Kem – Be', Color(0xFFE6D3B8), ['kem', 'be', 'nude']),
  ColorFamily('Hồng', Color(0xFFD9798F), ['hồng']),
  ColorFamily('Đỏ', Color(0xFFB3283B), ['đỏ']),
  ColorFamily('Nâu', Color(0xFF7B5137), ['nâu', 'sô-cô-la']),
  ColorFamily('Vàng – Ánh kim', Color(0xFFD9C38E), ['vàng', 'ánh kim', 'bạc']),
  ColorFamily('Xanh', Color(0xFF8FCFB8), ['xanh', 'mint']),
  ColorFamily('Tím', Color(0xFFB9A3DD), ['tím', 'lavender']),
  ColorFamily('Xám', Color(0xFF9E9E9E), ['xám']),
];

// ─────────────────────── Nhóm chất liệu ───────────────────────

const List<(String, List<String>)> materialGroups = [
  ('Da tổng hợp', ['tổng hợp', 'pu']),
  ('Da thật', ['da bò']),
  ('Da lộn – Nhung', ['lộn', 'suede', 'nhung']),
  ('Da bóng', ['bóng', 'patent']),
  ('Satin', ['satin']),
  ('Vải – Canvas', ['canvas', 'vải lưới']),
  ('Nhựa trong', ['pvc', 'nhựa']),
];

List<String> materialGroupsOf(String material) {
  final m = material.toLowerCase();
  return [
    for (final (name, keys) in materialGroups)
      if (keys.any(m.contains)) name,
  ];
}

/// Thứ tự hiển thị dịp dùng và loại giày (giống dữ liệu đã chuẩn hoá).
const occasionOrder = [
  'Đi học',
  'Đi làm',
  'Dự tiệc',
  'Dạo phố',
  'Hẹn hò',
  'Du lịch',
  'Thể thao',
];
const categoryOrder = [
  'Cao gót',
  'Sneaker',
  'Sandal',
  'Giày búp bê',
  'Boots',
  'Mules',
];
const allSizes = ['35', '36', '37', '38', '39', '40'];

// ───────────────────────── Khoảng giá ─────────────────────────

const _priceStep = 50000;

/// Giá thấp nhất / cao nhất trong danh sách, làm tròn theo bước 50.000₫.
RangeValues priceBounds(List<Product> products) {
  if (products.isEmpty) return const RangeValues(0, 1);
  var lo = products.first.price, hi = products.first.price;
  for (final p in products) {
    if (p.price < lo) lo = p.price;
    if (p.price > hi) hi = p.price;
  }
  final min = (lo ~/ _priceStep) * _priceStep;
  final max = ((hi + _priceStep - 1) ~/ _priceStep) * _priceStep;
  return RangeValues(min.toDouble(), (max == min ? min + _priceStep : max).toDouble());
}

int priceDivisions(RangeValues bounds) =>
    ((bounds.end - bounds.start) / _priceStep).round().clamp(1, 1000);

/// 350000 → "350K", 1250000 → "1,25tr"
String shortPrice(num v) {
  if (v >= 1000000) {
    var s = (v / 1000000).toStringAsFixed(2);
    s = s.replaceFirst(RegExp(r'\.?0+$'), '');
    return '${s.replaceAll('.', ',')}tr';
  }
  return '${(v / 1000).round()}K';
}

// ───────────────────────── Bộ lọc ─────────────────────────

class ActiveChip {
  const ActiveChip(this.label, this.withoutIt);

  final String label;

  /// Bộ lọc sau khi bỏ chip này.
  final ProductFilter withoutIt;
}

class ProductFilter {
  const ProductFilter({
    this.categories = const {},
    this.sizes = const {},
    this.colors = const {},
    this.heels = const {},
    this.occasions = const {},
    this.materials = const {},
    this.price,
    this.saleOnly = false,
    this.newOnly = false,
  });

  final Set<String> categories;
  final Set<String> sizes;
  final Set<String> colors; // tên nhóm màu (ColorFamily.name)
  final Set<String> heels; // HeelRange.label
  final Set<String> occasions;
  final Set<String> materials; // tên nhóm chất liệu
  final RangeValues? price; // null = không giới hạn giá
  final bool saleOnly;
  final bool newOnly;

  ProductFilter copyWith({
    Set<String>? categories,
    Set<String>? sizes,
    Set<String>? colors,
    Set<String>? heels,
    Set<String>? occasions,
    Set<String>? materials,
    RangeValues? price,
    bool clearPrice = false,
    bool? saleOnly,
    bool? newOnly,
  }) {
    return ProductFilter(
      categories: categories ?? this.categories,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      heels: heels ?? this.heels,
      occasions: occasions ?? this.occasions,
      materials: materials ?? this.materials,
      price: clearPrice ? null : (price ?? this.price),
      saleOnly: saleOnly ?? this.saleOnly,
      newOnly: newOnly ?? this.newOnly,
    );
  }

  int get activeCount =>
      categories.length +
      sizes.length +
      colors.length +
      heels.length +
      occasions.length +
      materials.length +
      (price != null ? 1 : 0) +
      (saleOnly ? 1 : 0) +
      (newOnly ? 1 : 0);

  bool get isEmpty => activeCount == 0;

  bool matches(Product p) {
    if (categories.isNotEmpty && !categories.contains(p.category)) {
      return false;
    }
    if (sizes.isNotEmpty && !p.sizes.any(sizes.contains)) return false;
    if (colors.isNotEmpty) {
      final families = colorFamilies.where((f) => colors.contains(f.name));
      if (!families.any((f) => p.colors.any(f.matches))) return false;
    }
    if (heels.isNotEmpty) {
      final ranges = heelRanges.where((h) => heels.contains(h.label));
      if (!ranges.any((h) => h.contains(p.heelHeight))) return false;
    }
    if (occasions.isNotEmpty && !p.occasions.any(occasions.contains)) {
      return false;
    }
    if (materials.isNotEmpty &&
        !materialGroupsOf(p.material).any(materials.contains)) {
      return false;
    }
    final range = price;
    if (range != null && (p.price < range.start || p.price > range.end)) {
      return false;
    }
    if (saleOnly && !p.hasDiscount) return false;
    if (newOnly && !p.isNew) return false;
    return true;
  }

  /// Lọc rồi sắp xếp. Không đổi danh sách gốc.
  List<Product> apply(List<Product> all, SortOption sort) {
    final list = all.where(matches).toList();
    int idOf(Product p) => int.tryParse(p.id) ?? 0;
    switch (sort) {
      case SortOption.popular:
        break;
      case SortOption.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.newest:
        list.sort((a, b) {
          if (a.isNew != b.isNew) return a.isNew ? -1 : 1;
          return idOf(b).compareTo(idOf(a));
        });
      case SortOption.bestSeller:
      case SortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  /// Các chip "đang chọn" hiện trên trang kết quả, bấm × để bỏ.
  List<ActiveChip> get chips {
    Set<String> minus(Set<String> s, String v) => {...s}..remove(v);
    final range = price;
    return [
      for (final c in categories)
        ActiveChip(c, copyWith(categories: minus(categories, c))),
      for (final s in sizes)
        ActiveChip('Size $s', copyWith(sizes: minus(sizes, s))),
      for (final c in colors)
        ActiveChip(c, copyWith(colors: minus(colors, c))),
      for (final h in heels)
        ActiveChip(h, copyWith(heels: minus(heels, h))),
      for (final o in occasions)
        ActiveChip(o, copyWith(occasions: minus(occasions, o))),
      for (final m in materials)
        ActiveChip(m, copyWith(materials: minus(materials, m))),
      if (range != null)
        ActiveChip(
          '${shortPrice(range.start)}–${shortPrice(range.end)}',
          copyWith(clearPrice: true),
        ),
      if (saleOnly) ActiveChip('Đang giảm giá', copyWith(saleOnly: false)),
      if (newOnly) ActiveChip('Hàng mới', copyWith(newOnly: false)),
    ];
  }
}

/// Thêm nếu chưa có, bỏ nếu đã có.
Set<String> toggleIn(Set<String> s, String v) =>
    s.contains(v) ? ({...s}..remove(v)) : {...s, v};
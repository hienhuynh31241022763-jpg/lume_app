import 'package:flutter/material.dart';

/// Icon cho từng loại giày.
///
/// Ảnh để trong assets/images/ (đã khai báo sẵn trong pubspec.yaml),
/// tên file chữ thường không dấu:
///   cat_cao_got.jpg · cat_sneaker.jpg · cat_sandal.jpg
///   cat_giay_bup_be.jpg · cat_boots.jpg · cat_mules.jpg
/// Loại nào chưa có ảnh thì tự hiện emoji, app không bị lỗi.

String emojiForCategory(String category) {
  final c = category.toLowerCase();
  if (c.contains('cao gót')) return '👠';
  if (c.contains('sneaker')) return '👟';
  if (c.contains('sandal')) return '👡';
  if (c.contains('búp bê')) return '🥿';
  if (c.contains('boot')) return '👢';
  if (c.contains('mule')) return '🩴';
  return '👞';
}

/// Đường dẫn ảnh icon của loại giày (null nếu loại lạ).
String? categoryImage(String category) {
  final c = category.toLowerCase();
  if (c.contains('cao gót')) return 'assets/images/cat_cao_got.jpg';
  if (c.contains('sneaker')) return 'assets/images/cat_sneaker.jpg';
  if (c.contains('sandal')) return 'assets/images/cat_sandal.jpg';
  if (c.contains('búp bê')) return 'assets/images/cat_giay_bup_be.jpg';
  if (c.contains('boot')) return 'assets/images/cat_boots.jpg';
  if (c.contains('mule')) return 'assets/images/cat_mules.jpg';
  return null;
}

/// Tên ngắn hiện dưới icon (giống prototype: "Búp bê" thay cho "Giày búp bê").
String shortCategoryLabel(String category) =>
    category.toLowerCase() == 'giày búp bê' ? 'Búp bê' : category;

/// Ảnh icon loại giày; chưa có file ảnh thì hiện emoji.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.category, this.size = 40});

  final String category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final emoji = Text(
      emojiForCategory(category),
      style: TextStyle(fontSize: size * 0.6),
    );
    final path = categoryImage(category);
    if (path == null) return emoji;
    // Ảnh có nền nên cắt tròn, phủ kín vòng tròn như ảnh đại diện.
    return ClipOval(
      child: Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Center(child: emoji),
      ),
    );
  }
}
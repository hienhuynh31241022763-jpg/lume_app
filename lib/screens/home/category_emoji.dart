/// Emoji tạm cho từng loại giày, dùng làm icon danh mục và ảnh giữ chỗ
/// khi sản phẩm chưa có ảnh. TODO: thay bằng ảnh thật khi có.
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

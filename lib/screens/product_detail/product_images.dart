import '../../data/api_client.dart';
import '../../models/product.dart';

/// Ảnh theo từng màu của sản phẩm.
///
/// API trả về thêm mảng `images`:
///   "images": [{"color": "Đỏ rượu", "url": "https://..."}, ...]
/// Model Product dùng chung chỉ đọc trường `image` (1 ảnh), nên màn Chi tiết
/// tự gọi lại /products/:id để lấy mảng này. Không cần sửa model của nhóm.
class ColorImage {
  const ColorImage(this.color, this.url);

  final String color;
  final String url;
}

final Map<String, List<ColorImage>> _cache = {};

/// Lấy danh sách ảnh theo màu. Lỗi mạng / không có mảng images thì trả về
/// danh sách rỗng, màn hình sẽ dùng ảnh `image` như cũ.
Future<List<ColorImage>> fetchColorImages(String productId) async {
  final cached = _cache[productId];
  if (cached != null) return cached;
  try {
    final data = await ApiClient.get('/products/$productId');
    final raw = data is Map ? data['images'] : null;
    final list = <ColorImage>[
      if (raw is List)
        for (final e in raw)
          if (e is Map && (e['url'] ?? '').toString().isNotEmpty)
            ColorImage(
              (e['color'] ?? '').toString().trim(),
              e['url'].toString().trim(),
            ),
    ];
    _cache[productId] = list;
    return list;
  } catch (_) {
    return const [];
  }
}

/// Ảnh của màu đang chọn.
/// - Màu có ảnh riêng → các ảnh đó.
/// - Màu chưa có ảnh → tất cả ảnh của sản phẩm.
/// - API không có mảng images → ảnh `image` duy nhất (hoặc rỗng).
List<String> imagesForColor(
  Product product,
  List<ColorImage> all,
  String? color,
) {
  final ofColor = [
    for (final img in all)
      if (color != null && img.color.toLowerCase() == color.toLowerCase())
        img.url,
  ];
  if (ofColor.isNotEmpty) return ofColor;
  if (all.isNotEmpty) return [for (final img in all) img.url];
  return product.image.isEmpty ? const [] : [product.image];
}
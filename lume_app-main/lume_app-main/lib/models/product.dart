import 'json_utils.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final int price;
  final int oldPrice;
  final double rating;
  final double heelHeight;
  final String material;
  final List<String> occasions;
  final bool isNew;
  final List<String> colors;
  final List<String> sizes;
  final String image;
  final String model3d;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.oldPrice,
    required this.rating,
    required this.heelHeight,
    required this.material,
    required this.occasions,
    required this.isNew,
    required this.colors,
    required this.sizes,
    required this.image,
    required this.model3d,
    required this.description,
  });

  bool get hasDiscount => oldPrice > price;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return ((oldPrice - price) / oldPrice * 100).round();
  }

  bool get has3d => model3d.isNotEmpty;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      price: toNum(json['price']).toInt(),
      oldPrice: toNum(json['oldPrice']).toInt(),
      rating: toNum(json['rating']).toDouble(),
      heelHeight: toNum(json['heelHeight']).toDouble(),
      material: (json['material'] ?? '').toString(),
      occasions: toStringList(json['occasions']),
      isNew: toBool(json['isNew']),
      colors: toStringList(json['colors']),
      sizes: toStringList(json['sizes']),
      image: (json['image'] ?? '').toString(),
      model3d: (json['model3d'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }
}

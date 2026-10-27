import 'json_utils.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final int price;
  final double heelHeight;
  final String material;
  final List<String> colors;
  final List<String> sizes;
  final String image;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.heelHeight,
    required this.material,
    required this.colors,
    required this.sizes,
    required this.image,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      price: toNum(json['price']).toInt(),
      heelHeight: toNum(json['heelHeight']).toDouble(),
      material: (json['material'] ?? '').toString(),
      colors: toStringList(json['colors']),
      sizes: toStringList(json['sizes']),
      image: (json['image'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }
}

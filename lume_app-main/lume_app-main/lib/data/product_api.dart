import '../models/product.dart';
import 'api_client.dart';

class ProductApi {
  Future<List<Product>> fetchProducts() async {
    final data = await ApiClient.get('/products');
    if (data is! List) {
      throw ApiException('Dữ liệu sản phẩm không hợp lệ');
    }
    return data
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Product> fetchProduct(String id) async {
    final data = await ApiClient.get('/products/$id');
    return Product.fromJson(Map<String, dynamic>.from(data as Map));
  }
}

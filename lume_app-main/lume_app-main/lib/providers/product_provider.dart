import 'package:flutter/foundation.dart';

import '../data/api_client.dart';
import '../data/product_api.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({ProductApi? api}) : _api = api ?? ProductApi();

  final ProductApi _api;

  List<Product> _products = [];
  bool _loading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _loading;
  String? get error => _error;

  List<String> get categories =>
      _products.map((p) => p.category).toSet().toList();

  Future<void> load({bool force = false}) async {
    if (_loading || (_products.isNotEmpty && !force)) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await _api.fetchProducts();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Không tải được sản phẩm';
    }
    _loading = false;
    notifyListeners();
  }

  Product? byId(String id) {
    return _products.where((p) => p.id == id).firstOrNull;
  }

  List<Product> byCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  List<Product> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _products;
    return _products
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q) ||
              p.material.toLowerCase().contains(q),
        )
        .toList();
  }
}

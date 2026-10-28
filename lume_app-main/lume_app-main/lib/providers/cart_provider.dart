import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  static const shippingFee = 30000;
  static const freeShipFrom = 1500000;
  static const _vouchers = {'LUME50K': 50000, 'WELCOME30K': 30000};

  final List<CartItem> _items = [];
  String? _voucherCode;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  String? get voucherCode => _voucherCode;

  int get count => _items.fold(0, (sum, i) => sum + i.quantity);
  int get subtotal => _items.fold(0, (sum, i) => sum + i.total);
  int get shipping =>
      _items.isEmpty || subtotal >= freeShipFrom ? 0 : shippingFee;
  int get discount {
    final value = _vouchers[_voucherCode] ?? 0;
    return value > subtotal ? subtotal : value;
  }

  int get total => subtotal - discount + shipping;

  void add(
    Product product, {
    required String size,
    required String color,
    int quantity = 1,
  }) {
    final index = _items.indexWhere(
      (i) => i.product.id == product.id && i.size == size && i.color == color,
    );
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          product: product,
          size: size,
          color: color,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void increase(CartItem item) {
    item.quantity += 1;
    notifyListeners();
  }

  void decrease(CartItem item) {
    if (item.quantity <= 1) {
      _items.remove(item);
    } else {
      item.quantity -= 1;
    }
    notifyListeners();
  }

  void remove(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  bool applyVoucher(String code) {
    final key = code.trim().toUpperCase();
    if (!_vouchers.containsKey(key)) return false;
    _voucherCode = key;
    notifyListeners();
    return true;
  }

  void removeVoucher() {
    _voucherCode = null;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _voucherCode = null;
    notifyListeners();
  }
}

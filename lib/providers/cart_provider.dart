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

  /// Tổng số lượng CẢ GIỎ (badge ở Chi tiết sản phẩm dùng số này).
  /// Tiền phải trả thì dùng nhóm `selected*` bên dưới.
  int get count => _items.fold(0, (sum, i) => sum + i.quantity);
  int get subtotal => _items.fold(0, (sum, i) => sum + i.total);
  int get shipping =>
      _items.isEmpty || subtotal >= freeShipFrom ? 0 : shippingFee;
  int get discount {
    final value = _vouchers[_voucherCode] ?? 0;
    return value > subtotal ? subtotal : value;
  }

  int get total => subtotal - discount + shipping;

  // ───── MH-15: chọn món để thanh toán ─────

  /// Các dòng đang được tick. Thanh toán chỉ lấy danh sách này.
  List<CartItem> get selectedItems =>
      List.unmodifiable(_items.where((i) => i.selected));

  /// Có ít nhất một dòng được tick (điều kiện bật nút Thanh toán).
  bool get hasSelection => _items.any((i) => i.selected);

  /// Giỏ không rỗng và mọi dòng đều được tick (trạng thái ô "Tất cả").
  bool get allSelected => _items.isNotEmpty && _items.every((i) => i.selected);

  int get selectedCount =>
      _items.fold(0, (sum, i) => i.selected ? sum + i.quantity : sum);

  int get selectedSubtotal =>
      _items.fold(0, (sum, i) => i.selected ? sum + i.total : sum);

  /// Xét trên tạm tính trước khi trừ voucher, giống [shipping].
  int get selectedShipping =>
      !hasSelection || selectedSubtotal >= freeShipFrom ? 0 : shippingFee;

  /// Voucher chỉ giảm trong phạm vi các món đã tick, để tổng không âm.
  int get selectedDiscount {
    final value = _vouchers[_voucherCode] ?? 0;
    return value > selectedSubtotal ? selectedSubtotal : value;
  }

  int get selectedTotal =>
      selectedSubtotal - selectedDiscount + selectedShipping;

  void toggleSelect(CartItem item, bool value) {
    if (item.selected == value) return;
    item.selected = value;
    notifyListeners();
  }

  void selectAll(bool value) {
    var changed = false;
    for (final item in _items) {
      if (item.selected != value) {
        item.selected = value;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  /// "Mua ngay": chỉ tick đúng biến thể vừa bấm, bỏ tick mọi dòng khác.
  void selectOnly(
    String productId, {
    required String size,
    required String color,
  }) {
    for (final item in _items) {
      item.selected =
          item.product.id == productId &&
          item.size == size &&
          item.color == color;
    }
    notifyListeners();
  }

  /// Nút "Xóa" ở màn giỏ: bỏ các dòng đã tick. Giữ voucher nếu giỏ còn hàng,
  /// vì người dùng chưa dùng mã đó để mua gì cả.
  void removeSelected() {
    if (!hasSelection) return;
    _items.removeWhere((i) => i.selected);
    if (_items.isEmpty) _voucherCode = null;
    notifyListeners();
  }

  /// Đặt hàng xong: bỏ các dòng vừa đặt và bỏ luôn voucher đã dùng (giữ lại
  /// thì phần giỏ còn lại được giảm lần hai bằng cùng một mã), rồi tick lại
  /// các dòng còn lại cho đúng mặc định "mở giỏ là tick sẵn".
  void clearOrdered() {
    _items.removeWhere((i) => i.selected);
    _voucherCode = null;
    for (final item in _items) {
      item.selected = true;
    }
    notifyListeners();
  }

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
      _items[index].selected = true; // MH-15: thêm vào giỏ là tick luôn.
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

  /// Đổi size/màu ngay trong giỏ. Trùng với dòng đã có thì gộp số lượng.
  void changeVariant(
    CartItem item, {
    required String size,
    required String color,
  }) {
    if (item.size == size && item.color == color) return;
    final index = _items.indexOf(item);
    if (index < 0) return;
    final same = _items.indexWhere(
      (i) =>
          i != item &&
          i.product.id == item.product.id &&
          i.size == size &&
          i.color == color,
    );
    if (same >= 0) {
      _items[same].quantity += item.quantity;
      // MH-15: gộp vào dòng chưa tick thì phải tick, kẻo tưởng mất hàng.
      _items[same].selected = _items[same].selected || item.selected;
      _items.removeAt(index);
    } else {
      _items[index] = CartItem(
        product: item.product,
        size: size,
        color: color,
        quantity: item.quantity,
        selected: item.selected, // MH-15: đổi size không được mất tick.
      );
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

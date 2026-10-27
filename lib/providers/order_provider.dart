import 'package:flutter/foundation.dart';

import '../data/api_client.dart';
import '../data/order_api.dart';
import '../models/order.dart';
import 'cart_provider.dart';

class OrderStatus {
  OrderStatus._();

  static const pending = 'Chờ xác nhận';
  static const shipping = 'Đang giao';
  static const delivered = 'Đã giao';
  static const cancelled = 'Đã hủy';
}

class OrderProvider extends ChangeNotifier {
  OrderProvider({OrderApi? api}) : _api = api ?? OrderApi();

  final OrderApi _api;

  List<Order> _orders = [];
  bool _loading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final list = await _api.fetchOrders();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _orders = list;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Không tải được đơn hàng';
    }
    _loading = false;
    notifyListeners();
  }

  Future<Order?> place({
    required CartProvider cart,
    required String customerName,
    required String phone,
    required String address,
    required String paymentMethod,
  }) async {
    final order = Order(
      id: '',
      customerName: customerName,
      phone: phone,
      address: address,
      paymentMethod: paymentMethod,
      status: OrderStatus.pending,
      items: cart.items.map((i) => i.toOrderItem()).toList(),
      total: cart.total,
      createdAt: DateTime.now(),
    );
    try {
      final created = await _api.createOrder(order);
      _orders.insert(0, created);
      cart.clear();
      _error = null;
      notifyListeners();
      return created;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> cancel(String id) async {
    try {
      await _api.updateStatus(id, OrderStatus.cancelled);
      await load();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null != null;
    }
  }
}

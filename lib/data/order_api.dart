import '../models/order.dart';
import 'api_client.dart';

class OrderApi {
  Future<List<Order>> fetchOrders() async {
    final data = await ApiClient.get('/orders');
    if (data is! List) {
      throw ApiException('Dữ liệu đơn hàng không hợp lệ');
    }
    return data
        .map((e) => Order.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Order> createOrder(Order order) async {
    final data = await ApiClient.post('/orders', order.toJson());
    return Order.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> updateStatus(String id, String status) async {
    await ApiClient.put('/orders/$id', {'status': status});
  }
}

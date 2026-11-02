import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lume_app/data/order_api.dart';
import 'package:lume_app/models/order.dart';
import 'package:lume_app/providers/order_provider.dart';
import 'package:lume_app/providers/review_provider.dart';
import 'package:lume_app/screens/review/review_screen.dart';

void main() {
  test('pending order can be cancelled and local state is updated', () async {
    final api = _FakeOrderApi([_order('pending', OrderStatus.pending)]);
    final provider = OrderProvider(api: api);

    await provider.load();
    expect(await provider.cancel('pending'), isTrue);
    expect(provider.orders.single.status, OrderStatus.cancelled);
    expect(api.updatedStatus, OrderStatus.cancelled);

    provider.dispose();
  });

  test('non-pending order cannot be cancelled', () async {
    final api = _FakeOrderApi([_order('shipping', OrderStatus.shipping)]);
    final provider = OrderProvider(api: api);

    await provider.load();
    expect(await provider.cancel('shipping'), isFalse);
    expect(provider.orders.single.status, OrderStatus.shipping);
    expect(api.updatedStatus, isNull);
    expect(provider.error, contains('đang chờ xác nhận'));

    provider.dispose();
  });

  test('submitted review is available for product and order item', () {
    final provider = ReviewProvider();
    final review = provider.submit(
      productId: '26',
      author: 'Lan Anh',
      rating: 5,
      fit: 'Vừa chân',
      comment: 'Mang rất êm.',
      imageCount: 1,
      orderId: 'order-26',
    );

    expect(provider.forProduct('26').first, same(review));
    expect(provider.hasReviewForOrderItem('order-26', '26'), isTrue);
    expect(review.imageCount, 1);
    provider.dispose();
  });

  testWidgets('review form saves the selected fit and comment', (tester) async {
    final provider = ReviewProvider();
    const item = OrderItem(
      productId: '26',
      name: 'Slingback Grace',
      image: '',
      price: 600000,
      size: '37',
      color: 'Kem',
      quantity: 1,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ReviewScreen(
                      args: ReviewRouteArgs(
                        orderId: 'order-review',
                        item: item,
                        customerName: 'Lan Anh',
                      ),
                    ),
                  ),
                ),
                child: const Text('Open review'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open review'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hơi chật'));
    await tester.enterText(
      find.byType(TextFormField),
      'Phần mũi hơi chật nhưng chất liệu mềm.',
    );
    await tester.scrollUntilVisible(
      find.text('Gửi đánh giá'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Gửi đánh giá'));
    await tester.pumpAndSettle();

    final review = provider.forProduct('26').first;
    expect(review.author, 'Lan Anh');
    expect(review.fit, 'Hơi chật');
    expect(review.comment, 'Phần mũi hơi chật nhưng chất liệu mềm.');
    expect(provider.hasReviewForOrderItem('order-review', '26'), isTrue);
    provider.dispose();
  });
}

Order _order(String id, String status) => Order(
  id: id,
  customerName: 'Lan',
  phone: '0900000000',
  address: 'TP. Hồ Chí Minh',
  paymentMethod: 'Thanh toán khi nhận hàng',
  status: status,
  items: const [
    OrderItem(
      productId: '1',
      name: 'Giày mẫu',
      image: '',
      price: 500000,
      size: '37',
      color: 'Đen',
      quantity: 1,
    ),
  ],
  total: 530000,
  createdAt: DateTime(2026, 11, 1),
);

class _FakeOrderApi extends OrderApi {
  _FakeOrderApi(this.orders);

  final List<Order> orders;
  String? updatedStatus;

  @override
  Future<List<Order>> fetchOrders() async => orders;

  @override
  Future<Order> createOrder(Order order) async => order;

  @override
  Future<void> updateStatus(String id, String status) async {
    updatedStatus = status;
  }
}

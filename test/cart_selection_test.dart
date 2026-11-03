import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lume_app/data/api_client.dart';
import 'package:lume_app/data/order_api.dart';
import 'package:lume_app/models/order.dart';
import 'package:lume_app/models/product.dart';
import 'package:lume_app/providers/cart_provider.dart';
import 'package:lume_app/providers/order_provider.dart';
import 'package:lume_app/screens/cart/cart_screen.dart';
import 'package:provider/provider.dart';

void main() {
  group('chon mon de thanh toan', () {
    test('new cart lines are ticked by default', () {
      final cart = CartProvider();
      cart.add(_product('1', 500000), size: '37', color: 'Đen');
      cart.add(_product('2', 800000), size: '38', color: 'Kem');

      expect(cart.allSelected, isTrue);
      expect(cart.hasSelection, isTrue);
      expect(cart.selectedCount, 2);
      expect(cart.selectedItems.length, 2);

      cart.dispose();
    });

    test('unticking a line leaves the whole-cart getters untouched', () {
      final cart = CartProvider();
      cart.add(_product('1', 500000), size: '37', color: 'Đen');
      cart.add(_product('2', 800000), size: '38', color: 'Kem');

      cart.toggleSelect(cart.items[1], false);

      expect(cart.selectedSubtotal, 500000);
      expect(cart.selectedCount, 1);
      // Badge o Chi tiet san pham van dem ca gio.
      expect(cart.subtotal, 1300000);
      expect(cart.count, 2);
      expect(cart.allSelected, isFalse);

      cart.dispose();
    });

    test('selectAll toggles every line at once', () {
      final cart = CartProvider();
      cart.add(_product('1', 500000), size: '37', color: 'Đen');
      cart.add(_product('2', 800000), size: '38', color: 'Kem');

      cart.selectAll(false);
      expect(cart.hasSelection, isFalse);
      expect(cart.allSelected, isFalse);
      expect(cart.selectedTotal, 0);
      expect(cart.selectedShipping, 0);

      cart.selectAll(true);
      expect(cart.allSelected, isTrue);

      cart.dispose();
    });

    test('an empty cart is not reported as fully selected', () {
      final cart = CartProvider();
      expect(cart.allSelected, isFalse);
      cart.dispose();
    });

    test('voucher never pushes the selected total below zero', () {
      final cart = CartProvider();
      cart.add(_product('1', 20000), size: '37', color: 'Đen');

      expect(cart.applyVoucher('LUME50K'), isTrue);
      expect(cart.selectedDiscount, 20000);
      expect(cart.selectedTotal, CartProvider.shippingFee);
      expect(cart.selectedTotal >= 0, isTrue);

      cart.dispose();
    });

    test('free shipping follows the selected subtotal', () {
      final cart = CartProvider();
      cart.add(_product('1', 1000000), size: '37', color: 'Đen');
      cart.add(_product('2', 800000), size: '38', color: 'Kem');

      expect(cart.selectedShipping, 0);

      cart.toggleSelect(cart.items[1], false);
      expect(cart.selectedSubtotal, 1000000);
      expect(cart.selectedShipping, CartProvider.shippingFee);

      cart.dispose();
    });

    test('selectOnly ticks exactly one variant', () {
      final cart = CartProvider();
      cart.add(_product('1', 500000), size: '37', color: 'Đen');
      cart.add(_product('2', 800000), size: '38', color: 'Kem');
      cart.add(_product('3', 300000), size: '39', color: 'Nâu');

      cart.selectOnly('2', size: '38', color: 'Kem');

      expect(cart.selectedItems.length, 1);
      expect(cart.selectedItems.single.product.id, '2');
      expect(cart.selectedSubtotal, 800000);

      cart.dispose();
    });

    test('changing the variant keeps the unticked state', () {
      final cart = CartProvider();
      cart.add(_product('1', 500000), size: '37', color: 'Đen');

      cart.toggleSelect(cart.items.single, false);
      cart.changeVariant(cart.items.single, size: '38', color: 'Đen');

      expect(cart.items.single.size, '38');
      expect(cart.items.single.selected, isFalse);

      cart.dispose();
    });

    test('merging a ticked line into an unticked line keeps it ticked', () {
      final cart = CartProvider();
      final product = _product('1', 500000);
      cart.add(product, size: '37', color: 'Đen');
      cart.add(product, size: '38', color: 'Đen');

      cart.toggleSelect(cart.items[0], false);
      cart.changeVariant(cart.items[1], size: '37', color: 'Đen');

      expect(cart.items.length, 1);
      expect(cart.items.single.quantity, 2);
      expect(cart.items.single.selected, isTrue);

      cart.dispose();
    });

    test('adding an existing line ticks it again', () {
      final cart = CartProvider();
      final product = _product('1', 500000);
      cart.add(product, size: '37', color: 'Đen');

      cart.toggleSelect(cart.items.single, false);
      cart.add(product, size: '37', color: 'Đen');

      expect(cart.items.single.quantity, 2);
      expect(cart.items.single.selected, isTrue);

      cart.dispose();
    });

    test('removeSelected keeps the voucher while the cart still has items', () {
      final cart = CartProvider();
      cart.add(_product('1', 500000), size: '37', color: 'Đen');
      cart.add(_product('2', 800000), size: '38', color: 'Kem');
      cart.applyVoucher('LUME50K');

      cart.toggleSelect(cart.items[1], false);
      cart.removeSelected();

      expect(cart.items.length, 1);
      expect(cart.items.single.product.id, '2');
      expect(cart.voucherCode, 'LUME50K');
      expect(cart.hasSelection, isFalse);

      cart.dispose();
    });

    test('buying again only ticks the lines of the old order', () {
      final cart = CartProvider();
      cart.add(_product('1', 500000), size: '37', color: 'Đen');

      // Man Don hang bo tick hang cu roi moi them lai cac mon cua don.
      cart.selectAll(false);
      cart.add(_product('2', 800000), size: '38', color: 'Kem');

      expect(cart.selectedItems.length, 1);
      expect(cart.selectedItems.single.product.id, '2');
      expect(cart.selectedSubtotal, 800000);

      cart.dispose();
    });

    test('removeSelected drops the voucher once the cart is empty', () {
      final cart = CartProvider();
      cart.add(_product('1', 500000), size: '37', color: 'Đen');
      cart.applyVoucher('LUME50K');

      cart.removeSelected();

      expect(cart.isEmpty, isTrue);
      expect(cart.voucherCode, isNull);

      cart.dispose();
    });
  });

  group('dat hang voi mon da tick', () {
    test('only the ticked lines are sent and removed', () async {
      final cart = CartProvider();
      cart.add(_product('1', 500000), size: '37', color: 'Đen');
      cart.add(_product('2', 800000), size: '38', color: 'Kem');
      cart.applyVoucher('LUME50K');
      cart.toggleSelect(cart.items[1], false);

      final api = _RecordingOrderApi();
      final orders = OrderProvider(api: api);

      final placed = await _place(orders, cart);

      expect(placed, isNotNull);
      expect(api.sent!.items.length, 1);
      expect(api.sent!.items.single.productId, '1');
      // 500.000 − 50.000 + 30.000 phi ship.
      expect(api.sent!.total, 480000);
      // Mon chua tick con lai trong gio va duoc tick lai.
      expect(cart.items.length, 1);
      expect(cart.items.single.product.id, '2');
      expect(cart.items.single.selected, isTrue);
      expect(cart.voucherCode, isNull);

      orders.dispose();
      cart.dispose();
    });

    test('a failed order leaves the cart and the ticks untouched', () async {
      final cart = CartProvider();
      cart.add(_product('1', 500000), size: '37', color: 'Đen');
      cart.add(_product('2', 800000), size: '38', color: 'Kem');
      cart.applyVoucher('LUME50K');
      cart.toggleSelect(cart.items[1], false);

      final orders = OrderProvider(api: _FailingOrderApi());

      final placed = await _place(orders, cart);

      expect(placed, isNull);
      expect(cart.items.length, 2);
      expect(cart.items[0].selected, isTrue);
      expect(cart.items[1].selected, isFalse);
      expect(cart.voucherCode, 'LUME50K');

      orders.dispose();
      cart.dispose();
    });
  });

  group('man gio hang', () {
    testWidgets('unticking a line updates the bottom bar', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final cart = CartProvider();
      cart.add(_product('1', 500000), size: '37', color: 'Đen');
      cart.add(_product('2', 800000), size: '38', color: 'Kem');
      addTearDown(cart.dispose);

      await tester.pumpWidget(_wrap(cart));

      expect(find.text('Thanh toán (2)'), findsOneWidget);

      // O tick dau tien cua danh sach, khong phai o "Tat ca" duoi thanh.
      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      expect(find.text('Thanh toán (1)'), findsOneWidget);
      expect(find.text('Tạm tính (1 sản phẩm)'), findsOneWidget);
    });

    testWidgets('checkout is disabled when nothing is ticked', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final cart = CartProvider();
      cart.add(_product('1', 500000), size: '37', color: 'Đen');
      cart.add(_product('2', 800000), size: '38', color: 'Kem');
      addTearDown(cart.dispose);

      await tester.pumpWidget(_wrap(cart));

      await tester.tap(find.byType(Checkbox).last); // o "Tat ca"
      await tester.pump();

      expect(find.text('Chưa chọn sản phẩm nào'), findsOneWidget);
      expect(find.text('Xóa (2)'), findsNothing);
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Thanh toán (0)'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('removing the ticked lines asks first', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final cart = CartProvider();
      cart.add(_product('1', 500000), size: '37', color: 'Đen');
      cart.add(_product('2', 800000), size: '38', color: 'Kem');
      addTearDown(cart.dispose);

      await tester.pumpWidget(_wrap(cart));

      await tester.tap(find.text('Xóa (2)'));
      await tester.pumpAndSettle();
      expect(find.text('Xóa sản phẩm đã chọn?'), findsOneWidget);

      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(cart.items.length, 2);

      await tester.tap(find.text('Xóa (2)'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Xóa'));
      await tester.pumpAndSettle();

      expect(cart.isEmpty, isTrue);
      expect(find.text('Giỏ hàng đang trống'), findsOneWidget);
    });
  });
}

Widget _wrap(CartProvider cart) {
  return ChangeNotifierProvider<CartProvider>.value(
    value: cart,
    child: const MaterialApp(home: CartScreen()),
  );
}

Future<Order?> _place(OrderProvider orders, CartProvider cart) {
  return orders.place(
    cart: cart,
    customerName: 'Hạo',
    phone: '0900000000',
    address: '[Nhà riêng] 279 Nguyễn Tri Phương, P.5, Q.10',
    paymentMethod: 'Thanh toán khi nhận hàng (COD)',
  );
}

Product _product(String id, int price) => Product(
  id: id,
  name: 'Giày mẫu $id',
  category: 'Cao gót',
  price: price,
  oldPrice: price,
  rating: 4.5,
  heelHeight: 5,
  material: 'Da',
  occasions: const ['Dạo phố'],
  isNew: false,
  colors: const ['Đen', 'Kem', 'Nâu'],
  sizes: const ['37', '38', '39'],
  image: '',
  model3d: '',
  description: '',
);

class _RecordingOrderApi extends OrderApi {
  Order? sent;

  @override
  Future<Order> createOrder(Order order) async {
    sent = order;
    return order;
  }
}

class _FailingOrderApi extends OrderApi {
  @override
  Future<Order> createOrder(Order order) async {
    throw ApiException('Không có mạng');
  }
}

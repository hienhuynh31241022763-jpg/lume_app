import 'order.dart';
import 'product.dart';

class CartItem {
  final Product product;
  final String size;
  final String color;
  int quantity;

  /// MH-15: dòng này có được tick để thanh toán không. Mặc định tick sẵn.
  /// Chỉ đổi qua [CartProvider.toggleSelect] / [CartProvider.selectAll],
  /// gán thẳng ở màn hình thì giỏ không báo cho UI vẽ lại.
  /// Không đưa vào [toOrderItem]; nếu sau này thêm `==`/`hashCode` thì bỏ qua.
  bool selected;

  CartItem({
    required this.product,
    required this.size,
    required this.color,
    this.quantity = 1,
    this.selected = true,
  });

  int get total => product.price * quantity;

  OrderItem toOrderItem() {
    return OrderItem(
      productId: product.id,
      name: product.name,
      image: product.image,
      price: product.price,
      size: size,
      color: color,
      quantity: quantity,
    );
  }
}

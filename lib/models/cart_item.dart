import 'order.dart';
import 'product.dart';

class CartItem {
  final Product product;
  final String size;
  final String color;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    required this.color,
    this.quantity = 1,
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

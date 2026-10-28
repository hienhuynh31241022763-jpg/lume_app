import 'json_utils.dart';

DateTime _toDate(dynamic value) {
  if (value is num) {
    final n = value.toInt();
    return DateTime.fromMillisecondsSinceEpoch(n < 100000000000 ? n * 1000 : n);
  }
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
}

class OrderItem {
  final String productId;
  final String name;
  final String image;
  final int price;
  final String size;
  final String color;
  final int quantity;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.size,
    required this.color,
    required this.quantity,
  });

  int get total => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: (json['productId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      price: toNum(json['price']).toInt(),
      size: (json['size'] ?? '').toString(),
      color: (json['color'] ?? '').toString(),
      quantity: toNum(json['quantity']).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'image': image,
    'price': price,
    'size': size,
    'color': color,
    'quantity': quantity,
  };
}

class Order {
  final String id;
  final String customerName;
  final String phone;
  final String address;
  final String paymentMethod;
  final String status;
  final List<OrderItem> items;
  final int total;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.paymentMethod,
    required this.status,
    required this.items,
    required this.total,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return Order(
      id: (json['id'] ?? '').toString(),
      customerName: (json['customerName'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      paymentMethod: (json['paymentMethod'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : [],
      total: toNum(json['total']).toInt(),
      createdAt: _toDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'customerName': customerName,
    'phone': phone,
    'address': address,
    'paymentMethod': paymentMethod,
    'status': status,
    'items': items.map((e) => e.toJson()).toList(),
    'total': total,
    'createdAt': createdAt.toIso8601String(),
  };
}

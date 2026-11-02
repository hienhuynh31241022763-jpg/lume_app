import '../../models/order.dart';

/// HT-01 / HT-02 · Định dạng đơn hàng nhóm đã thống nhất (2026-11-01).
/// Màn Đơn hàng (Giang) dùng lại các hàm này để hiện giống nhau.

/// Mã đơn: "#LM" + ngày đặt yyyyMMdd + id 3 số. VD: #LM20261031007
String orderCode(Order order) {
  final d = order.createdAt.toLocal();
  final date = '${d.year}${_two(d.month)}${_two(d.day)}';
  return '#LM$date${order.id.padLeft(3, '0')}';
}

/// Số ngày giao dự kiến kể từ lúc đặt.
const deliveryDays = 3;

/// "Thứ Năm, 05/11"
String estimatedDelivery(DateTime orderedAt) {
  final d = orderedAt.toLocal().add(const Duration(days: deliveryDays));
  return '${_weekdays[d.weekday - 1]}, ${_two(d.day)}/${_two(d.month)}';
}

/// Tên phương thức thanh toán ghi vào `Order.paymentMethod`.
class PaymentNames {
  PaymentNames._();

  static const cod = 'Thanh toán khi nhận hàng (COD)';
  static const bank = 'Chuyển khoản ngân hàng';

  /// "Ví điện tử · MoMo"
  static String wallet(String name) => 'Ví điện tử · $name';
}

const _weekdays = [
  'Thứ Hai',
  'Thứ Ba',
  'Thứ Tư',
  'Thứ Năm',
  'Thứ Sáu',
  'Thứ Bảy',
  'Chủ Nhật',
];

String _two(int n) => n.toString().padLeft(2, '0');

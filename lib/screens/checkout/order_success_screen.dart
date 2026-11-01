import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../models/order.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';
import '../main_shell.dart';
import 'order_format.dart';

/// HT-02 · Đặt hàng thành công
/// - Dấu tích động (lottie), mã đơn, ngày giao dự kiến.
/// - "Theo dõi đơn hàng" mở Đơn hàng; "Tiếp tục mua sắm" về Trang chủ.
/// Thanh toán mở màn này kèm [order]. Route chung `AppRoutes.orderSuccess`
/// vẫn dựng được (không có đơn thì chỉ hiện lời cảm ơn).
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, this.order});

  final Order? order;

  void _continueShopping(BuildContext context) {
    MainShell.selectTab(MainShell.homeTab);
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final order = this.order;
    final textTheme = Theme.of(context).textTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            children: [
              const Spacer(),
              SizedBox.square(
                dimension: 180,
                // Máy bật "giảm chuyển động" thì hiện dấu tích tĩnh.
                child: reduceMotion
                    ? const _StaticCheck()
                    : Lottie.asset(
                        'assets/animations/order_success.json',
                        repeat: false,
                        errorBuilder: (_, _, _) => const _StaticCheck(),
                      ),
              ),
              const SizedBox(height: 12),
              Text('Đặt hàng thành công!', style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Cảm ơn bạn đã mua sắm tại LUMÉ',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              if (order != null) ...[
                const SizedBox(height: 20),
                _OrderInfo(order: order),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.orders),
                child: const Text('Theo dõi đơn hàng'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => _continueShopping(context),
                child: const Text('Tiếp tục mua sắm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaticCheck extends StatelessWidget {
  const _StaticCheck();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircleAvatar(
        radius: 60,
        backgroundColor: AppColors.rose,
        child: Icon(Icons.check, size: 64, color: Colors.white),
      ),
    );
  }
}

class _OrderInfo extends StatelessWidget {
  const _OrderInfo({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, Widget value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          value,
        ],
      ),
    );
    const bold = TextStyle(fontWeight: FontWeight.w700);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          row('Mã đơn', Text(orderCode(order), style: bold)),
          row(
            'Dự kiến giao',
            Text(estimatedDelivery(order.createdAt), style: bold),
          ),
          row(
            'Thanh toán',
            Flexible(
              child: Text(
                order.paymentMethod,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          row('Tổng tiền', PriceText(order.total)),
        ],
      ),
    );
  }
}

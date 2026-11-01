import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../../routes/app_routes.dart';
import '../../screens/orders/order_detail_screen.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({this.order, super.key});

  final Order? order;

  @override
  Widget build(BuildContext context) {
    final placedOrder = order;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt hàng thành công'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 42,
                backgroundColor: AppColors.blush,
                child: Icon(
                  Icons.check_rounded,
                  size: 48,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Cảm ơn bạn đã đặt hàng!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Đơn hàng đang chờ shop xác nhận.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
              if (placedOrder != null) ...[
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Mã đơn hàng: ${placedOrder.id}'),
                        const SizedBox(height: 8),
                        PriceText(placedOrder.total),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => OrderDetailScreen(order: placedOrder),
                      ),
                    ),
                    child: const Text('Theo dõi đơn hàng'),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.shell,
                    (_) => false,
                  ),
                  child: const Text('Tiếp tục mua sắm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

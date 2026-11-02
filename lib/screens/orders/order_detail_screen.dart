import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/review_provider.dart';
import '../../routes/app_routes.dart';
import '../../screens/home/demo_data.dart';
import '../../screens/review/review_screen.dart';
import '../cart/cart_screen.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({required this.order, super.key});

  final Order order;

  Future<void> _cancel(BuildContext context, Order currentOrder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn hàng?'),
        content: const Text('Bạn có chắc muốn hủy đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Giữ đơn'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success = await context.read<OrderProvider>().cancel(currentOrder.id);
    if (!context.mounted) return;
    final error = context.read<OrderProvider>().error;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Đã hủy đơn hàng' : error ?? 'Không thể hủy đơn hàng',
          ),
        ),
      );
  }

  void _buyAgain(BuildContext context, Order order) {
    final productProvider = context.read<ProductProvider>();
    final products = [
      for (final item in order.items)
        productById(productProvider, item.productId),
    ];
    if (products.any((product) => product == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Một số sản phẩm trong đơn không còn kinh doanh'),
        ),
      );
      return;
    }

    final cart = context.read<CartProvider>();
    for (var index = 0; index < order.items.length; index++) {
      final item = order.items[index];
      cart.add(
        products[index]!,
        size: item.size,
        color: item.color,
        quantity: item.quantity,
      );
    }
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const CartScreen()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thêm sản phẩm cũ vào giỏ hàng')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;
    final currentOrder =
        orders.where((item) => item.id == order.id).firstOrNull ?? order;
    final reviewProvider = context.watch<ReviewProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _OrderStatusCard(order: currentOrder),
          const SizedBox(height: 12),
          _DeliveryTimeline(order: currentOrder),
          const SizedBox(height: 12),
          _OrderInfoCard(order: currentOrder),
          const SizedBox(height: 12),
          _ItemsCard(order: currentOrder, reviewProvider: reviewProvider),
          const SizedBox(height: 12),
          _PaymentCard(order: currentOrder),
          const SizedBox(height: 20),
          if (currentOrder.status == OrderStatus.pending)
            OutlinedButton.icon(
              onPressed: () => _cancel(context, currentOrder),
              icon: const Icon(Icons.close),
              label: const Text('Hủy đơn hàng'),
            ),
          if (currentOrder.status != OrderStatus.pending)
            ElevatedButton.icon(
              onPressed: () => _buyAgain(context, currentOrder),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Mua lại đơn này'),
            ),
        ],
      ),
    );
  }
}

class _OrderStatusCard extends StatelessWidget {
  const _OrderStatusCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final color = switch (order.status) {
      OrderStatus.delivered => AppColors.success,
      OrderStatus.cancelled => AppColors.muted,
      OrderStatus.shipping => AppColors.roseDark,
      _ => AppColors.warning,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              order.status == OrderStatus.delivered
                  ? Icons.check_circle_outline
                  : order.status == OrderStatus.cancelled
                  ? Icons.cancel_outlined
                  : Icons.local_shipping_outlined,
              color: color,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.status,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Mã đơn: ${order.id}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryTimeline extends StatelessWidget {
  const _DeliveryTimeline({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final cancelled = order.status == OrderStatus.cancelled;
    final currentStep = switch (order.status) {
      OrderStatus.pending => 0,
      OrderStatus.shipping => 1,
      OrderStatus.delivered => 2,
      _ => -1,
    };
    final steps = [
      ('Chờ xác nhận', 'Shop đã nhận được đơn hàng'),
      ('Đang giao', 'Đơn hàng đang trên đường đến bạn'),
      ('Đã giao', 'Giao hàng thành công'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theo dõi đơn hàng',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (cancelled)
              _TimelineEntry(
                title: 'Đơn hàng đã hủy',
                subtitle: 'Đơn hàng này đã được hủy',
                active: true,
                isLast: true,
                color: AppColors.error,
              )
            else
              for (var index = 0; index < steps.length; index++)
                _TimelineEntry(
                  title: steps[index].$1,
                  subtitle: steps[index].$2,
                  active: index <= currentStep,
                  isLast: index == steps.length - 1,
                  date: index == 0 ? _formatDateTime(order.createdAt) : null,
                ),
          ],
        ),
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.title,
    required this.subtitle,
    required this.active,
    required this.isLast,
    this.date,
    this.color = AppColors.rose,
  });

  final String title;
  final String subtitle;
  final bool active;
  final bool isLast;
  final String? date;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pointColor = active ? color : AppColors.line;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Icon(
                  active ? Icons.check_circle : Icons.circle_outlined,
                  size: 18,
                  color: pointColor,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: active ? AppColors.blush : AppColors.line,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: active ? color : AppColors.muted,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    date == null ? subtitle : '$subtitle · $date',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderInfoCard extends StatelessWidget {
  const _OrderInfoCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin nhận hàng',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _InfoLine(Icons.person_outline, order.customerName),
            _InfoLine(Icons.phone_outlined, order.phone),
            _InfoLine(Icons.location_on_outlined, order.address),
          ],
        ),
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.order, required this.reviewProvider});

  final Order order;
  final ReviewProvider reviewProvider;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sản phẩm đã đặt',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final item in order.items) ...[
              const Divider(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OrderProductImage(item: item),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Size ${item.size}'
                          '${item.color.isEmpty ? '' : ' · ${item.color}'}'
                          ' · SL ${item.quantity}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        PriceText(item.total),
                        if (order.status == OrderStatus.delivered) ...[
                          const SizedBox(height: 6),
                          if (reviewProvider.hasReviewForOrderItem(
                            order.id,
                            item.productId,
                          ))
                            const Text(
                              'Đã đánh giá',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else
                            TextButton.icon(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.review,
                                arguments: ReviewRouteArgs(
                                  orderId: order.id,
                                  item: item,
                                  customerName: order.customerName,
                                ),
                              ),
                              icon: const Icon(Icons.rate_review_outlined),
                              label: const Text('Viết đánh giá'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrderProductImage extends StatelessWidget {
  const _OrderProductImage({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    const fallback = ColoredBox(
      color: AppColors.blush,
      child: Center(
        child: Icon(Icons.shopping_bag_outlined, color: AppColors.rose),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 64,
        height: 64,
        child: item.image.startsWith('http')
            ? Image.network(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              )
            : item.image.startsWith('product_images/')
            ? Image.asset(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              )
            : fallback,
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoLine(Icons.payment_outlined, order.paymentMethod),
            const Divider(height: 20),
            Row(
              children: [
                const Expanded(child: Text('Tổng thanh toán')),
                PriceText(order.total),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: 9),
          Expanded(child: Text(text.isEmpty ? 'Chưa cập nhật' : text)),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year} '
    '${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';

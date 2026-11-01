import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';
import 'order_detail_screen.dart';

const _orderTabs = [
  'Tất cả',
  OrderStatus.pending,
  OrderStatus.shipping,
  OrderStatus.delivered,
  OrderStatus.cancelled,
];

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: _orderTabs.length,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<OrderProvider>().load();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.roseDark,
          indicatorColor: AppColors.rose,
          tabs: [
            for (var i = 0; i < _orderTabs.length; i++)
              Tab(
                text: i == 0
                    ? _orderTabs[i]
                    : '${_orderTabs[i]} (${provider.orders.where((o) => o.status == _orderTabs[i]).length})',
              ),
          ],
        ),
      ),
      body: provider.isLoading && provider.orders.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.rose),
            )
          : provider.error != null && provider.orders.isEmpty
          ? _LoadError(
              message: provider.error!,
              onRetry: () => context.read<OrderProvider>().load(),
            )
          : TabBarView(
              controller: _tabs,
              children: [
                for (final status in _orderTabs)
                  _OrderList(
                    orders: status == 'Tất cả'
                        ? provider.orders
                        : provider.orders
                              .where((order) => order.status == status)
                              .toList(),
                  ),
              ],
            ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        color: AppColors.rose,
        onRefresh: () => context.read<OrderProvider>().load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Icon(Icons.receipt_long_outlined, size: 52, color: AppColors.muted),
            SizedBox(height: 12),
            Center(
              child: Text(
                'Chưa có đơn hàng',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.rose,
      onRefresh: () => context.read<OrderProvider>().load(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _OrderCard(order: orders[index]),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (order.status) {
      OrderStatus.delivered => AppColors.success,
      OrderStatus.cancelled => AppColors.muted,
      OrderStatus.shipping => AppColors.roseDark,
      _ => AppColors.warning,
    };

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => OrderDetailScreen(order: order),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Đơn hàng #${order.id}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    order.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                '${order.items.length} sản phẩm · ${_formatDate(order.createdAt)}',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const Divider(height: 22),
              if (order.items.isNotEmpty)
                Text(
                  order.items.first.name +
                      (order.items.length > 1
                          ? ' và ${order.items.length - 1} sản phẩm khác'
                          : ''),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Spacer(),
                  const Text(
                    'Tổng thanh toán: ',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                  PriceText(order.total),
                ],
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Xem chi tiết  ›',
                  style: TextStyle(
                    color: AppColors.roseDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 42,
              color: AppColors.muted,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';

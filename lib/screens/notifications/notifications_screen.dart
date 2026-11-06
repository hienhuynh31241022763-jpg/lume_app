import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Thông báo',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFFC86D7C), // Màu chủ đạo của LUMÉ
            labelColor: Color(0xFFC86D7C),
            unselectedLabelColor: Colors.black54,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Tất cả'),
              Tab(text: 'Đơn hàng'),
              Tab(text: 'Khuyến mãi'),
            ],
          ),
        ),
        body: Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            return TabBarView(
              children: [
                // Tab 1: Tất cả
                _buildList(provider.notifications),

                // Tab 2: Đơn hàng
                _buildList(provider.orderNotifications),

                // Tab 3: Khuyến mãi
                _buildList(provider.promoNotifications),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<NotificationItem> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có thông báo nào',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFC86D7C).withOpacity(0.1),
            child: Icon(
              item.type == 'order'
                  ? Icons.local_shipping_outlined
                  : (item.type == 'promo' ? Icons.discount_outlined : Icons.notifications_none),
              color: const Color(0xFFC86D7C),
            ),
          ),
          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              item.body,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        );
      },
    );
  }
}

// Giúp tương thích cả 2 cách gọi NotificationScreen và NotificationsScreen
typedef NotificationsScreen = NotificationScreen;

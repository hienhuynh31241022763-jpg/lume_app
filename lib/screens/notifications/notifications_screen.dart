import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/notification_data.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_colors.dart';

const _notificationTabs = ['Tất cả', 'Đơn hàng', 'Khuyến mãi'];

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: _notificationTabs.length,
    vsync: this,
  );

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: provider.markAllRead,
              child: const Text('Đọc tất cả'),
            ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.roseDark,
          indicatorColor: AppColors.rose,
          tabs: [for (final tab in _notificationTabs) Tab(text: tab)],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          for (final tab in _notificationTabs)
            _NotificationList(
              notifications: tab == 'Tất cả'
                  ? provider.notifications
                  : provider.notifications
                        .where((notification) => notification.type == tab)
                        .toList(),
              isInitializing: provider.isInitializing,
              isSupported: provider.isSupported,
              errorMessage: provider.errorMessage,
            ),
        ],
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({
    required this.notifications,
    required this.isInitializing,
    required this.isSupported,
    required this.errorMessage,
  });

  final List<AppNotification> notifications;
  final bool isInitializing;
  final bool isSupported;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      final message = errorMessage != null
          ? 'Không thể tải thông báo: $errorMessage'
          : !isSupported
          ? 'Thông báo đẩy chưa được hỗ trợ trên nền tảng này.'
          : 'Chưa có thông báo. Thông báo Firebase nhận được sẽ hiển thị tại đây.';
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isInitializing)
                const CircularProgressIndicator()
              else
                const Icon(
                  Icons.notifications_none,
                  size: 48,
                  color: AppColors.muted,
                ),
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (errorMessage != null)
          Container(
            color: AppColors.blush,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.roseDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Không thể đồng bộ thông báo: $errorMessage'),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 9),
            itemBuilder: (context, index) =>
                _NotificationTile(notification: notifications[index]),
          ),
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final read = provider.isRead(notification);
    final isOrder = notification.type == 'Đơn hàng';
    final accent = isOrder ? AppColors.rose : AppColors.warning;
    final icon = isOrder
        ? Icons.local_shipping_outlined
        : notification.title.toLowerCase().contains('flash')
        ? Icons.bolt
        : Icons.confirmation_number_outlined;

    return Material(
      color: read ? AppColors.card : AppColors.blush.withValues(alpha: 0.48),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          provider.markRead(notification);
          showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            backgroundColor: AppColors.background,
            builder: (context) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: accent,
                          child: Icon(icon, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            notification.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      notification.content,
                      style: const TextStyle(height: 1.5, fontSize: 14),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          notification.type,
                          style: const TextStyle(
                            color: AppColors.roseDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          notification.time,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: accent,
                child: Icon(icon, size: 19, color: Colors.white),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: read ? FontWeight.w500 : FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.content,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.time,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (!read)
                Padding(
                  padding: const EdgeInsets.only(left: 6, top: 5),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.rose,
                      shape: BoxShape.circle,
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

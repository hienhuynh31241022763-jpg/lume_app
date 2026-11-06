import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Model thông báo đơn giản
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type; // 'order', 'promo', hoặc 'system'
  final DateTime createdAt;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });
}

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({dynamic store, dynamic service});

  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => _notifications;

  // Lọc thông báo cho Tab Đơn hàng
  List<NotificationItem> get orderNotifications =>
      _notifications.where((item) => item.type == 'order').toList();

  // Lọc thông báo cho Tab Khuyến mãi
  List<NotificationItem> get promoNotifications =>
      _notifications.where((item) => item.type == 'promo').toList();

  int get unreadCount => _notifications.where((item) => !item.isRead).length;

  void markAsRead(NotificationItem item) {
    item.isRead = true;
    notifyListeners();
  }

  void markAllRead() {
    for (final item in _notifications) {
      item.isRead = true;
    }
    notifyListeners();
  }

  void addNotification(NotificationItem item) {
    _notifications.insert(0, item);
    notifyListeners();
  }

  Future<void> initialize() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // 1. Xin quyền thông báo
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      // 2. Bật hiển thị banner khi app đang mở (Foreground)
      await FirebaseMessaging.instance.setForegroundNotificationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Lắng nghe thông báo và lưu vào danh sách
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.notification?.title ?? message.data['title']?.toString() ?? '';
        final body = message.notification?.body ?? message.data['body']?.toString() ?? '';

        if (message.notification != null || title.isNotEmpty || body.isNotEmpty) {
          // Lấy type từ FCM Custom Data (mặc định là 'system' nếu không gửi)
          String rawType = (message.data['type'] ?? 'system').toString().toLowerCase();
          String type = 'system';
          if (rawType.contains('order') || rawType.contains('đơn')) {
            type = 'order';
          } else if (rawType.contains('promo') || rawType.contains('khuyến') || rawType.contains('offer')) {
            type = 'promo';
          } else if (rawType.isNotEmpty) {
            type = rawType;
          }

          final newNotification = NotificationItem(
            id: message.messageId ?? DateTime.now().toString(),
            title: title.isNotEmpty ? title : (message.notification?.title ?? ''),
            body: body.isNotEmpty ? body : (message.notification?.body ?? ''),
            type: type,
            createdAt: DateTime.now(),
          );

          _notifications.insert(0, newNotification); // Thêm lên đầu danh sách
          notifyListeners(); // Cập nhật lại UI lập tức
        }
      });
    } catch (e) {
      debugPrint('FirebaseMessaging initialize error: $e');
    }
  }
}

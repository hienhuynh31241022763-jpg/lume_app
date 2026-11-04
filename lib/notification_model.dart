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

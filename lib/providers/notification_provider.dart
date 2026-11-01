import 'package:flutter/foundation.dart';

import '../data/notification_data.dart';

class NotificationProvider extends ChangeNotifier {
  final Set<String> _readIds = {};

  List<AppNotification> get notifications => appNotifications;

  int get unreadCount =>
      appNotifications.where((notification) => !_readIds.contains(notification.id)).length;

  bool isRead(AppNotification notification) =>
      _readIds.contains(notification.id);

  void markRead(AppNotification notification) {
    if (_readIds.add(notification.id)) notifyListeners();
  }

  void markAllRead() {
    if (unreadCount == 0) return;
    _readIds.addAll(appNotifications.map((notification) => notification.id));
    notifyListeners();
  }
}

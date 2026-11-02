import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'notification_data.dart';

class NotificationInbox {
  const NotificationInbox({required this.notifications, required this.readIds});

  final List<AppNotification> notifications;
  final Set<String> readIds;
}

abstract interface class NotificationStore {
  Future<NotificationInbox> load();

  Future<void> save(List<AppNotification> notifications, Set<String> readIds);
}

class LocalNotificationStore implements NotificationStore {
  LocalNotificationStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _inboxKey = 'lume_notification_inbox_v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<NotificationInbox> load() async {
    final raw = await _preferences.getString(_inboxKey);
    if (raw == null || raw.isEmpty) {
      return const NotificationInbox(notifications: [], readIds: {});
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Hộp thư thông báo đã lưu không hợp lệ.');
    }
    final rawNotifications = decoded['notifications'];
    final rawReadIds = decoded['readIds'];
    if (rawNotifications is! List || rawReadIds is! List) {
      throw const FormatException('Dữ liệu hộp thư thông báo không đầy đủ.');
    }
    return NotificationInbox(
      notifications: rawNotifications
          .map(
            (item) => AppNotification.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      readIds: rawReadIds.map((id) => id as String).toSet(),
    );
  }

  @override
  Future<void> save(
    List<AppNotification> notifications,
    Set<String> readIds,
  ) async {
    final payload = jsonEncode({
      'notifications': notifications.map((item) => item.toJson()).toList(),
      'readIds': readIds.toList(),
    });
    await _preferences.setString(_inboxKey, payload);
  }
}

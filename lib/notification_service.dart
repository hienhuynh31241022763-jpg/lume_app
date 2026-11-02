import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'data/notification_data.dart';
import 'data/notification_store.dart';
import 'firebase_options.dart';

abstract interface class NotificationService {
  Future<void> initialize({
    required ValueChanged<AppNotification> onNotification,
  });

  Future<void> dispose();
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final notification = appNotificationFromMessage(message);
  if (notification == null) return;

  final store = LocalNotificationStore();
  final inbox = await store.load();
  if (!inbox.notifications.any((item) => item.id == notification.id)) {
    final notifications = [...inbox.notifications, notification]
      ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    await store.save(notifications, inbox.readIds);
  }

  if (message.notification == null) {
    await _showBackgroundDataNotification(notification);
  }
}

Future<void> _showBackgroundDataNotification(
  AppNotification notification,
) async {
  const channelId = 'high_importance_channel';
  const channelName = 'High Importance Notifications';
  const channelDescription = 'Thông báo đơn hàng và ưu đãi từ LUMÉ';
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  await plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.max,
        ),
      );
  await plugin.show(
    id: notification.id.hashCode,
    title: notification.title,
    body: notification.content,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
  );
}

class FcmNotificationService implements NotificationService {
  FcmNotificationService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  static const _channelId = 'high_importance_channel';
  static const _channelName = 'High Importance Notifications';
  static const _channelDescription = 'Thông báo đơn hàng và ưu đãi từ LUMÉ';
  static const _channel = AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: _channelDescription,
    importance: Importance.max,
  );

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  @override
  Future<void> initialize({
    required ValueChanged<AppNotification> onNotification,
  }) async {
    await dispose();
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    _subscriptions.add(
      FirebaseMessaging.onMessage.listen(
        (message) {
          final notification = appNotificationFromMessage(message);
          if (notification == null) return;
          onNotification(notification);
          unawaited(
            _showForegroundNotification(notification)
                .catchError((Object error, StackTrace stackTrace) {
                  debugPrint('Không thể hiện thông báo foreground: $error');
                  debugPrintStack(stackTrace: stackTrace);
                }),
          );
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('Lỗi khi nhận thông báo foreground: $error');
          debugPrintStack(stackTrace: stackTrace);
        },
      ),
    );
    _subscriptions.add(
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) {
          final notification = appNotificationFromMessage(message);
          if (notification != null) onNotification(notification);
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('Lỗi khi mở thông báo: $error');
          debugPrintStack(stackTrace: stackTrace);
        },
      ),
    );

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      final notification = appNotificationFromMessage(initialMessage);
      if (notification != null) onNotification(notification);
    }

    // Firebase Console's test sender uses the FCM registration token.
    // ignore: deprecated_member_use
    final token = await _messaging.getToken();
    if (kDebugMode && token != null) {
      debugPrint('FCM Registration Token: $token');
    }
  }

  Future<void> _showForegroundNotification(AppNotification notification) {
    return _localNotifications.show(
      id: notification.id.hashCode,
      title: notification.title,
      body: notification.content,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }
}

AppNotification? appNotificationFromMessage(RemoteMessage message) {
  final title =
      message.notification?.title ?? message.data['title']?.toString() ?? '';
  final content =
      message.notification?.body ??
      message.data['body']?.toString() ??
      message.data['content']?.toString() ??
      '';
  if (title.trim().isEmpty && content.trim().isEmpty) return null;

  final sentAt = message.sentTime;
  return AppNotification(
    id:
        message.messageId ??
        message.data['notificationId']?.toString() ??
        '${(sentAt ?? DateTime.now()).microsecondsSinceEpoch}',
    type: _notificationType(
      message.data['type']?.toString() ??
          message.data['category']?.toString() ??
          '',
    ),
    title: title.trim().isEmpty ? 'Thông báo' : title.trim(),
    content: content.trim(),
    receivedAt: sentAt ?? DateTime.now(),
  );
}

String _notificationType(String value) {
  final normalized = value.toLowerCase();
  if (normalized.contains('order') || normalized.contains('đơn hàng')) {
    return 'Đơn hàng';
  }
  if (normalized.contains('promo') ||
      normalized.contains('khuyến mãi') ||
      normalized.contains('offer')) {
    return 'Khuyến mãi';
  }
  return value.trim().isEmpty ? 'Thông báo' : value.trim();
}

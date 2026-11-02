import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lume_app/data/notification_data.dart';
import 'package:lume_app/data/notification_store.dart';
import 'package:lume_app/notification_service.dart';
import 'package:lume_app/providers/notification_provider.dart';

void main() {
  test('received inbox and read state survive provider recreation', () async {
    final store = _MemoryNotificationStore();
    final service = _FakeNotificationService();
    final provider = NotificationProvider(store: store, service: service);

    await provider.initialize();
    final message = AppNotification(
      id: 'fcm-message-1',
      type: 'Đơn hàng',
      title: 'Đơn hàng đã được xác nhận',
      content: 'Đơn hàng của bạn đang được chuẩn bị.',
      receivedAt: DateTime(2026, 10, 25),
    );
    service.emit(message);
    await Future<void>.delayed(Duration.zero);

    expect(provider.notifications, [message]);
    expect(provider.unreadCount, 1);
    await provider.markRead(message);
    expect(provider.unreadCount, 0);

    provider.dispose();
    final restored = NotificationProvider(
      store: store,
      service: _FakeNotificationService(),
    );
    await restored.initialize();

    expect(restored.notifications, [message]);
    expect(restored.isRead(message), isTrue);
    expect(restored.unreadCount, 0);
    restored.dispose();
  });

  test('duplicate received message is stored only once', () async {
    final store = _MemoryNotificationStore();
    final service = _FakeNotificationService();
    final provider = NotificationProvider(store: store, service: service);
    await provider.initialize();

    final message = AppNotification(
      id: 'same-message',
      type: 'Khuyến mãi',
      title: 'Ưu đãi mới',
      content: 'Nội dung ưu đãi.',
      receivedAt: DateTime(2026, 10, 25),
    );
    service.emit(message);
    service.emit(message);
    await Future<void>.delayed(Duration.zero);

    expect(provider.notifications, [message]);
    expect(store.inbox.notifications, [message]);
    provider.dispose();
  });
}

class _MemoryNotificationStore implements NotificationStore {
  NotificationInbox inbox = const NotificationInbox(
    notifications: [],
    readIds: {},
  );

  @override
  Future<NotificationInbox> load() async => inbox;

  @override
  Future<void> save(
    List<AppNotification> notifications,
    Set<String> readIds,
  ) async {
    inbox = NotificationInbox(
      notifications: List.unmodifiable(notifications),
      readIds: Set.unmodifiable(readIds),
    );
  }
}

class _FakeNotificationService implements NotificationService {
  ValueChanged<AppNotification>? _onNotification;

  void emit(AppNotification notification) {
    _onNotification?.call(notification);
  }

  @override
  Future<void> initialize({
    required ValueChanged<AppNotification> onNotification,
  }) async {
    _onNotification = onNotification;
  }

  @override
  Future<void> dispose() async {
    _onNotification = null;
  }
}

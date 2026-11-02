import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/notification_data.dart';
import '../data/notification_store.dart';
import '../notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({NotificationStore? store, this._service})
    : _store = store ?? LocalNotificationStore();

  final NotificationStore _store;
  NotificationService? _service;
  final List<AppNotification> _notifications = [];
  final Set<String> _readIds = {};
  String? _errorMessage;
  bool _isInitializing = false;
  bool _isInitialized = false;
  bool _isSupported = true;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount =>
      _notifications.where((item) => !_readIds.contains(item.id)).length;

  String? get errorMessage => _errorMessage;

  bool get isInitializing => _isInitializing;

  bool get isSupported => _isSupported;

  bool isRead(AppNotification notification) =>
      _readIds.contains(notification.id);

  Future<void> initialize() async {
    if (_isInitializing || _isInitialized) return;
    _isInitializing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final inbox = await _store.load();
      _notifications
        ..clear()
        ..addAll(inbox.notifications);
      _notifications.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
      _readIds
        ..clear()
        ..addAll(inbox.readIds);
    } catch (error, stackTrace) {
      _errorMessage = error.toString();
      debugPrint('Không thể tải hộp thư thông báo đã lưu: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    if (kIsWeb) {
      _isSupported = false;
      _isInitialized = true;
      _isInitializing = false;
      notifyListeners();
      return;
    }

    try {
      _service ??= FcmNotificationService();
      await _service!.initialize(onNotification: _handleIncomingNotification);
      _isSupported = true;
      _isInitialized = true;
    } catch (error, stackTrace) {
      _errorMessage = error.toString();
      debugPrint('Không thể khởi tạo Firebase Messaging: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> addNotification(AppNotification notification) =>
      _receiveNotification(notification);

  Future<void> _receiveNotification(AppNotification notification) async {
    if (_notifications.any((item) => item.id == notification.id)) return;
    _notifications.add(notification);
    _notifications.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    notifyListeners();
    await _saveInbox();
  }

  Future<void> markRead(AppNotification notification) async {
    if (!_readIds.add(notification.id)) return;
    notifyListeners();
    await _saveInbox();
  }

  Future<void> markAllRead() async {
    if (unreadCount == 0) return;
    _readIds.addAll(_notifications.map((item) => item.id));
    notifyListeners();
    await _saveInbox();
  }

  Future<void> _saveInbox() {
    return _persistInbox();
  }

  Future<void> _persistInbox() async {
    try {
      await _store.save(
        List.unmodifiable(_notifications),
        Set.unmodifiable(_readIds),
      );
    } catch (error, stackTrace) {
      _errorMessage = error.toString();
      debugPrint('Không thể lưu hộp thư thông báo: $error');
      debugPrintStack(stackTrace: stackTrace);
      notifyListeners();
    }
  }

  void _handleIncomingNotification(AppNotification notification) {
    unawaited(
      addNotification(notification)
          .catchError((Object error, StackTrace stackTrace) {
            debugPrint('Không thể lưu thông báo trên thiết bị: $error');
            debugPrintStack(stackTrace: stackTrace);
          }),
    );
  }

  @override
  void dispose() {
    final service = _service;
    if (service != null) unawaited(service.dispose());
    super.dispose();
  }
}

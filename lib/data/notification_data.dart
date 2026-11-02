class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.receivedAt,
  });

  final String id;
  final String type;
  final String title;
  final String content;
  final DateTime receivedAt;

  String get time {
    final elapsed = DateTime.now().difference(receivedAt);
    if (elapsed.inMinutes < 1) return 'Vừa xong';
    if (elapsed.inHours < 1) return '${elapsed.inMinutes} phút trước';
    if (elapsed.inDays < 1) return '${elapsed.inHours} giờ trước';
    if (elapsed.inDays == 1) return '1 ngày trước';
    return '${elapsed.inDays} ngày trước';
  }

  Map<String, Object> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'content': content,
    'receivedAt': receivedAt.toIso8601String(),
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      receivedAt: DateTime.parse(json['receivedAt'] as String),
    );
  }
}
